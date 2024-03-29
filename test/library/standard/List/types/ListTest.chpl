import List.list;

proc testList(type t) where isTuple(t) {
  var l = new list(t);
  var x = (new t[0](1), new t[1](2));

  l.pushBack(x);
  assert(l.size == 1);

  var value = l.popBack();
  assert(l.size == 0);
}

proc testList(type t) where isBorrowedClass(t) {
  var l = new list(t);

  // create values with 'owned' if t is a borrowed class type
  // (the list will still store borrowed)
  type useT = (t:owned);

  var x: useT = new useT(1);

  l.pushBack(x.borrow());
  assert(l.size == 1);

  var value = l.popBack();
  assert(l.size == 0);
}

proc testList(type t) {
  var l = new list(t);

  var x: t = new t(1);

  l.pushBack(x);
  assert(l.size == 1);

  var value = l.popBack();
  assert(l.size == 0);

  if isUnmanagedClass(t) {
    delete x;
  }

}
