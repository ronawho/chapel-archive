#include <unistd.h>
#include <zmq.h>

void sendMsgC() {

    void *context = zmq_ctx_new ();
    void *requester = zmq_socket (context, ZMQ_REQ);
    zmq_connect (requester, "tcp://localhost:5558");
    char buffer [10];

    printf ("SEND() C: sending msg1");
    zmq_send (requester, "Hello", 5, 0);
    zmq_recv (requester, buffer, 10, 0);
    printf ("RECV() C: receive msg1");
    printf ("C: sleeping for 3s");

    sleep(10);

    printf ("SEND() C: sending msg2");
    zmq_send (requester, "World", 5, 0);
    zmq_recv (requester, buffer, 10, 0);
    printf ("RECV() C: receive msg2");
}
