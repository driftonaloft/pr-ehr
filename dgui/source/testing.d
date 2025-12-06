module testing;

import gui;

import scene;


import app;


import gui.mltextbox;
import nudsfml.system.vector2;

class Testing : Scene {
    Application app;

    Window testWindow;

    MultilineTextbox tbTest;

    this (Application app_) {
        super(app_);
        app = app_;
    }

    override void onResize (Vector2i size){
        super.onResize(size);
        if (testWindow !is null) {
            testWindow.position = (Vector2f(size) - testWindow.size ) / 2;
        }
    }

    override void onGainFocus(){
        super.onGainFocus();
        app.guisystem.clear();
        app.guisystem.addChild(testWindow);
    }

    override void onLostFocus(){
        super.onLostFocus();

    }

    override void onCreate(){
        testWindow = new gui.window.Window(app.guisystem, "Testing",Vector2f(0,0), Vector2f(640,480));

        string text = "this is a multiline text box\n now look at me\n there should be 3 lines";
        tbTest = new MultilineTextbox(app.guisystem, "", text, Vector2f(5,20), Vector2f(630,455));
        testWindow.addChild(tbTest);
        
    }

    void buildGui(){
		auto guiWin = new gui.window.Window(app.guisystem);
		guiWin.label = "Test Gui Window";
		guiWin.size = Vector2f(800,600);
		guiWin.position = Vector2f(10, 64);
		app.guisystem.addChild(guiWin);

		auto guiTree = new Tree(app.guisystem);
		guiTree.label = "Tree Display Test";
		guiTree.value = "Test Value";
		guiTree.size = Vector2f(200, 570);
		guiTree.position = Vector2f(5, 25);

		guiTree.addNode("a", "A", "a-node","");
		auto bnode = guiTree.addNode("b", "B", "b-node","");
			bnode.addNode("c", "C", "c-node","");
			bnode.addNode("d", "D", "d-node", "");
			auto enode = bnode.addNode("e", "E", "e-node", "",false,true);
			enode.addNode("f", "F", "f-node", "");
			bnode.addNode("g", "G", "g-node", "");
			bnode.addNode("h", "H", "h-node", "");
			bnode.open= true;
		guiTree.addNode("i", "I", "i-node", "");
		guiTree.addNode("j", "J", "j-node", "");

		guiWin.addChild(guiTree);

		auto guiCage = new Cage(app.guisystem);
		guiCage.size = Vector2f(200, 200);
		guiCage.position = Vector2f(250, 75);
		guiCage.edit = true;
		guiWin.addChild(guiCage);

		auto button = new Button(app.guisystem);
		button.label = "Test button";
		button.value = "Test Value";
		button.size = Vector2f(100, 32);
		button.position = Vector2f(210, 25);
		guiWin.addChild(button);	
	}
}