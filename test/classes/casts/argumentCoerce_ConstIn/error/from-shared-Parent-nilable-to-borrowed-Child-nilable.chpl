// AUTO-GENERATED: Do not edit
class A {}
class Parent {}
class Child : Parent {}
// coercing from shared Parent? to borrowed Child?
proc bar(const in x: borrowed Child?) {}
proc foo() {
  var a = new shared Parent?();
  bar(a);
}
proc main() {
  foo();
}
