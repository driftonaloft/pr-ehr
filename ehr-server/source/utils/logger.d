module utils.logger;

import std.stdio;
import std.file;
import std.format;

class Logger {
    string filename_;
    File f;

    this (string filename = "app.log"){
        setFile(filename);

    }

    void opCall(A...)(A a){
        this.writeln(a);
    }

    void setFile(string filename){
        filename_ = filename;
        if(f.isOpen()){
            f.close();
        }
        f.open(filename,"w");
    }

    void write(A...)(A a){
        import std.datetime;

        string stime = format("[%-23s] ",Clock.currTime.toISOString());
        std.stdio.write(stime, a);
        f.write(stime, a);

    }

    void writeln(A...)(A a){
        import std.datetime;

        string stime = format("[%-23s] ",Clock.currTime.toISOString());
        std.stdio.writeln(stime, a);
        f.writeln(stime, a);
    }
}