module ehr;

import network;
import utils.logger;
import cryptogrophy;

class Ehr {
    Logger log;
    Network network;
    bool running = false;
    Cryptogrophy crypto;

    this() {
        log = new Logger("ehr.log");
        network = new Network(this);
        crypto = new Cryptogrophy(log);
    }

    void startup(){
        import std.file;
        log("STARTING UP EHR SERVER");
        crypto.startup("data/keys/");
        network.startup(5891);
        running = true;
    }

    void run(){
        log("EHR RUNNING");
        while(running){
            network.update();
        }
    }

    void shutdown(){
        log("SHUTTING DOWN EHR SERVER");
        network.shutdown();
    }

}