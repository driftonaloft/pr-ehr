module command.patientcmd;

import server;
import network.client;

import std.stdio;
import std.format;

import patients;

import vibe.vibe;

int patientCmd (Server server, Client client, string[] tokens){
    if (tokens.length > 1){
        string commandToken = tokens[1];
        switch(commandToken){
            case "list":    
                return patientList(server, client, tokens);
            case "create":
                return patientCreate(server, client, tokens);
                //break;
            case "remove":
                break;
            case "update":

                break;
            default:
                logInfo("Invalid patient command: %s", commandToken); 
                break;  
        }
    }
    return 0;
}

int patientList (Server server, Client client, string[] tokens){
    auto cursor = server.db.patients.find();
    client.sendln("Patients:");
    foreach(patient; cursor){
        client.sendln(format("\tPatient: %s %s - %s", patient["nameFirst"], patient["nameLast"], patient["dateOfBirth"]));
    }
    return 0;
}


/*
@patient create { "nameFirst":"Tristan", "nameLast":"Daniel", "dateOfBirth":"13-12-1985" }
*/

int patientCreate (Server server, Client client, string[] tokens){
    import std.string;

    if (tokens.length > 2){
        string patientInfoJson = tokens[2 .. $].join(" ");
        auto info = parseJsonString(patientInfoJson).deserializeJson!PatientInfo();
        info.id = BsonObjectID.generate();
    
        //TODO: run a search to see if patient info matches any other patients before creation
        // if search matches preset matches
        // else create the new patients
        logInfo("Creating patient: %s %s - %s", info.nameFirst, info.nameLast, info.dateOfBirth);
        client.sendln(format("created oatient : %s %s - %s",info.nameFirst, info.nameLast, info.dateOfBirth ));
``
        auto p = server.patientManager.createPatient(info);
        if(p is null){
            return 0;
        }
        return 1;
    }
    return 0;
}

int patientSearch(Server server, Client client, string[] tokens){

}