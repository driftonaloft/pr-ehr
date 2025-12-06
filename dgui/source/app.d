import std.stdio;
import std.format;
import std.string;
import std.array;
import core.memory;

import nudsfml.graphics;
import nudsfml.system;

import gui;
import util.color;

import scene;
import logon;
import formeditor;
import testing;
import logon;

class Application{
	RenderWindow win;
	Gui guisystem;
	Clock frameTime;
	bool running = true;
	string selection = "";
	string mode = "edit";
	Text text;


	SceneManager sceneManager;

	this(){
		win = new RenderWindow(VideoMode(1280, 1024),"Elevation EHR - Testing");
		win.setFramerateLimit(60);

		guisystem = new Gui(win);
		guisystem.initialize();

		frameTime = new Clock();

		text = new Text("",guisystem.fonts["default"],10);
		text.position = Vector2f(win.size.x - 200, 0);

		sceneManager = new SceneManager(this);

		Logon logon = new Logon(this);
		sceneManager.registerScene("logon",logon);

		FormEditor editor = new FormEditor(this);
		sceneManager.registerScene("editor",editor);

		Testing testing = new Testing(this);
		sceneManager.registerScene("testing",testing);

		sceneManager.switchScene("logon");
	}


	void run(){
		while (running){
			float dt = frameTime.restart().asSeconds();
			draw();
			float drawTime = frameTime.getElapsedTime().asSeconds();
			events();
			float eventTime = frameTime.getElapsedTime().asSeconds();
			update(dt);
			float updateTime = frameTime.getElapsedTime().asSeconds() - eventTime;


			//writeln(format("dt: %8f et: %8f drawt: %8f", dt, eventTime, updateTime));
		}
	}

	void events(){
		Event e;
		int eventCount = 0;

		/*
		while(win.pollEvent(e)){
			eventCount ++;
			handleEvnets(e);
			guisystem.handleEvent(e);
		}
		*/

		win.waitEvent(e);
		eventCount ++;
		handleEvnets(e);
		guisystem.handleEvent(e);

		while(win.pollEvent(e)){
			eventCount ++;
			handleEvnets(e);
			guisystem.handleEvent(e);
		}
	}

	void handleEvnets(Event e){
		switch (e.type) {
			case Event.Type.KeyPressed : {
				if(e.key.code == Keyboard.Key.Escape){
					win.close();
					running = false;
				}
				if(e.key.control){
					if(e.key.code == Keyboard.Key.R){
						//perfdisp.reset();
					}
					if(e.key.code == Keyboard.Key.Tilde){
						//toggle DebugConsole
					}
					if(e.key.code == Keyboard.Key.M){
						ulong used = GC.stats.usedSize / 1024;
						ulong free = GC.stats.usedSize / 1024;
						ulong total = GC.stats.allocatedInCurrentThread / 1024;
						version(DEBUG_TEXT){writefln("used: %dkb, free: %dkb, total: %dkb", used, free, total);}
					}
					if(e.key.code == Keyboard.Key.F12){
						auto screenshot = win.capture();
						writeln("saving screenshot");
						screenshot.saveToFile("screenshot.png");
						writeln("done");
					}
				}
			} break;
			case Event.Type.Resized:
				sceneManager.resize(Vector2i(win.size.x, win.size.y));
				break;
			default: 
		}
	}

	void update(float dt){
		guisystem.update(dt);
		sceneManager.update(dt);
	}


	void draw() {
		win.clear();
		guisystem.draw();
		win.draw(sceneManager);
		win.draw(text);

		//perfdisp.draw(win);

		win.display();
	}

	bool logon(string name, string password){
		return true;
	}

}

void main(string [] args) {
	writeln("DGui test app");
	writeln("args - ", args);

	Application app = new Application();
	app.run();
}
