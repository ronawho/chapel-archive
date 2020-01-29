import time
import zmq
from  multiprocessing import Process
import os
import sys
import datetime

sys.path.insert(0, 'lib')
import chpl_send_msg

def mydate():
    date = datetime.datetime.utcnow()
    return f'{date.minute}:{date.second:02}'

def send():
    print("SEND() PYTHON: calling chpl func")
    chpl_send_msg.sendMsg()

def recv():
    context = zmq.Context()
    rep_socket = context.socket(zmq.REP)
    rep_socket.bind("tcp://*:5558")
    print(mydate(), " RECV(): in recv()", flush=True)
    for num_msg in range(2):
        message = rep_socket.recv_string()
        print(mydate(), ' RECV(): recv msg: ', message, flush=True)
        rep_socket.send_string(message)

chpl_send_msg.chpl_setup()

Process(target=recv).start()

send()
