use IO.FormattedIO;
use ZMQ;
use Time;
use DateTime;

proc mydate() {
  var date = datetime.utcnow();
  return '%02i:%02i'.format(date.minute, date.second);
}

export proc sendMsg() {
  writeln("CHPL: in sendMsg");
  var context: Context;
  var socket = context.socket(ZMQ.REQ);
  socket.connect("tcp://localhost:5558");

  writeln("SEND() CHPL: sending msg1");
  socket.send("hello");
  var message = socket.recv(string);
  writeln(mydate(), " received message: ", message);

  sleep(5);

  writeln("SEND() CHPL: sending msg2");
  socket.send("world");
  message = socket.recv(string);
  writeln(mydate(), " received message: ", message);
}
