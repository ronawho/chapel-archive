use Time;

config const numTrials = 100;
config const printTimings = false;

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

extern proc skip_fma(b: bool);
proc coforallOnTaskSpawn(trials) {
  //skipEndCountAll(true);
  skipEndCount=true;
  skip_fma(true);

  for 1..numTrials do
    coforall locid in 1..numLocales-1 do on Locales[locid] {}

  skip_fma(false);
  skipEndCount=false;
  //skipEndCountAll(false);
}

