use Time;

config const numTrials = 500000;
config const printTimings = true;
config const verify = false;

enum TaskingMode {
  coforallOnT
};
use TaskingMode;

config param taskingMode = coforallOnT;

proc main() {
  var t: Timer;

  t.start();
  select taskingMode {
     when coforallOnT do coforallOnTaskSpawn(numTrials);
  }
  t.stop();

  if printTimings {
    writeln("Elapsed time: ", t.elapsed());
  }
}



proc skipEndCountAll(val: bool) {
  skipEndCount = val;
  coforall loc in Locales do on loc {
    skipEndCount = val;
  }
}

pragma "locale private" var counter = 0;
inline proc incCounter() { counter += 1; }
inline proc getCounter() { return counter; }
var counters:[1..numLocales-1] int;

config const noEndCount = false;
config const skipFmaLevel = 0;

extern proc skip_fma(val: c_int);
proc coforallOnTaskSpawn(trials) {
  if skipFmaLevel {
    skipEndCount=true;
    skip_fma(skipFmaLevel:c_int);
  } else if noEndCount {
    skipEndCountAll(true);
  }

  for 1..numTrials do
    coforall locid in 1..numLocales-1 do on Locales[locid] { incCounter(); }

  if skipFmaLevel {
    skip_fma(0);
    skipEndCount=false;
  } else if noEndCount {
    skipEndCountAll(false);
  }

  coforall locid in 1..numLocales-1 do on Locales[locid] do
    counters[locid] = getCounter();
  if verify then
    assert(+reduce counters == numLocales-1*numTrials);
  writeln(counters);
}

