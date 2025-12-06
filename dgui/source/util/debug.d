module util.debugger;

import gui;
import nudsfml.graphics;

Debug debugger;

class Debug {
    Drawer debugDropdown;
    Console debugConsole;

    this(){
    }

    void registerDebugGui(Gui guisystem){
        debugDropdown = new Drawer(guisystem);
        debugDropdown.id = "debugConsoleDrawer";
        debugDropdown.size = Vector2f(guisystem.win.size.x, 300);
        debugDropdown.position = Vector2f(0,0);
        debugDropdown.docked = Drawer.Docked.Top;
        debugDropdown.events["resize"]=(Event e){
            debugDropdown.size = Vector2f(debugDropdown.size.x, 300);
        };
        debugDropdown.state = debugDropdown.DrawerState.Closed;

        debugConsole = new Console(guisystem);
        debugConsole.id = "console";
        debugConsole.size = debugDropdown.size - Vector2f(32, 16);
        debugConsole.position = Vector2f(5, 5);
        debugConsole.print("Elevation EHR");
        debugDropdown.addChild(debugConsole);

        guisystem.addChild(debugDropdown);

        Table tb = new Table(guisystem,3,5);
        tb.position = Vector2f(10,300);
        guisystem.addChild(tb);
    }

    void print(A...)(string f, A args){
        debugConsole.print(f, args);
        //log output
    }
}