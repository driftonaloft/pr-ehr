import std.stdio;

import nudsfml.graphics;


import dgui;

import util.debugwindow;

void main() {
    writeln("Testing Full");

    auto dbgwin = new DebugWindow ("DebugWindow - Testing", 0f);
    auto handler = new Handler(dbgwin.win);

    auto frame = new Frame(handler, "Frame", Vector2f(20, 20), Vector2f(400, 300));

    auto button = new Button(handler, "Button", Vector2f(0, 0));
    button.size = button.preferredMinSize;
    frame.registerChild(button);

    button.eventCallbacks[WidgetEvent.mouseClicked] = (Event e) {
        writeln("Button clicked");
        return null;
    };
    
    auto toggleButton = new ToggleButton(handler, "Toggle", false, Vector2f(0, 25));
    toggleButton.size = toggleButton.preferredMinSize;
    frame.registerChild(toggleButton);
    toggleButton.eventCallbacks[WidgetEvent.mouseClicked] = (Event e) {
		writeln("toggleButton status: " , toggleButton.checked ? "true" : "false");
		return null;
	};

    auto tbab = new ToggleButtonArray(handler, ["Kawasaki", "Carneval", "List", "Salid"], Vector2f(10, 25 * 2), Vector2f(380, 20), false); 
    frame.registerChild(tbab);

    auto checkbox = new CheckBox(handler, "Checkbox",false, Vector2f(0, 25 * 3), Vector2f(100, 15));
    checkbox.size = checkbox.preferredMinSize;
    frame.registerChild(checkbox);

    handler.registerChild(frame);

    dbgwin.eventDelegate = &handler.handleEvent;
    dbgwin.updateDelegate = &handler.update;


    dbgwin.drawDelegate = (RenderWindow win) {
        import std.format;
        Vector2i mouse = Mouse.getPosition();
        dbgwin.print(0, format("Mouse: (%d, %d)", mouse.x, mouse.y));
        handler.draw();
    };

    dbgwin.run();

 

}



