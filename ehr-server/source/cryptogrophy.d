module cryptogrophy;

import crypto.rsa;

import utils.logger;

import std.stdio;
import std.file;

class Cryptogrophy {
    RSAKeyPair keypair;
    Logger log;

    this (Logger l){
        log = l;
    }

    void startup(string keydir = "data/keys/",int encryptionLevel = 1){
        log("[CHECKING KEYS]");
        if(!exists(keydir ~ "private.key") && !exists(keydir ~ "public.key")){
            log("\tGenerating Keys");
            keypair = RSA.generateKeyPair(1024*encryptionLevel);
            log("\tprivateKey: ",keypair.privateKey);
            log("\tpublicKey: ", keypair.publicKey);
            log("\t[DONE]");
            
            auto publicKey = File(keydir ~ "public.key", "w");
            publicKey.write(keypair.publicKey);
            publicKey.close();

            auto privateKey = File(keydir ~ "private.key", "w");
            privateKey.write(keypair.privateKey);
            privateKey.close();
        } else {
            keypair.publicKey  = cast(string)read(keydir ~ "public.key" );
            keypair.privateKey = cast(string)read(keydir ~ "private.key");
        }
    }

    ubyte [] encrypt(ubyte [] data){
        ubyte [] retval;
        retval = RSA.encrypt(keypair.privateKey, data);
        return retval;
    }

    ubyte [] decrypt(ubyte [] data){
        ubyte [] retval;
        retval = RSA.decrypt(keypair.publicKey, data);
        return retval;
    }
}

unittest {
    Logger log = new Logger("unitest.log");
    Cryptogrophy crypto = new Cryptogrophy(log);

    string test = "This is some text to be encrypted";

    crypto.startup();

    log("start encryption");
    ubyte [] en = crypto.encrypt(cast(ubyte[])test);
    log("end encryption");
    ubyte [] dec = crypto.decrypt(en);
    log("end decryption");

    string test2 = cast(string) dec;

    writeln(test2);
}