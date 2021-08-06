/*
 * Copyright 2021 Hewlett Packard Enterprise Development LP
 * Other additional copyright holders may be indicated within.
 *
 * The entirety of this work is licensed under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 *
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include "chpl/types/Param.h"

#include "chpl/queries/query-impl.h"
#include "chpl/types/BoolType.h"
#include "chpl/types/BytesType.h"
#include "chpl/types/CStringType.h"
#include "chpl/types/ComplexType.h"
#include "chpl/types/ImagType.h"
#include "chpl/types/IntType.h"
#include "chpl/types/RealType.h"
#include "chpl/types/StringType.h"
#include "chpl/types/UintType.h"

#include "../immediates/num.h"
#include "../immediates/prim_data.h"

namespace chpl {
namespace types {


Param::~Param() {
}

bool Param::completeMatch(const Param* other) const {
  const Param* lhs = this;
  const Param* rhs = other;
  if (lhs->tag() != rhs->tag())
    return false;
  if (!lhs->contentsMatchInner(rhs))
    return false;

  return true;
}

bool Param::updateParam(owned<Param>& keep, owned<Param>& addin) {
  if (keep->completeMatch(addin.get())) {
    // no changes are necessary
    return false;
  } else {
    // swap the Param
    keep.swap(addin);
    return true;
  }
}

void Param::markParam(Context* context, const Param* keep) {
  if (keep == nullptr) return;
  // run markUniqueStrings on the node
  keep->markUniqueStringsInner(context);
}

static
Immediate paramToImmediate(const Param* p, const Type* t) {
  Immediate ret;

  switch (p->tag()) {
    case paramtags::BoolParam:
      {
        auto bp = (const BoolParam*) p;
        auto v = bp->value();
        ret.const_kind = NUM_KIND_BOOL;
        ret.num_index = BOOL_SIZE_SYS;
        ret.v_bool = v;
        return ret;
      }
    case paramtags::ComplexParam:
      {
        auto cp = (const ComplexParam*) p;
        auto v = cp->value();
        auto ct = t->toComplexType();
        assert(ct);
        if (ct == nullptr) return ret;
        ret.const_kind = NUM_KIND_COMPLEX;
        if (ct->bitwidth() == 64) {
          ret.num_index = COMPLEX_SIZE_64;
          ret.v_complex64.r = v.re;
          ret.v_complex64.i = v.im;
        } else if (ct->bitwidth() == 128) {
          ret.num_index = COMPLEX_SIZE_128;
          ret.v_complex128.r = v.re;
          ret.v_complex128.i = v.im;
        } else {
          assert(false && "case not handled");
        }
        return ret;
      }
    case paramtags::IntParam:
      {
        auto ip = (const IntParam*) p;
        auto v = ip->value();
        auto it = t->toIntType();
        assert(it);
        if (it == nullptr) return ret;
        ret.const_kind = NUM_KIND_INT;
        if (it->bitwidth() == 8) {
          ret.num_index = INT_SIZE_8;
          ret.v_int8 = v;
        } else if (it->bitwidth() == 16) {
          ret.num_index = INT_SIZE_16;
          ret.v_int16 = v;
        } else if (it->bitwidth() == 32) {
          ret.num_index = INT_SIZE_32;
          ret.v_int32 = v;
        } else if (it->bitwidth() == 64) {
          ret.num_index = INT_SIZE_64;
          ret.v_int64 = v;
        } else {
          assert(false && "case not handled");
        }
        return ret;
      }
    case paramtags::NoneParam:
      {
        ret.const_kind = NUM_KIND_BOOL;
        ret.num_index = BOOL_SIZE_SYS;
        ret.v_bool = false;
        return ret;
      }
    case paramtags::RealParam:
      {
        auto rp = (const RealParam*) p;
        auto v = rp->value();
        if (auto rt = t->toRealType()) {
          ret.const_kind = NUM_KIND_REAL;
          if (rt->bitwidth() == 32) {
            ret.num_index = FLOAT_SIZE_32;
            ret.v_float32 = v;
          } else if (rt->bitwidth() == 64) {
            ret.num_index = FLOAT_SIZE_64;
            ret.v_float64 = v;
          } else {
            assert(false && "case not handled");
          }
        } else if (auto it = t->toImagType()) {
          ret.const_kind = NUM_KIND_IMAG;
          if (it->bitwidth() == 32) {
            ret.num_index = FLOAT_SIZE_32;
            ret.v_float32 = v;
          } else if (it->bitwidth() == 64) {
            ret.num_index = FLOAT_SIZE_64;
            ret.v_float64 = v;
          } else {
            assert(false && "case not handled");
          }
        } else {
          assert(false && "case not handled");
        }
        return ret;
      }
    case paramtags::StringParam:
      {
        auto sp = (const StringParam*) p;
        auto v = sp->value().podUniqueString();
        ret.const_kind = CONST_KIND_STRING;
        if (t->isStringType()) {
          ret.string_kind = STRING_KIND_STRING;
          ret.num_index = 0;
          ret.v_string = v;
        } else if (t->isBytesType()) {
          ret.string_kind = STRING_KIND_BYTES;
          ret.num_index = 0;
          ret.v_string = v;
        } else if (t->isCStringType()) {
          ret.string_kind = STRING_KIND_C_STRING;
          ret.num_index = 0;
          ret.v_string = v;
        } else {
          assert(false && "case not handled");
        }
        return ret;
      }
    case paramtags::UintParam:
      {
        auto up = (const UintParam*) p;
        auto v = up->value();
        auto ut = t->toUintType();
        assert(ut);
        if (ut == nullptr) return ret;
        ret.const_kind = NUM_KIND_UINT;
        if (ut->bitwidth() == 8) {
          ret.num_index = INT_SIZE_8;
          ret.v_uint8 = v;
        } else if (ut->bitwidth() == 16) {
          ret.num_index = INT_SIZE_16;
          ret.v_uint16 = v;
        } else if (ut->bitwidth() == 32) {
          ret.num_index = INT_SIZE_32;
          ret.v_uint32 = v;
        } else if (ut->bitwidth() == 64) {
          ret.num_index = INT_SIZE_64;
          ret.v_uint64 = v;
        } else {
          assert(false && "case not handled");
        }
        return ret;
      }
  }
  assert(false && "case not handled");
  return ret;
}

static
std::pair<const Param*, const Type*> immediateToParam(Context* context,
                                                      const Immediate& imm) {
  switch (imm.const_kind) {
  case NUM_KIND_INT:
    switch (imm.num_index) {
      case INT_SIZE_8:
        return {IntParam::get(context, imm.v_int8),
                IntType::get(context, 8)};
      case INT_SIZE_16:
        return {IntParam::get(context, imm.v_int16),
                IntType::get(context, 16)};
      case INT_SIZE_32:
        return {IntParam::get(context, imm.v_int32),
                IntType::get(context, 32)};
      case INT_SIZE_64:
        return {IntParam::get(context, imm.v_int64),
                IntType::get(context, 64)};
      default:
        assert(false && "case not handled");
    }
  case NUM_KIND_BOOL:
    return {BoolParam::get(context, imm.v_bool!=0), BoolType::get(context, 0)};
  case CONST_KIND_STRING:
    switch (imm.string_kind) {
      case STRING_KIND_STRING:
        return {StringParam::get(context, imm.v_string),
                StringType::get(context)};
      case STRING_KIND_BYTES:
        return {StringParam::get(context, imm.v_string),
                BytesType::get(context)};
      case STRING_KIND_C_STRING:
        return {StringParam::get(context, imm.v_string),
                CStringType::get(context)};
      default:
        assert(false && "case not handled");
      }
  case NUM_KIND_REAL:
    switch (imm.num_index) {
      case FLOAT_SIZE_32:
        return {RealParam::get(context, imm.v_float32),
                RealType::get(context, 32)};
      case FLOAT_SIZE_64:
        return {RealParam::get(context, imm.v_float64),
                RealType::get(context, 64)};
      default:
        assert(false && "case not handled");
    }
  case NUM_KIND_IMAG:
    switch (imm.num_index) {
      case FLOAT_SIZE_32:
        return {RealParam::get(context, imm.v_float32),
                ImagType::get(context, 32)};
      case FLOAT_SIZE_64:
        return {RealParam::get(context, imm.v_float64),
                ImagType::get(context, 64)};
      default:
        assert(false && "case not handled");
    }
  case NUM_KIND_COMPLEX:
    switch (imm.num_index) {
      case COMPLEX_SIZE_64:
        return {ComplexParam::get(context,
                                  Param::ComplexDouble(imm.v_complex64.r,
                                                       imm.v_complex64.i)),
                ComplexType::get(context, 64)};
      case COMPLEX_SIZE_128:
        return {ComplexParam::get(context,
                                  Param::ComplexDouble(imm.v_complex128.r,
                                                       imm.v_complex128.i)),
                ComplexType::get(context, 128)};
      default:
        assert(false && "case not handled");
    }
  default:
    assert(false && "case not handled");
  }
  return {nullptr, nullptr};
}

QualifiedType Param::fold(Context* context,
                          UniqueString op,
                          QualifiedType a,
                          QualifiedType b) {
  assert(a.hasType() && a.hasParam());
  assert(b.hasType() && b.hasParam());

  // convert Param to Immediate
  Immediate aImm = paramToImmediate(a.param(), a.type());
  Immediate bImm = paramToImmediate(b.param(), b.type());
  Immediate result;

  // fold
  int immOp = 0;
#define USTR(s) UniqueString::build(context, s)

  if      (op == USTR("**")) immOp = P_prim_pow;
  else if (op == USTR("*"))  immOp = P_prim_mult;
  else if (op == USTR("/"))  immOp = P_prim_div;
  else if (op == USTR("%"))  immOp = P_prim_mod;
  else if (op == USTR("+"))  immOp = P_prim_add;
  else if (op == USTR("-"))  immOp = P_prim_subtract;
  else if (op == USTR("<<")) immOp = P_prim_lsh;
  else if (op == USTR(">>")) immOp = P_prim_rsh;
  else if (op == USTR("<"))  immOp = P_prim_less;
  else if (op == USTR("<=")) immOp = P_prim_lessorequal;
  else if (op == USTR(">"))  immOp = P_prim_greater;
  else if (op == USTR(">=")) immOp = P_prim_greaterorequal;
  else if (op == USTR("==")) immOp = P_prim_equal;
  else if (op == USTR("!=")) immOp = P_prim_notequal;
  else if (op == USTR("&"))  immOp = P_prim_and;
  else if (op == USTR("^"))  immOp = P_prim_xor;
  else if (op == USTR("|"))  immOp = P_prim_or;
  else if (op == USTR("&&")) immOp = P_prim_land;
  else if (op == USTR("||")) immOp = P_prim_lor;
  else if (op == USTR("u+")) immOp = P_prim_plus;
  else if (op == USTR("u-")) immOp = P_prim_minus;
  else if (op == USTR("~"))  immOp = P_prim_not;
  else if (op == USTR("!"))  immOp = P_prim_lnot;
  else assert(false && "case not handled");

  fold_constant(context, immOp, &aImm, &bImm, &result);

  // convert from Immediate
  std::pair<const Param*, const Type*> pair = immediateToParam(context, result);
  return QualifiedType(QualifiedType::PARAM, pair.second, pair.first);
}

std::string Param::toString() const {
  std::string ret;

  switch (tag_) {
#define PARAM_NODE(NAME, VALTYPE) \
    case paramtags::NAME: { \
      const NAME* casted = (const NAME*) this; \
      auto value = casted->value(); \
      ret += Param::valueToString(value); \
      break; \
    }
// Apply the above macros to ParamClassesList.h
#include "chpl/types/ParamClassesList.h"
// clear the macros
#undef PARAM_NODE
  }

  return ret;
}

// implement the subclasses using macros and ParamClassesList.h
#define PARAM_NODE(NAME, VALTYPE) \
  const owned<NAME>& NAME::get##NAME(Context* context, VALTYPE value) { \
    QUERY_BEGIN(get##NAME, context, value); \
    auto result = toOwned(new NAME(value)); \
    return QUERY_END(result); \
  }

// Apply the above macros to ParamClassesList.h
#include "chpl/types/ParamClassesList.h"

// clear the macros
#undef PARAM_NODE


} // end namespace types
} // end namespace chpl
