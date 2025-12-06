module command;

enum Commands : long {
    NOP,
    AUTHENTICATE,
    LOGON,
    CREATE_FORM_TEMPLATE,
    CREATE_SECTION_TEMPLATE,
    ADD_SECTION_FORM_TEMPLATE,
}

string [Commands] commandList;

static this() {
    commandList[Commands.NOP] = "NOP";
    commandList[Commands.AUTHENTICATE] = "AUTHENTICATE";
    commandList[Commands.LOGON] = "LOGON";
}

struct Command { //struct ? // COMMAND_ID:{ARGName: Value, ARGName:[VALUES, VALUES, ALUES]};
    string originalStatement;
    Commands cmdid;
    string[string] args;
    string[string] retargs;
    bool complete;

    string toBuffer() {
        import std.format;
        string retval;

        retval = commandList[cmdid];
        if(args.length){
            retval ~= ":{";
            foreach(key, value; args){
                retval ~= format(" %s: %s,",key, value);
            }
            if(retval[$-1] == ','){
                retval = retval[0 .. ($ - 1)];
            }
            retval ~= "};";
        }
        
        return retval;
    }

    void fromBuffer() {
        to
    }
}

unittest {
    import std.stdio;
    Command cmd;
    cmd.cmdid = Commands.NOP;
    cmd.args["Test"] = "Lets Not";
    cmd.args["Losser"] = "True";
    cmd.args["Bangles"] = "[10, 20, 30, 40]";

    string buffer = cmd.toBuffer();

    writeln(buffer);
}