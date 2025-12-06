import std.stdio;
import std.format;

import game : Game;

import bindbc.sfml;

import nudsfml.graphics;
import nudsfml.window;
import nudsfml.system;

//handle loading and setting up configurations for the application

void main(){


	Game game  = new Game();
	game.startup();
	game.run();
	game.shutdown();
}

