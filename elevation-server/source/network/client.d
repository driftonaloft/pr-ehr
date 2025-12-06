module network.client;

import vibe.core.net;
import vibe.vibe;

import user;
import server : Server;

class Client {
    string id;
    TCPConnection conn;
    ClientManager manager;
    UserManager userManager;
    User user;

    ulong bytesSent;
    long attempt;
    Server server;

    enum State {
        validate,
        login,
        connected,
        quit
    }
    State state;

    this (TCPConnection conn_, Server server_)@trusted {
        conn = conn_;
        server = server_;
        manager = server.manager;
        userManager = server.userManager;
        this.send("validate:");
    }

    void send(string data){
        import eventcore.driver;
        try {
            bytesSent += conn.write(cast(ubyte[])data, IOMode.all);
        } catch (Exception e){
            logError("error writing client: %s - %s", id , e.msg);
        }
    }

    void sendln(string data){
        this.send(data ~ "\n\r");
    }

    void processInput(string line) {
        switch(state){
            case State.validate:
                validate(line);
                break;
            case State.login:
                login(line);
                break;
            case State.connected:
                connected(line);
                break;
            case State.quit:
                break;
            default:
                break;
        }
    }

    void validate(string line){
        if(line == "validate"){
            sendln("please enter your username and password <username>:<password>");
            send("login:> ");
            state = State.login;
        } else {
            sendln("please validate first");
        }
    }

    void login(string line){
        auto parts = line.split(":");
        if(parts.length != 2){
            sendln("bad username passoword format, expected <username>:<password>");
            return;
        }
        user = userManager.getUserClient(parts[0], parts[1]);
        if(user is null){
            sendln("incorrect username or password");
            attempt++;
            return;
        }

        sendln("you are now logged in");
        send(":> ");
        state = State.connected;
    }

    void connected(string line) {
        if(user is null){
            sendln("An Error Occured -> Disconnecting");
            logError("user is null in connected");
            state = State.quit;
            return;
        }
        server.cmdProc.parse(this, line);
        send(":> ");
    }

    void start() @trusted{
        import std.conv;
        try {
            while(!conn.empty) {
                auto line = cast(const(char)[])conn.readLine();
                processInput(line.to!string);
                if(state == state.quit){
                    break;
                }
            }
        } catch (Exception e) {
            logError("failed to read from client: %s", e.msg);
        }
        manager.closeClient(this);
    }

    void close(){
        conn.flush();
        conn.close();
    }
}

class ClientManager {
    Client [] clients;
    ulong nextClientID = 0;

    this(){}

    ///registerClients
    ///Params
    ///  client - requireds a valid 
    void registerClient(Client client) @trusted {
        if(client !is null){
            client.id = nextClientID.to!string;
            nextClientID++;
            clients ~= client;
        }
    }

    void closeClient(Client client) {
        import std.algorithm.mutation;
        if(client !is null){
            clients = clients.remove!(a => a.id == client.id);
            client.close();
        }
    }

    void shutdown() {
        foreach(ref client; clients){
            client.close();
        }
    }

    void sendAll(string message) {
        foreach(ref client; clients){
            client.sendln(message);
        }
    }

    Client getClient(string id) {
        foreach(ref client ; clients){
            if(client.id == id){
                return client;
            }
        }
        return null;
    }
}
