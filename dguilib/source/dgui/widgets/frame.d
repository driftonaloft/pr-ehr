module dgui.widgets.frame;

import dgui.widget;
import dgui.handler;

import nudsfml.graphics;

class Frame : Widget {
    RoundedRectangle frameShape;
    RoundedRectangle labelShape;
    FloatRect handleArea;
    Text labelText;

    @property {
        override string label(string value){
            mLabel = value;
            labelText.string = value;
            return mLabel;
        }
        override string label(){
            return mLabel;
        }
    }

    this(Handler handler) {
        this(handler, "frame", Vector2f(0,0), Vector2f(300, 200));
    }

    this(Handler handler, string label = "frame", Vector2f position = Vector2f(0,0), Vector2f size = Vector2f(300, 200)) {
        super(handler, position, size);

        frameShape = new RoundedRectangle();
        frameShape.fillColor = handler.colors["frame"];
        frameShape.outlineColor = handler.colors["frameOutline"];
        frameShape.outlineThickness = 1;

        labelShape = new RoundedRectangle();
        labelShape.fillColor = handler.colors["frame"] - Color(30, 30, 30, 0);
        labelShape.bottomLeft = false;
        labelShape.bottomRight = false;

        labelText = new Text();
        labelText.setFont(handler.font);
        labelText.characterSize = 16;
        labelText.fillColor = handler.colors["text"];

        this.label = label;
        this.updateSize();
    }

    override bool isHandle(Vector2i point){
        return handleArea.contains(point.x, point.y);
    }

    override void updateSize(){
        frameShape.size = size;  
        labelShape.size = Vector2f(size.x - 4, 20);

        handleArea = FloatRect(2, 2, size.x, 20);

        childArea = FloatRect(2, 26, size.x, size.y - 28);
    }

    override void onDraw(RenderTarget target, Vector2f offset){
        frameShape.position = position + offset;
        target.draw(frameShape);

        labelShape.position = position + offset + Vector2f(2,2);
        target.draw(labelShape);

        labelText.position = position + offset + Vector2f(4,2);
        target.draw(labelText);
    }
}


unittest {
    import std.stdio;
    import dgui.handler;
    import dgui.widget;

    import util.debugwindow;

    writeln("Testing Frame");

    auto dbgwin = new DebugWindow("Testing Frame", 2f);
    auto handler = new Handler(dbgwin.win);

    Frame testFrame = new Frame(handler);
    testFrame.size = Vector2f(200, 300);
    testFrame.position = Vector2f(50, 50);
    testFrame.label = "Test Frame";
    handler.registerChild(testFrame);
    
    dbgwin.updateDelegate = (float dt){
        handler.update(dt);
    };
    dbgwin.eventDelegate = (Event e){
        handler.handleEvent(e);
    };
    dbgwin.drawDelegate = (target){
        handler.draw();
    }; 
    dbgwin.run();
}
