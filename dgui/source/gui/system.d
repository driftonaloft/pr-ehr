module gui.system;

import std.stdio;
import std.conv;

import nudsfml.graphics;
import gfx;
import gui;

struct MouseState {
    Vector2i pos;
    bool button1;
    bool button2;
    bool button3;
}

struct DragState {
    Vector2i startDrag;
    Vector2i offset;
    Vector2i endDrag;
    bool dragging;
    Widget target;
}

class Gui {
   Font[string] fonts;
   Color[string] theme;

    Texture controls;
    Atlas atlas;
    RenderWindow win;

    Widget[] children;
    string[] tabstops;
    ulong tabstopIndex;
    Widget hasFocus;

    Vector2i dragStart;
    Vector2i dragEnd;
    bool isDragging;

    MouseState currentMouse;
    MouseState oldMouse;

    DragState dragState;

    RectangleShape mousePosition;

    Vector2f size;

    this(RenderWindow window) {
        win = window;
        currentMouse =  MouseState();
        oldMouse = MouseState();
        controls = new Texture();
        theme["text"] = Color.White;

        size = Vector2f(window.size);

        fonts["default"] = new Font();
        if (!fonts["default"].loadFromFile("data/font/hack/Hack-Regular.ttf")) {
            writeln("failed to load system font");
        }
        atlas = new Atlas();

        mousePosition = new RectangleShape;
        mousePosition.size = Vector2f(6,6);
    }

    void initialize() {
        if (!controls.loadFromFile("data/controls.png")) {
            writeln("failed to load gui controls texture: data/controls.png");
        }
    }

    void addChild(T : Widget)(ref T child, bool tabstop = false) {
		// TODO!!!
		// i dislike this hack should have some type of registered function that can be used to deal with 
		// witdgets that have special requirements/considerations for registering their children

		child.parent = null;
		children ~= child;
		if (tabstop) {
			tabstops ~= child.id;
		}
	}

    void removeChildType(T : Widget)(ref T child){
        import std.algorithm;
        children = children.remove!(c => c == child);
    }

    Widget contains(Vector2i pos) {
        Widget obj;
        foreach_reverse (ref child; children) {
            obj = child.contains(pos);
            if (obj !is null) {
                break;
            }
        }
        return obj;
    }

    void update(float deltaTime) {
        //rework mouse states to be more concise 
        auto p = Mouse.getPosition(win);
        currentMouse = MouseState();//
        currentMouse.pos = p;
        currentMouse.button1 = Mouse.isButtonPressed(Mouse.Button.Left);
        currentMouse.button2 = Mouse.isButtonPressed(Mouse.Button.Right);
        currentMouse.button3 = Mouse.isButtonPressed(Mouse.Button.Middle);

        if (currentMouse.button1 && !oldMouse.button1) {
            dragState.startDrag = p;
            auto target = contains(p);
            if (target !is null) {
                if(target.grabable(p)){
                   version(DEBUG){ writeln("grabbed: ", target.m_type, " - ", target.id);}
                    dragState.target = target;
                    dragState.offset = target.getReleativePosition(p);
                }
            }
            dragState.dragging = false;
        } else if (currentMouse.button1 && oldMouse.button1) {
            dragState.dragging = true;
        } else if (!currentMouse.button1 && oldMouse.button1) {
            dragState.endDrag = p;
            dragState.offset = Vector2i(0,0);
            dragState.target = null;
            dragState.dragging = false;
        }
        Vector2i deltaMouse = currentMouse.pos - oldMouse.pos;

        mousePosition.position = Vector2f(p) - Vector2f(3,3);

        if (dragState.dragging) {
            mousePosition.fillColor = Color.Green;
            if (hasFocus !is null) {
                if (hasFocus.m_type == "cage" || hasFocus.m_type == "window") {
                    if(hasFocus == dragState.target) {  
                        dragState.target.onDrag(p, dragState.offset);
                    }
                }
            }
        } else {
            mousePosition.fillColor(Color.White);
        }
        oldMouse = currentMouse;

        foreach (ref child; children) {
            child.update(deltaTime);
        }
    }

    void draw() {
        foreach (ref child; children) {
            child.draw(win, Vector2f(0, 0));
        }
        win.draw(mousePosition);
    }

    void doTabStop(bool reverse = false) {
        if (hasFocus !is null) {
            if (hasFocus.willTabstop) {
                auto p = hasFocus.parent;
                if (p !is null) {
                    if (p.tabstops.length > 0) {
                        if (reverse) {
                            p.tabStopIndex--;
                            if (p.tabStopIndex < 0) {
                                p.tabStopIndex = cast(int)(p.tabstops.length - 1);
                            }
                        } else {
                            p.tabStopIndex++;
                            if (p.tabStopIndex >= p.tabstops.length) {
                                p.tabStopIndex = 0;
                            }
                        }
                        auto child = p.getChild(p.tabstops[p.tabStopIndex]);
                        if (child !is null) {
                            changeFocus(child);
                        }
                    }
                }
            }
        }
    }

    void clear(){
        children.length = 0;
        tabstops.length = 0;
        tabstopIndex = 0;
        hasFocus = null;
    }

    void changeFocus(ref Widget obj) {
        if (hasFocus !is null) {
            hasFocus.hasFocus = false;
            hasFocus.onLostFocus();
        }
        if (obj !is null) {
            obj.hasFocus = true;
            obj.onGainFocus();
        }
        hasFocus = obj;
    }

    void handleEvent(Event e) {
        switch (e.type) {
            case e.Type.Closed:
                win.close();
                break;
                
            case e.Type.KeyPressed:
                if (e.key.code == Keyboard.Key.Left) {
                    if (hasFocus !is null) {
                        hasFocus.cursor--;
                        hasFocus.onCursor();
                    }
                }
                if (e.key.code == Keyboard.Key.Right) {
                    if (hasFocus !is null) {
                        hasFocus.cursor++;
                        hasFocus.onCursor();
                    }
                }
                if (e.key.code == Keyboard.Key.Tab) {
                    doTabStop(e.key.shift);
                }
                if(e.key.code == Keyboard.Key.End){
                    if(hasFocus !is null){
                        hasFocus.onEnd();
                    }
                }
                if(e.key.code == Keyboard.Key.Home){
                    if(hasFocus !is null){
                        hasFocus.onHome();
                    }
                }
                break;

            case e.Type.KeyReleased:
                if (hasFocus !is null) {
                    hasFocus.onKeyReleased(e);
                }
                break;

            case e.Type.TextEntered:
                if (hasFocus !is null) {
                    hasFocus.onText(e);
                }
                break;

            case e.Type.Resized:
                win.view = View(FloatRect(0, 0, e.size.width, e.size.height));
                size = Vector2f(e.size.width, e.size.height);
                foreach (ref child; children) {
                    child.onResize(e);
                }
                break;

            case e.Type.MouseButtonPressed:
                Widget obj;
                auto p = Vector2i(e.mouseButton.x, e.mouseButton.y);
                foreach_reverse (ref child; children) {
                    obj = child.contains(p);
                    if (obj !is null) {
                        version(DEBUG){writeln("object clicked: ", obj.id, " type: ", obj.m_type);}
                        obj.onClick(e);
                        obj.hasFocus = true;
                        break;
                    }
                }
                changeFocus(obj);
                break;

            case e.Type.MouseWheelMoved:
                Widget obj;
                auto p = Vector2i(e.mouseWheel.x, e.mouseWheel.y);
                foreach_reverse (ref child; children) {
                    obj = child.contains(p);
                    if (obj !is null) {
                        break;
                    }
                }
                if (obj !is null) {
                    obj.onScrollWheel(e);
                }
                break;

            default:
                break;
        }
    }
}
