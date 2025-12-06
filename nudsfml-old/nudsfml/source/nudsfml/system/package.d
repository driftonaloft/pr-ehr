module nudsfml.system;

public import nudsfml.system.clock;
public import nudsfml.system.config;
public import nudsfml.system.err;
public import nudsfml.system.inputstream;
public import nudsfml.system.lock;
public import nudsfml.system.mutex;
public import nudsfml.system.sleep;
public import nudsfml.system.thread;
public import nudsfml.system.time;
public import nudsfml.system.vector2;
public import nudsfml.system.vector3;

import bindbc.sfml;

static this() {
	if(!loadSFML()){
        import std.stdio;
		writeln("failed to load sfml");
	}
}