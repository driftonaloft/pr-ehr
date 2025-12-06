module dgui.widgets.label;

import nudsfml.graphics;

import dgui.widget;
import dgui.handler;

class Label : Widget {
    Text text;

    @property {
        override string label (string v){
            mLabel = v;
            text.string = v;
            updateSize();
            return v;
        }
    }
    
    @property {
        override Color color (Color v){
            mColor = v;
            text.fillColor = v;
            return v;
        }
    }


    @property {
        override Vector2f size (Vector2f v){
            import std.conv;
            text.characterSize = v.y.to!int;
            updateSize();
            return mSize;
        }
    }

    override void updateSize(){
        mSize.x = text.getGlobalBounds.width;
        mSize.y = text.characterSize;
    }

    override void onDraw(RenderTarget target, Vector2f offset){
        text.position = position + offset;
        target.draw(text);
    }

    this (Handler handler, string label, Vector2f position, Vector2f size){
        text = new Text;
        text.font = handler.font;
        text.string = label;
        
        super(handler, position, size);

        this.label = label;
        this.size = size;
    }
}


unittest {
    import std.stdio;
    import dgui.handler;
    import dgui.widget;
    import dgui.graphics.color;
    import std.conv;

    import util.debugwindow;


    writeln("Testing Label");

    auto dbgwin = new DebugWindow("CheckBox", 2f);
    auto handler = new Handler(dbgwin.win);

    Label testWidget = new Label(handler, "Test 2", Vector2f(100, 100), Vector2f(100, 100));
    testWidget.label = "Test";
    testWidget.size = Vector2f(100, 30);

    handler.registerChild(testWidget);


    float testTime = 0f;
    
    dbgwin.updateDelegate = (float dt){
        testTime += dt;
        testWidget.color = HSVtoRGB((testTime * 512).to!int % 255, 1f, 1f);
    };
    dbgwin.eventDelegate = (Event e){
        handler.handleEvent(e);
    };
    dbgwin.drawDelegate = (target){
        handler.draw();
    };

    dbgwin.run();
}