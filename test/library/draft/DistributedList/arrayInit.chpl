use DistributedList;

var a = [i in 0..<10000] i;
var dl = new distributedList(a);
var a_ = dl.toArray();

writeln(&& reduce (a_ == a));
