#----------------------------------------------------------------------------
# MIT License
# 
# Copyright (c) 2018 Gabriel Capella
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
#----------------------------------------------------------------------------
#
# This source code is part of my final undergraduate thesis.
# For any suggestion, doubt or comment send an email to
# gabriel@capella.pro
#
#----------------------------------------------------------------------------
import socketserver
import hashlib
import os

# [CMD, ADDR, SIZE, NOUCE]
# bytes [1, 2, 2, 256, 256]

# Server send request to device, where:
#  - CMD: the command to be executed
#  - ADDR: initial memory position address
#  - SIZE: bytes to hash
#  - NOUCE: nounce
#

############ COMMANDS ############
TAKE_HASH       = 0x10
SET_LED_ON      = 0x20
SET_LED_OFF     = 0x21
SET_RESET       = 0x30
GET_RESET_HASH  = 0x31

############ DEVICE KEY ############
device_key = [
    42, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 
    42, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 
    42, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 
    42, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68,
    42, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 
    42, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 
    42, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 
    42, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68
]

MEMORY_FILE = "../../SMART/synthesis/xilinx/WORK/smart_app.mem"
LED_ADDR = 0x00;
MEMORY = []

def calculate_hash_pmem (addr, size, nounce):
    addr = addr-0xe000
    data = MEMORY[addr:addr+size]
    return calculate_hash(data, addr, nounce)

def calculate_hash (data, addr, nounce):
    key = []
    for i in range(len(device_key)):
        key.append(0)
        key[i] = device_key[len(device_key)-i-1].to_bytes(4, byteorder='big')

    key = b''.join(key)
    array = key+nounce
    array = array+data+int(addr).to_bytes(4, byteorder='big')

    return hashlib.sha256(array).digest()

class MyTCPHandler(socketserver.StreamRequestHandler):
    def handle(self):
        print("New client.")
        # self.request is the TCP socket connected to the client
        while True:
            # VERIFY DEVICE
            nounce = self.send_command(TAKE_HASH, 0x0, 0x0)
            auth = self.rfile.readline().strip()

            expected = calculate_hash(bytes(), 0x0, nounce)
            if (auth.decode() != expected.hex()):
                print("Device is not trust...")
                return
            print("Correct device.")

            # TURN LED ON
            self.send_command(SET_LED_ON, LED_ADDR, 0x01)
            self.rfile.readline().strip() # ignore response

            # VERIFY LED ON STATUS
            for i in xrange(0,10):
                nounce = self.send_command(TAKE_HASH, LED_ADDR, 0x01)
                auth = self.rfile.readline().strip()
                expected = calculate_hash(bytes([1]), LED_ADDR, nounce)
                if (auth.decode() != expected.hex()):
                    print("Incorrect led value!!!")

            # TURN LED OFF
            self.send_command(SET_LED_OFF, LED_ADDR, 0x01)
            self.rfile.readline().strip() # ignore response

            # VERIFY LED OFF STATUS
            for i in xrange(0,10):
                nounce = self.send_command(TAKE_HASH, LED_ADDR, 0x01)
                auth = self.rfile.readline().strip()
                expected = calculate_hash(bytes([1]), LED_ADDR, nounce)
                if (auth.decode() != expected.hex()):
                    print("Incorrect led value!!!")


            # VERIFY FULL PROGRAM MEMORY
            nounce = self.send_command(TAKE_HASH, 0xe000, 2**13)
            auth = self.rfile.readline().strip()
            expected = calculate_hash_pmem(0xe000, 2**13, nounce)
            if (auth.decode() != expected.hex()):
                print("Device code has changed.")
            else:
                print("Device successfully device code check.")

            # SEND RESET COMMAND
            self.send_command(SET_LED_ON, LED_ADDR, 0x0, 0x0)
            self.rfile.readline().strip() # ignore response

            # VERIFY SECURELY RESET
            nounce = self.send_command(TAKE_HASH, 0x0, 0x0)
            auth = self.rfile.readline().strip()
            expected = calculate_hash(bytes(), 0x0, nounce)
            if (auth.decode() != expected.hex()):
                print("Device did not made a reset.")
            else:
                print("Device successfully reset.")

    def send_command(self, cmd, addr, size):
        cmd = int(cmd).to_bytes(1, byteorder="big", signed=False)
        addr = int(addr).to_bytes(2, byteorder="big", signed=False)
        size = int(size).to_bytes(2, byteorder="big", signed=False)
        nounce = os.urandom(256)

        final = cmd+addr+size+nounce

        print(final.hex());
        self.wfile.write(final)
        return nounce

if __name__ == "__main__":
    HOST, PORT = "0.0.0.0", 3000

    with open(MEMORY_FILE, 'r') as f:
        data = f.read().split('\n')
        data = [value.strip() for value in data if value != '']
        data = [int(value, 16).to_bytes(2, byteorder="little", signed=False) for value in data]
        data = b''.join(data)
        MEMORY = data
        
        # nounce = [0x23001120] * 64
        # for i in range(len(nounce)):
        #     nounce[i] = nounce[i].to_bytes(4, byteorder='big')
        # print(calculate_hash_pmem(0xe005, 89, nounce))

        # Create the server, binding to localhost on port 9999
        with socketserver.TCPServer((HOST, PORT), MyTCPHandler) as server:
            # Activate the server; this will keep running until you
            # interrupt the program with Ctrl-C
            server.serve_forever()
