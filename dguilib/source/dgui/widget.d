module dgui.widget;

import nudsfml.graphics;

public import dgui.graphics.roundedrectangle;
import dgui.handler;

enum WidgetEvent{
    mouseClicked,
    mouseEntered,
    mouseExited,
    mouseMoved,
    mouseHover,
    mouseStartDrag,
    mouseEndDrag,
    mouseDragging,
    mouseWheelMoved,
    keyPressed,
    keyReleased,
    textEntered,
    focasGained,
    focusLost,
    resized,
    moved
    
}

struct Value {
    int type;
    union {
        int i;
        float f;
        bool b;
        string s;
    }
}

class Widget {
    string type;
    Handler handler;
    Widget parent;
    Widget[] children;
    FloatRect childArea;
    bool enabled = true;
    bool checked;
    bool hasFocus;
    bool hasHover;
    float hoverDelay = -1;//negative values indicate infinate delay;

    string delegate (Event e)[WidgetEvent] eventCallbacks;

    string mLabel; //visible difining text of the element
    @property { 
        string label() { 
            return mLabel; 
        }
        string label(string value) {
            mLabel = value;
            return mLabel;
        }
    }

    string mValue;
    @property {
        string value() {
            return mValue;
        }
        string value(string value) {
            mValue = value;
            return mValue;
        }
    }

    Vector2f preferredMinSize(){
		return Vector2f(80, 20);
	}

    Vector2f mSize;
    @property { 
        Vector2f size() { 
            return mSize; 
        }
        Vector2f size(Vector2f value) {
            mSize = value;
            updateSize();
            return mSize;
        }
    }

    Color mColor;
    @property { //color
        Color color(Color c){
            mColor = c;
            return mColor;
        }
        Color color(){
            return mColor;
        }
    }

    //these will all probably become properties
    Vector2f position;
    

    this(Handler handler, Vector2f position, Vector2f size) {
        this.handler = handler;
        this.position = position;
        this.mSize = size;
        color = Color.White;
        type = typeof(this).stringof;
    }

    this(Handler handler) {
        this(handler, Vector2f(0, 0), Vector2f(80, 20));
    }

    void updateSize() {
        childArea = FloatRect(2, 2, size.x - 4, size.y - 4);
    }

    void onHoverUpdate(float dt) {

    }

    void registerChild(Widget child) {
        child.parent = this;
        children ~= child;
    }

    void onUpdate(float dt) {}
    void onDraw(RenderTarget target, Vector2f offset) {}

    string onMouseEntered(Event e){
        if(WidgetEvent.mouseEntered in eventCallbacks){
            return eventCallbacks[WidgetEvent.mouseEntered](e);
        }
        return null;
    }

    string onHoverGained(Event e){
        import std.stdio;
        writeln("Hover Gained - ", label);
        return null;
    }

    string onHoverLost(Event e){
        import std.stdio;
        writeln("Hover Lost - ", label);
        return null;
    }

    string onMouseExited(Event e){
        if(WidgetEvent.mouseExited in eventCallbacks){
            return eventCallbacks[WidgetEvent.mouseExited](e);
        }
        return null;
    }
    string onMouseMoved(Event e){
        if(WidgetEvent.mouseMoved in eventCallbacks){
            return eventCallbacks[WidgetEvent.mouseMoved](e);
        }
        return null;
    }
    string onMouseHover(Event e){
        if(WidgetEvent.mouseHover in eventCallbacks){
            return eventCallbacks[WidgetEvent.mouseHover](e);
        }
        return null;
    }
    string onMouseStartDrag(Event e){
        if(WidgetEvent.mouseStartDrag in eventCallbacks){
            return eventCallbacks[WidgetEvent.mouseStartDrag](e);
        }
        return null;
    }
    string onMouseEndDrag(Event e){
        if(WidgetEvent.mouseEndDrag in eventCallbacks){
            return eventCallbacks[WidgetEvent.mouseEndDrag](e);
        }
        return null;
    }
    string onMouseDragging(Event e){
        if(WidgetEvent.mouseDragging in eventCallbacks){
            return eventCallbacks[WidgetEvent.mouseDragging](e);
        }
        return null;
    }
    string onMouseWheelMoved(Event e){
        if(WidgetEvent.mouseWheelMoved in eventCallbacks){
            return eventCallbacks[WidgetEvent.mouseWheelMoved](e);
        }
        return null;
    }
    string onKeyPressed(Event e){
        if(WidgetEvent.keyPressed in eventCallbacks){
            return eventCallbacks[WidgetEvent.keyPressed](e);
        }
        return null;
    }
    string onKeyReleased(Event e){
        if(WidgetEvent.keyReleased in eventCallbacks){
            return eventCallbacks[WidgetEvent.keyReleased](e);
        }
        return null;
    }
    string onTextEntered(Event e){
        if(WidgetEvent.textEntered in eventCallbacks){
            return eventCallbacks[WidgetEvent.textEntered](e);
        }
        return null;
    }
    string onFocusGained(Event e){
        if(WidgetEvent.focasGained in eventCallbacks){
            return eventCallbacks[WidgetEvent.focasGained](e);
        }
        return null;
    }
    string onFocusLost(Event e){
        if(WidgetEvent.focusLost in eventCallbacks){
            return eventCallbacks[WidgetEvent.focusLost](e);
        }
        return null;
    }
    string onResized(Event e){
        if(WidgetEvent.resized in eventCallbacks){
            return eventCallbacks[WidgetEvent.resized](e);
        }
        return null;
    }
    string onMove(Event e){
        if(WidgetEvent.moved in eventCallbacks){
            return eventCallbacks[WidgetEvent.moved](e);
        }
        return null;
    }
    string onMouseClicked(Event e){
        if(WidgetEvent.mouseClicked in eventCallbacks){
            return eventCallbacks[WidgetEvent.mouseClicked](e);
        }
        return null;
    }

    void update(float dt) {
        onUpdate(dt);
        foreach(child; children){
            child.update(dt);
        }
    }

    bool isHandle( Vector2i point) {
        return false;
    }

    Vector2i getReleativePosition( Vector2i point) {
        point = point - (Vector2i(position) + Vector2i(Vector2f(childArea.left, childArea.top)));
        if(parent !is null){
            point = parent.getReleativePosition(point);
        }
        return point;
    }

    Widget contains(Vector2i point){
        if(enabled){
            point -= position;
            foreach_reverse (ref child; children){
                auto c = child.contains(point - Vector2f(childArea.left, childArea.top));{
                    if(c !is null){
                        return c;
                    }
                }
            }
            if( point.x < mSize.x && point.x >= 0 && 
                point.y < mSize.y && point.y >= 0){
                return this;
            }
        }

        return null;
    }

    void draw(RenderTarget target, Vector2f offset = Vector2f(0, 0)) {
        if(enabled){
            onDraw(target, offset);
            Vector2f offsetPosition = offset + position + Vector2f(childArea.left, childArea.top);
            foreach(child; children){
                child.draw(target, offsetPosition);
            }
        }
    }
}

unittest {
    import std.stdio;
    import dgui.handler;
    import dgui.widget;

    import util.debugwindow;

    writeln("Testing Widget");

    RenderWindow win = new RenderWindow(VideoMode(800, 600), "Test");
    win.setFramerateLimit(60);
    bool running = true;

    auto dbgwin = new DebugWindow("Widget Test", 1f);

    Widget testWidget = new Widget(null, Vector2f(100, 100), Vector2f(100, 100));

    dbgwin.drawDelegate = (target) {
        testWidget.draw(target, Vector2f(0, 0));
    };

    dbgwin.run;
}