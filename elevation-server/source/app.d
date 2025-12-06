import std.stdio;

import server : Server;

void main(string [] args) {     
    auto server = new Server;

    server.startup();
    server.run(args);
}


