// AUTO-GENERATED: Do not edit
class A {}
class Parent {}
class Child : Parent {}
// coercing from borrowed Child to shared Parent
proc bar(const in x: shared Parent) {}
proc foo() {
  var alloc = new owned Child();
  var a:borrowed Child = alloc;
  bar(a);
}
proc main() {
  foo();
}
