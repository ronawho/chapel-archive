record R {
  var x: int;
}

// record opts out of being copyable
proc R.init=(other: R) {
  compilerError("You can't copy an R");
}

// program tries to copy-init R
proc ret(arg) { return arg; }

proc main() {
  var r = new R(1);
  writeln(r);

  var bub = ret(r);
  writeln(r);
}
