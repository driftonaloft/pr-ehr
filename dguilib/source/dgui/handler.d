module dgui.handler;

import std.stdio;

import dgui.widget;

import nudsfml.graphics;
import core.internal.hash;

struct MouseState {
    Vector2i position;
    bool leftButton;
    bool rightButton;
    bool middleButton;
    bool xButton1;
    bool xButton2;

    void getState(){
        position = Mouse.getPosition();
        leftButton = Mouse.isButtonPressed(Mouse.Button.Left);
        rightButton = Mouse.isButtonPressed(Mouse.Button.Right);
        middleButton = Mouse.isButtonPressed(Mouse.Button.Middle);
        xButton1 = Mouse.isButtonPressed(Mouse.Button.XButton1);
        xButton2 = Mouse.isButtonPressed(Mouse.Button.XButton2);
    }

    bool buttonPressed(Mouse.Button button)(MouseState previous){
        static if(button == Mouse.Button.Left){
            return leftButton && !previous.leftButton;
        }
        static if(button == Mouse.Button.Right){
            return rightButton && !previous.rightButton;
        } 
        static if(button == Mouse.Button.Middle){
            return middleButton && !previous.middleButton;
        } 
        static if(button == Mouse.Button.XButton1){
            return xButton1 && !previous.xButton1;
        } 
        static if(button == Mouse.Button.XButton2){
            return xButton2 && !previous.xButton2;
        } 
    }

    bool buttonRelease(Mouse.Button button)(MouseState previous){
        static if(button == Mouse.Button.Left){
            return !leftButton && previous.leftButton;
        }
        static if(button == Mouse.Button.Right){
            return !rightButton && previous.rightButton;
        } 
        static if(button == Mouse.Button.Middle){
            return !middleButton && previous.middleButton;
        } 
        static if(button == Mouse.Button.XButton1){
            return !xButton1 && previous.xButton1;
        } 
        static if(button == Mouse.Button.XButton2){
            return !xButton2 && previous.xButton2;
        }
    }

    bool buttonHeld (Mouse.Button button)( MouseState previous){
        static if(button == Mouse.Button.Left){
            return leftButton && previous.leftButton;
        }
        static if(button == Mouse.Button.Right){
            return rightButton && previous.rightButton;
        }
        static if(button == Mouse.Button.Middle){
            return middleButton && previous.middleButton;
        }
        static if(button == Mouse.Button.XButton1){
            return xButton1 && previous.xButton1;
        }
        static if(button == Mouse.Button.XButton2){
            return xButton2 && previous.xButton2;
        } 
    }
    
}

class Handler {
    RenderWindow win;
    Font font;
    Color[string] colors;
    //TextureAtlas atlas;

    Widget[]  children;
    Widget hasFocus; 
    Widget hasHover;
    Widget potentialHover;
    float hoverTime = 0f;
    Widget [] popups; //dropdowns, menus, etc

    Widget draggedOffset;
    Vector2i dragOffset;


    float scale = 1f;

    MouseState currentMouse;
    MouseState previousMouse;
    float distanceMouse;
    
    this (RenderWindow win) {
        this.win = win;
        font = new Font();
        
        if(!font.loadFromFile("data/monoid.ttf")){
            writeln("Failed to load font");
        }

        this.loadTheme("data/theme.dat");
    }

    bool loadTheme(string filename){
        import std.stdio;
        import std.string;
        import std.format;

        import dgui.graphics.color : fromUInt;

        colors["text"] = Color(255, 255, 255);
        colors["frame"] = Color(127, 127, 127);
        colors["frameOutline"]= Color(100, 100, 100);
        colors["button"] = Color(160, 160, 160);
        colors["toggle"] = Color(160, 160, 160);
        colors["toggle_checked"] = Color(100, 100, 100);
        colors["toggle_unchecked"] = Color(160, 160, 160);
        colors["textbox"] = Color(100,100,100);
        colors["textbox_outline"] = Color(180,180,180);
        colors["textbox_cursor"] = Color(225,225,225);


        File f;     

        try {
            f = File(filename, "r");
        } catch (Exception e){
            writeln("Failed to open theme file: ", filename);
            return false;
        }

        string line;
        while((line = f.readln()) !is null){
            string target;
            uint hex;
            line.formattedRead("\"%s\" = 0x%x", target, hex);
            colors[target] = fromUInt(hex);
            //writeln("Loaded color: ", target, " = ", colors[target].toString);

        }
        
        return true;
    }

    void handleEvent(Event e) {
        switch(e.type){
            case Event.Type.MouseButtonPressed:{
                auto mousePos = Vector2i(e.mouseButton.x, e.mouseButton.y);
                auto target = contains(mousePos);
                changeFocus(target);
                if(target !is null) {
                    target.onMouseClicked(e);
                }
                break;
            }
            case Event.Type.MouseWheelMoved:{
                auto mousePos = Vector2i(e.mouseButton.x, e.mouseButton.y);
                auto target = contains(mousePos);
                if(target !is null){
                    target.onMouseWheelMoved(e);
                }
                break;
            }
            case Event.Type.KeyPressed:{
                if(hasFocus !is null){
                    hasFocus.onKeyPressed(e);
                }
                break;
            }
            case Event.Type.TextEntered:{
                if(hasFocus !is null){
                    hasFocus.onTextEntered(e);
                }
                break;
            }
            default:
                break;
        }
    }

    void changeFocus(ref Widget focus){
        if(hasFocus !is null){
            hasFocus.onFocusLost(Event());
            hasFocus.hasFocus = false;

        }
        if(focus !is null){
            focus.onFocusGained(Event());
            focus.hasFocus = true;
        }
        hasFocus = focus;
    }

    Widget contains(Vector2i point){
        foreach_reverse (ref child; children){
            auto c = child.contains(point);{
                if(c !is null){
                    return c;
                }
            }
        }
        return null;
    }

    void registerChild(Widget child) {
        child.parent = null;
        children ~= child;
    }

    
    void update(float dt){
        if(!handleDragging(dt)){
            handleHover(dt);
        }

        foreach(ref child; children){
            child.update(dt);
        }
    }

    bool  (float dt){
        import dgui.util.vector2;
        previousMouse = currentMouse;
        currentMouse.getState();

        if(currentMouse.buttonPressed!(Mouse.Button.Left)(previousMouse)){
            distanceMouse = 0f;
        } else if (currentMouse.buttonHeld!(Mouse.Button.Left)(previousMouse)){
            distanceMouse += distance(currentMouse.position , previousMouse.position);
        }



        //determin left mouse button state change
        //if button is pressed and contained widget is not null and containedwidget isHandle = true
        //then startDragging if mouse moves more then 3 pixels
        //onStartDrag;
        //if dragging is true then call onDrag
        //onDrag;
        //if button is released then call onEndDrag
        //onEndDrag


        return false;
    }

    void handleHover(float dt){
        auto tempHover = contains(Mouse.getPosition(win));
        if(tempHover != potentialHover){
            hoverTime = 0f;
            potentialHover = tempHover;
        } else if(potentialHover == hasHover){
            //Hover hasn't changed, so we don't need to do anything
            if(hasHover !is null){
                hasHover.onHoverUpdate(dt);
            }
        } else {
            hoverTime += dt;
            if(potentialHover !is null){
                if(hoverTime > potentialHover.hoverDelay && potentialHover.hoverDelay >= 0f){
                    hoverTime = 0f;
                    if(hasHover !is null){
                        hasHover.onHoverLost(Event());
                        hasHover.hasHover = false;
                        hasHover = null;

                    }
                    if(!potentialHover.hasHover){
                        potentialHover.hasHover = true;
                        hasHover = potentialHover;
                        potentialHover.onHoverGained(Event());
                    }
                }
            } else {
                hoverTime = 0f;
                if(hasHover !is null){
                    hasHover.onHoverLost(Event());
                    hasHover.hasHover = false;
                    hasHover = null;
                }
            }
        }

    }

    void draw(){
        foreach(ref child; children){
            child.draw(win);
        }
        if(popups.length > 0){
            foreach(ref popup; popups){
                popup.draw(win);
            }
        }
    }
}


unittest {
    import std.stdio;
    import dgui.handler;
    import dgui.widget;

    writeln("Testing Hanlder");

    RenderWindow win = new RenderWindow(VideoMode(800, 600), "Test");
    win.setFramerateLimit(60);
    
    Handler handler = new Handler(win);

    Widget testWidget = new Widget(null, Vector2f(100, 100), Vector2f(100, 100));
    handler.registerChild(testWidget);
    
    Clock clock = new Clock();
    float testTime = 0f;
    bool running = true;
    while(running){
        float dt = clock.restart().asSeconds();
        Event event;
        while(win.pollEvent(event)){
            if(event.type == Event.Type.Closed){
                running = false;
            }

            handler.handleEvent(event);
        }

        testTime += dt;
        if(testTime > 1f){
            running = false;
        }

        handler.update(dt);

        win.clear(Color(20,20,20));

        handler.draw();

        win.display();
    } 
    win.close();
}