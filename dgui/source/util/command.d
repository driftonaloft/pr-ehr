module util.command;

import std.stdio;
import std.array;

string delegate(string[]) [string] commands;

string parse(string prompt){
    auto tokens = split(prompt);
    string output;
    if(tokens.length > 0){
        auto cmd = tokens[0];
        if(cmd in commands){
            output = commands[cmd](tokens);
        } else {
            output = "unknown command\n";
        }
    }
    return output ~ "done";
}

void register(string cmd, string delegate(string[]) d){
    commands[cmd] = d;
}
