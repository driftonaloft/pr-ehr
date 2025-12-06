module application;

import std.stdio;
import std.conv;
import std.format;

import nudsfml.graphics;

import gui;

class Application {
	bool running = false;
	RenderWindow win;
	GuiSystem dgui;

	float scale = 1.0f;
	Clock frameTime;

	float dt;

	DebugBox d;

    this() {
		win = new RenderWindow(VideoMode(1400, 1024), "DGUI Editor");
		win.setFramerateLimit(60);
		running = true;

		frameTime = new Clock();

		//load theme colors from file (or use default)
		dgui = new GuiSystem(win/*, "theme.xml"*/);

		
		auto ribbon = new Panel(dgui, Vector2f(0,0), Vector2f(win.getSize().x, 40));
		dgui.registerChild(ribbon);
		
		auto testWindow = new WindowGui(dgui,"Test Window", Vector2f(1400 - 220 ,40),Vector2f(200,600));
		dgui.registerChild(testWindow);
			auto lbl = new Label(dgui, "Label", Vector2f(10,10), Vector2f(100,20));
			auto btn =	new Button(dgui, "Button", Vector2f(10,40), Vector2f(100,25)); //also consider being able to pass a float rect
			auto toggle = new ToggleButton(dgui, "Toggle", Vector2f(10,75), Vector2f(100,25));
			auto textbox = new TextBox(dgui, "TextBox", Vector2f(10,110), Vector2f(180,20));
			auto listbo = new ListBox(dgui, "ListBox",["ABCD", "EFGH","IJKL","MNOP","QRST", "UVWX","YZ"], Vector2f(10,140), Vector2f(180,100));
			auto dropdown = new DropDownBox(dgui, ["abcd", "abcdef","abcdefg","abcdefgh","aabcd", "bdefg","bcgfds"], Vector2f(10,250), Vector2f(180,20));

			testWindow.registerChild(lbl);	
			testWindow.registerChild(btn);	
			testWindow.registerChild(toggle);
			testWindow.registerChild(textbox);
			testWindow.registerChild(listbo);
			testWindow.registerChild(dropdown);
		
		auto narrativePanel = new Panel(dgui, Vector2f(310,10), Vector2f(820,900));
		dgui.registerChild(narrativePanel);
			auto narrativeLabel = new Label(dgui, "Narrative", Vector2f(10,5), Vector2f(100,20));
			auto spinner = new Spinner(dgui, format("< %=4d >", 16), Vector2f(10,30), Vector2f(100,20));
			spinner.spinValue = 16;
			auto fontDropDown = new DropDownBox(dgui, ["default"], Vector2f(115,30), Vector2f(100,20));
			auto colorBox = new TextBox(dgui, "#ffffff", Vector2f(220,30), Vector2f(100,20)); //find way to lock to hex color format
			auto richtextbox = new RichTextBox(dgui, Vector2f(10,55), Vector2f(800,800));
			richtextbox.parseText(
				"\n" ~
				"data {color:#ffa500}${color:#dfa500}{{{color:#a0a0ff}form{color:#ffffff}.{color:#a0a0ff}section{color:#ffffff}.{color:#a0a0ff}label{color:#dfa500}}{color:#f0f0f0} and will be imbeded at the location\n\r"			
			);
			
			narrativePanel.registerChild(richtextbox);
			narrativePanel.registerChild(colorBox);
			narrativePanel.registerChild(fontDropDown);
			narrativePanel.registerChild(narrativeLabel);
			narrativePanel.registerChild(spinner);			
		
		auto toolDrawer = new Drawer(dgui, Vector2f(0,0), Vector2f(300,200),Dock.Left);
			auto toolArray = new ToggleButtonArray(dgui, Vector2f(10,5), Vector2f(260,190),
			["Text box", "Button", "Toggle", "List Box", "Rich Text Box", "Toggle Array",
			"Dropdown", "Spinner", "Image", "ImageDrawable", "Label", "Text Block"]);

			toolDrawer.registerChild(toolArray);
		dgui.registerChild(toolDrawer);
		
		d = new DebugBox("frameTime",dgui.fonts["default"], Vector2f(10,10), 200f,10f);
		
	}	

	void run(){
		while(running){
			frameTime.restart();
			handleEvents();
			update();
			display();
		}
	}	

	void handleEvents() {
		Event e;
		while(win.pollEvent(e)) {
			switch(e.type) {
				case Event.Type.KeyPressed :
					switch(e.key.code){
						case Keyboard.Key.Escape : 
							running = false;
						break;
						default : break;
					} break;	
				default :
					break;
			}
			//guiSystem.handleEvents(e);
            dgui.handleEvents(e);
		}
    }

	void update( /*float deltaTime*/ ) {
        float deltaTime = 1.0f / 60.0f;
        dgui.update(deltaTime);
		d.update(dt);
	}

	void display() {
		win.clear( dgui.theme["background"] );
		//draw dgui
		win.draw(dgui);

		//d.draw(win);
		//dt = frameTime.restart().asSeconds();
		win.display();
	}

	void shutdown() {
        //gui.cleanup();
		win.close();
	}
}
