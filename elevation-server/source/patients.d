module patients;

import vibe.vibe;

import vibe.db.mongo.mongo;
import vibe.data.serialization : name;
import vibe.data.bson;

import database;

import appointment;

struct EditInfo  {
    string user;
    string date;
    string time;
    string [string]  fieldsOriginal;
    string [string]  fieldsNew;
}

struct PatientInfo {
    @optional { // optional for json/bson serialization
        @name("_id") BsonObjectID id; //requiered for mongoDB
        string nameWhole;
        string nameFirst;
        string nameMiddle;
        string nameLast;
        string namePrefix;
        string dateOfBirth; //should be a date-time

        string createdby;
        string [] editedby;

        string identificationNumber; //ssn idn sin ect...

        string address;
        string city;
        string state;
        string zip;
        string country;
        
        string primary_contact;
        string [string] contacts;
    }

    //TODO: add these fields in the future
    //InsuranceInfo[] insurance;
    //RefererInfo[] referers;
    
    //FormDataRef[string] form;
    //Apointment[DATETIME] apointmentrefs;
    //AttachmentRef[string] attachmentrefs;
    //Billing[] billingsre; 
    //Payment[] paymentsref;
    //Note[] notesref;
}


class Patient {
    PatientInfo info;

    Database db;
    this(Database db_) {
        db = db_;
    }
}

class PatientManager {
    Database db;

    this(Database db_) {
        db = db_;
    }

    Patient getPatient(string nameFirst, string nameLast) {
        foreach(info ; db.patients.find!PatientInfo(["nameFirst": nameFirst,"nameLast": nameLast])) {
            auto p = new Patient(db);
            p.info = info;
            return p;
        }
        return null;
    }

    Patient createPatient(PatientInfo info){
        info.id = BsonObjectID.generate();

        db.patients.insertOne(info); 

        auto p = new Patient(db);
        p.info = info;

        return p;
    }

    void updatePatient(PatientInfo info) {
        db.patients.updateOne(["_id": info.id], info);
    }

}