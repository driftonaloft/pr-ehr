module server;

import vibe.core.core;
import vibe.vibe;

import network.client;
import database;
import user;

import command.processor;
import patients;

///class holding the application data for the server
class Server {
    ClientManager manager;
    UserManager userManager;
    PatientManager patientManager;
    CommandProcessor cmdProc;

    Database db;

    this() {
        db = new Database(); // pass db conntion address?
        manager = new ClientManager();

        userManager = new UserManager(db);
        cmdProc = new CommandProcessor(this);
    }

    void startup() {
        logInfo("Server started");
        userManager.startup();
        cmdProc.startup();
    }

    int run(string[] args){
        auto listeners = listenTCP(5891,(TCPConnection conn) @safe nothrow {
            logInfo("new connection from: ", conn.peerAddress);
            try {
                auto client = new Client(conn, this);

                manager.registerClient(client);
                client.start();
            } catch (Exception e) {
                logError("Error in client: ", e.msg);
            }
        });
        scope(exit){
            shutdown(listeners);
        }

        return runApplication(&args);
    }

    void shutdown(TCPListener[] listeners) {
        foreach(ear; listeners){
            ear.stopListening();
        }
        manager.shutdown();
        db.cleanup();
    }
}


//TODO:
//usermanagement
//patient managment
//ehr
//  form creation editing / updating / datamapping across versions
//  narritive creations and storing
//attachments
//  compression model 
//note generation
//calander / schedualing module
//  subscribers for data update requests
//cryptographics / security verifications
//website status indicator
//maintinence 
//  hotserver reload of sockets // socket transfer
//  backups
//  integrety checks
//reports
//
//inventory managment
//billing
//automated tasklist generation for visits
//patient tracker 2.0


