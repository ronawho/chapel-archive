class C { var x: int; } 


var globalValue = new borrowed C(1);
proc getGlobalHashtableElement (key: C) lifetime return globalValue {
  return globalValue;
}

proc ok1() {
  var bb: borrowed C;
  {
    var own = new owned C(2);
    var b = getGlobalHashtableElement(own.borrow());
    bb = b;
  }
  writeln(bb.x);
}
ok1();

var globalInt = 0;
proc getGlobalHashtableElementRef (const ref key: int) const ref lifetime return globalInt {
  return globalInt;
}

proc ok2 () const ref {
  var key = 0;
  return getGlobalHashtableElementRef(key);
}

proc callOk2() {
  const ref x = ok2();
  writeln(x);
}
callOk2();

proc returnOneOfThem (a: C, b: C) lifetime return b {
  return b;
}

proc ok3() {
  var bb: borrowed C;
  var outerOwn = new owned C(1);
  {
    var innerOwn = new owned C(2);
    var b = returnOneOfThem(innerOwn, outerOwn);
    bb = b;
  }
  writeln(bb.x);
}
ok3();

proc getGlobalHashtableElementGeneric (key) lifetime return globalValue {
  return globalValue;
}

proc ok4() {
  var bb: borrowed C;
  {
    var own = new owned C(2);
    var b = getGlobalHashtableElementGeneric(own.borrow());
    bb = b;
  }
  writeln(bb.x);
}
ok4();

proc returnOneOfThemGeneric (a, b) lifetime return b {
  return b;
}

proc ok5() {
  var bb: borrowed C;
  var outerOwn = new owned C(1);
  {
    var innerOwn = new owned C(2);
    var b = returnOneOfThemGeneric(innerOwn.borrow(), outerOwn.borrow());
    bb = b;
  }
  writeln(bb.x);
}
ok5();
