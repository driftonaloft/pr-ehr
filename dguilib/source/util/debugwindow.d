module util.debugwindow;

import nudsfml.graphics;
import std.stdio;
import std.format;

class DebugWindow {
    RenderWindow win;
    Clock clock;
    float time=0;
    float elaspedTime;
    Text text;
    Font font;
    bool doHalt = false;

    void delegate(Event) eventDelegate;
    void delegate(float) updateDelegate;
    void delegate(RenderWindow) drawDelegate;

    string[20] debugStrings; 

    this(string title = "debug window", float elaspedTime = 2.0f, bool doHalt = true){
        win = new RenderWindow(VideoMode(1024, 768), title);
        this.elaspedTime = elaspedTime;
        font  = new Font();
        font.loadFromFile("data/monoid.ttf");
        text = new Text("Time: ", font,16);
        text.fillColor(Color.White);
        this.doHalt = doHalt;

        if(elaspedTime == 0f){
            this.doHalt = false;
        }

        clock = new Clock();
    }

    void print(int line, string s){
        debugStrings[line] = s;
    }

    void run(){
        bool running = true;
        
        while(running){
            float dt = clock.restart().asSeconds();
            time = time + dt;

            if(time > elaspedTime && doHalt){
                win.close();
                writeln("debug window closed after ", elaspedTime, " seconds");
                running = false;
            }

            Event e;
            while(win.pollEvent(e)){
                if(e.type == Event.Type.Closed){
                    win.close();
                }
                if(e.type == Event.Type.KeyPressed){
                    if( e.key.code == Keyboard.Key.Escape){
                        running = false;
                    }
                }
                if(eventDelegate !is null){
                    eventDelegate(e);
                }
            }

            if(updateDelegate !is null){
                updateDelegate(dt);
            }

            win.clear();
            if(drawDelegate !is null){
                drawDelegate(win);
            }

            text.position = Vector2f(8,768-16);
            text.string = format("Time: %f FPS:%f", time, 1f/dt );
            win.draw(text);

            foreach (i, line; debugStrings){
                if(line !is null){
                    text.string = line;
                    text.position = Vector2f( 8, i * 16);
                    win.draw(text);
                }
            }

            win.display();
        }
    }
}