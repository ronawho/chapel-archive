use UnorderedAtomics;
use Time;

// Test single-threaded performance or ordered and unordered atomics.

config const iters = 50000;
config const printStats = true;

proc test(useUnordered) {
  var a: atomic int;
  a.write(1);
  on Locales[numLocales-1] {
    var t: Timer; t.start();
    if useUnordered {
      for 1..iters do a.unorderedWrite(1);
      unorderedAtomicTaskFence();
    } else {
      for 1..iters do a.write(1);
    }
    t.stop();
    if printStats {
      const ordering = if useUnordered then "Unordered " else "  Ordered ";
      const time = "time(sec): " + t.elapsed();
      const rate = "rate(mOps/sec): " + (iters / t.elapsed()) / 1e6;
      //writeln(ordering + time);
      writeln(ordering + rate + " " + time);
    }
  }
  assert(a.read() == 1);
}

test(false);
test(true);
