module network.client;

import std.socket;
import std.datetime;
import std.stdio;

class Client {
    string serverURL;
    string sessionID;
    Socket s;

    shared ubyte[] inbuffer;
    shared ubyte[] outbuffer; //
    shared ulong bytesReady;
    string[] lines;

    enum State{
        validate,
        login,
        connected,
        close
    }

    bool dataReady;

    this(){}

    void update(){
        SocketSet sockets;
        sockets.add(s);
        Socket.select(sockets, null, null, dur!"msecs"(20));

        if(sockets.isSet(s)){
            ubyte[4096] buffer;
            ulong bytes = s.receive(buffer);
            if(bytes == 0){
                writeln("disconnected");
                return;
            }
            inbuffer ~= buffer[0 .. bytes];
        }
    }

    void sendln(string message){
        send(message ~ "\n\r");
    }
    void send(string message){

    }
    string readln(){
        import std.algorithm.mutation;
        string line;
        if(lines.length > 0 ){
            line = lines[0];
            lines = lines.remove(0);
        }
        return line;
    }
}

class ClientManager {
    Client[] clients;
}