// AUTO-GENERATED: Do not edit
class A {}
class Parent {}
class Child : Parent {}
// coercing from borrowed Parent to owned Child?
proc bar(in x: owned Child?) {}
proc foo() {
  var alloc = new owned Parent();
  var a:borrowed Parent = alloc;
  bar(a);
}
proc main() {
  foo();
}
