import std.stdio;

import vibe.core.core;
import vibe.core.log : logError, logInfo;
import vibe.core.net : TCPConnection, listenTCP;
import vibe.stream.operations : readLine;

import core.time;
import std.conv;

TCPConnection[] clients;

void registerClient(TCPConnection client){
    clients ~= client;
}

void sendAll(TCPConnection conn, string data){
    foreach(client ; clients){
        if(conn.fd != client.fd){
            client.write(data);
        }
    }
}

int main(string [] args) {
    string serverVersion = "0.0.1";

	writeln("Starting Elevation Server - ", serverVersion);

    auto listener = listenTCP(5891, (conn){
        logInfo("new Connection: ",conn.peerAddress );
        registerClient(conn);

        sendAll(conn, "new Connection\r\n");
        conn.write("new Connection\r\n");

        try {
            while(!conn.empty){
                auto line = cast(const(char)[])conn.readLine();
                if(line == "quit"){
                    logInfo("Client wants to Quit.");
                    break;
                } else {
                    logInfo("Got Line: %s", line);
                    sendAll(conn, line.to!string ~ "\r\n");
                }
            }
        } catch (Exception e){
            logError("failed to read from client: %s", e.msg);
        }

        conn.close();
    });

    return runApplication(&args);
}
