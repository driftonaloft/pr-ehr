module command.systemcmd;

import server;
import network.client;

import vibe.vibe;

int quit(Server server, Client client, string[] tokens){
    if(tokens.length == 1){
        if(tokens[0] == "@quit"){
            logInfo("client: %s wants to quit", client.id);
            client.state = client.state.quit;
        }
    }
    return 0;
}

int shutdown(Server server, Client client, string[] tokens){
    if(client.user.permissions("admin")){
        server.manager.sendAll("server shutting down");
        exitEventLoop(true);
    }
    return 0;
}

int ping(Server server, Client client, string[] tokens){
    if(tokens.length == 2){
        client.sendln("pong " ~ tokens[1]);
    }
    return 0;
}
