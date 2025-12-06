module client;

import std.socket;
import std.conv;

import ehr : Ehr;

import command;

import cryptogrophy;

enum ClientState {
    GetID,
    Diffie_Hellman, 
    ExchangeKeys,
    Authenticate, 
    Connected, 
    Dead
};

class Client {
    string clientID;
    string clientType;
    string userid;
    Socket s;
    Ehr ehr; 
    Cryptogrophy crypto;

    ClientState state; 
    string input;


    size_t totalReceivedBytes;
    size_t totalSentBytes;

    string outBuffer;

    Command [] cmdList;

    this(Ehr ehr_) {
        crypto = new Cryptogrophy(ehr.log);
        ehr = ehr_; 
        state = ClientState.GetID;
    }

    size_t recv(){
        ubyte [1024*8] buffer; 
        size_t receivedBytes = s.receive(buffer);


        if(receivedBytes == 0) {
            state = ClientState.Dead;
            return 0;
        }

        if(!processBuffer(buffer.to!string)){

        }

        totalReceivedBytes += receivedBytes;
        return receivedBytes;
    }

    size_t send(Command cmd) {
        string buffer = cmd.toBuffer;

        return 0;
    }

    bool processBuffer(string buffer) {
        import std.string;
        if(buffer.strip == "halt" ) {
            ehr.running = false;
        }

        cmdList =  buildCommandList();
        return true;
    }

    Command [] buildCommandList() { // Command [] command list
        Command [] cmdList;

        return cmdList;
    }

    void update(){
        if(cmdList.length > 0){

        }
        
    }
}
