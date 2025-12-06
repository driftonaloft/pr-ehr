module database;

import vibe.vibe;

import user;

class Database {
    MongoClient client;
    MongoDatabase mongodb;
    MongoCollection users;
    MongoCollection inventory;
    MongoCollection patients;
    MongoCollection formTemplates;
    MongoCollection notesTemplates;
    MongoCollection forms;
    MongoCollection notes;
    MongoCollection attachments;
    MongoCollection appointments;

    this(string connectionString_ = "mongodb://truenas.local:27017"){
    //this(string connectionString_ = "mongodb://root:d34dz0n3@localhost:27017"){
        try {
            client = connectMongoDB(connectionString_);
            logInfo("Connected to Database: %s", connectionString_);
            mongodb = client.getDatabase("testing");

            users = mongodb["users"];
            patients = mongodb["patients"];
            attachments = mongodb["attachments"];
        } catch (Exception e) {
            logError("Error MongoDB: %s", e.msg);
        }
    }

    ~this(){
        client.cleanupConnections();
    }

    void cleanup(){
        client.cleanupConnections();
    }
}