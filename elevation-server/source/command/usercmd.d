module command.usercmd;

import server;
import network.client;

import std.format;
import std.string;

int userlist (Server server, Client client, string[] tokens){
    client.sendln("users:");
    foreach(user; server.userManager.getUserList()){
        client.sendln(format("%s - references : %d",user.userName, user.clientCount ));
    }
    return 0;
}

int usercreate (Server server, Client client, string[] tokens){
    if(!client.user.permissions("admin")){
        client.sendln("you do not have permission to create users");
        return 0;
    }
    if(tokens.length != 3){
        client.sendln("bad format, expected @createuser <username> <password>");
        return 0;
    }
    auto tempuser = server.userManager.getUser(tokens[1]);
    if(tempuser !is null){
        client.sendln("user already exists");
        return 0;
    }
    server.userManager.createUser(tokens[1], tokens[2],["user"]);   
    return 0;
}

int userpermissions(Server server, Client client, string[] tokens){
    if(!client.user.permissions("admin")){
        client.sendln("you do not have permission to edit users permissions");
        return 0;
    }
    if(tokens.length == 4){
        auto tempuser = server.userManager.getUser(tokens[1]);
        if(tempuser is null){
            client.sendln("user does not exists");
            return 0;
        }
        if(tokens[2].startsWith("add")){
            tempuser.info.addPermissions(tokens[3].split(","));
        } else if(tokens[2].startsWith("rem")){
            tempuser.info.removePermissions(tokens[3].split(","));
        } else {
            client.sendln("unknown option: " ~ tokens[2]);
            return 0;
        }
        tempuser.updateUser();
        client.sendln("permissions updated");
        return 0;
    } else if (tokens.length == 3){
        auto tempuser = server.userManager.getUser(tokens[1]);
        if(tokens[2] == "list"){
            client.sendln(tempuser.userName);
            client.send("properties: ");
            foreach(property; tempuser.info.permissions){
                client.send(property ~ ", ");
            }
            client.send("\n\r");
        }
    } else {
        client.sendln("invalide command format:");
        client.sendln("    expect @userpermissions <user> <add/remove/list> [<peramiter list to add/remove>]");
    }
    return 0;
}