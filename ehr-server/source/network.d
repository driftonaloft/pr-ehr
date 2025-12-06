module network;

import std.socket;
import std.algorithm;


import ehr: Ehr; 

import client : Client , ClientState;

class Network {
    Socket s;
    Client [] clients;

    Ehr ehr;

    this(Ehr ehr_){
        ehr = ehr_;
    }

    void startup(ushort port){
        s = new TcpSocket;
        s.blocking = false;
        s.setOption(SocketOptionLevel.SOCKET, SocketOption.REUSEADDR , 1);
        s.bind(new InternetAddress(port));
        s.listen(5);
        ehr.log("network - listening on port: ",port);
    }

    void update(){
        auto ss = buildSocketSet(); //possible optimization to declare set at beginning and use reset needs testing
        Socket.select(ss, null, null); 
        if(ss.isSet(s)){
            newClient();
        }

        foreach(client ; clients){
            if(ss.isSet(client.s)) {
                if(!client.recv()){
                    ehr.log("    client - socket disconnected");
                    continue;
                }
            }
            client.update();
        }

        clients = clients.remove!(c => c.state == ClientState.Dead);
    }

    void shutdown(){
        ehr.log("network - shutting down");
        foreach(client; clients){
            client.s.shutdown(SocketShutdown.BOTH);
            client.s.close();
            ehr.log("    client - disconnected : ", client.userid);

        }
        s.shutdown(SocketShutdown.BOTH);
        s.close();
    }

    void newClient(){
        Client client = new Client(ehr);
        client.s = s.accept();
        clients ~= client;    
        ehr.log("    client - new connection");
    }

    SocketSet buildSocketSet(){
       SocketSet ss = new SocketSet;
        ss.add(s);
        foreach(c ; clients){
            ss.add(c.s);
        }
        return ss;
    }

}