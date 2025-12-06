module command.processor;

import vibe.vibe;
import network.client : Client;
import server : Server;
import std.complex;



alias CommandDelegate = int delegate(Server server, Client client, string [] tokens);

class Command {
    string id;
    CommandDelegate cmd;

    this(string id_, CommandDelegate cmd_){
        id = id_;
        cmd = cmd_;
    }

    int execute(Server server, Client client, string [] tokens){
        if(cmd is null){
            logError("command: client %s, no command delegate - %s", client.id, id);
            return 0;
        }
        return cmd(server, client, tokens);
    }
}

class CommandProcessor {
    Command [] commands;
    Server server;

    this (Server server){
        this.server = server;
    }

    int parse(Client client, string commandString){
        string [] tokens = commandString.split(" ");
        if(tokens.length <= 0){
            logError("command: client %s, invalid command string - \"%s\"", client.id, commandString);
            return 0;
        }

        auto command = getCommand(tokens[0]);
        if(command is null){
            logError("command: client %s, command not found - %s", client.id, tokens[0]);
            return 0;
        }

        return command.execute(server, client, tokens);
    }

    void registerCommand(string id, CommandDelegate cmd){
        auto command = getCommand(id, true);
        if(command !is null){
            logError("command: command is already registered - %s", id);
            return;
        }

        command = new Command(id, cmd);
        commands ~= command;
        logInfo("command: registered command - %s", id);
    }

    Command getCommand(string token, bool perfectMatch = false){
        token = token.toLower;
        foreach(cmd; commands){
            if(cmd.id.startsWith(token)){
                if (perfectMatch){
                    if(cmd.id == token){
                        return cmd;
                    }
                } else {
                    return cmd;
                }
            }
        }
        return null;
    }

    bool startup(){
        import std.functional;
        import command.systemcmd;
        import command.usercmd;
        import command.patientcmd;

        registerCommand("@userlist",toDelegate(&userlist));
        registerCommand("@usercreate",toDelegate(&usercreate));
        registerCommand("@userpermissions", toDelegate(&userpermissions));
        
        registerCommand("@quit", toDelegate(&quit));
        registerCommand("@shutdown", toDelegate(&shutdown));
        registerCommand("@ping", toDelegate(&ping));

        registerCommand("@patient", toDelegate(&patientCmd));

        return false;
    }
}
