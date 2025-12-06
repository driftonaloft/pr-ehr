module dgui.widgets.togglebutton;

import std.stdio;

import nudsfml.graphics;

import dgui.graphics.roundedrectangle;

import dgui.widget;
import dgui.handler;

class ToggleButton : Widget {
    Text text; 
    RoundedRectangle rect;

    this(Handler handler, string label = "test", bool checked = false, Vector2f position = Vector2f(0,0), Vector2f size = Vector2f(100,20)){
        rect = new RoundedRectangle();
        text = new Text();
        this.checked = checked;
        super(handler, position, size);
        
        text.setFont(handler.font);
        text.setCharacterSize(14);
        text.setColor(Color.White);
        
        rect.radius = 5;
        rect.cornerCount = 4;
        rect.outlineColor = handler.colors["toggle"] - Color(60, 60, 60, 0);
        rect.outlineThickness = 1;

        color = handler.colors["toggle"];
        this.label = label;
    }

    @property {
        override Vector2f preferredMinSize() {
            auto bounds = text.getGlobalBounds();
            Vector2f textSize = Vector2f(bounds.width,bounds.height) + Vector2f(15,6);
            return Vector2f(textSize.x, 20);
        }
    }

    override string onMouseClicked(Event e){
        checked = !checked;
        return super.onMouseClicked(e);
    }

    @property{ //label
        override string label(string v){
			mLabel = v;
            text.string = v;
			return mLabel;
		}
		override string label(){
			return mLabel;
		}
    }

    @property { //color
        override Color color(Color c){
            mColor = c;
            rect.fillColor = c;
            return mColor;
        }
        override Color color(){
            return mColor;
        }
    }

    @property { //size
        override Vector2f size(Vector2f s){
            mSize = s;
            rect.size = s;
            return mSize;
        }
        override Vector2f size(){
            return mSize;
        }
    }
    alias size = Widget.size;

    override void onDraw(RenderTarget target, Vector2f offset) {
        auto drawpos = position + offset;
        rect.position = drawpos;
        rect.size = mSize;
        if(checked){
            rect.fillColor = handler.colors["toggle_checked"];
        } else {
            rect.fillColor = handler.colors["toggle_unchecked"];
        }

        auto bounds = text.getGlobalBounds();
        Vector2f textSize = Vector2f(bounds.width,bounds.height);
        Vector2f midpoint = mSize/2;
        Vector2f textpos = midpoint - (textSize / 2) - Vector2f(0,3);
        
        text.position = drawpos + textpos;

        target.draw(rect);
        target.draw(text);
    }
}



//can you create a unittest for testing buttons?
unittest {
    import nudsfml.graphics;
    import dgui.widgets.frame;
    import dgui.widgets.label;

    import util.debugwindow;

    writeln("Testing ToggleButton");

    auto dbgwin = new DebugWindow("ToggleButton", 2f);
    auto handler = new Handler(dbgwin.win);

    auto frame = new Frame(handler, "Frame", Vector2f(20, 20), Vector2f(400, 300));
    handler.registerChild(frame);

    auto button = new ToggleButton(handler, "Toggle");
    button.size = button.preferredMinSize;
    frame.registerChild(button);

    auto button2 = new ToggleButton(handler, "Checked");
    button2.size = button2.preferredMinSize;
    button2.checked = true;
    button2.position = Vector2f(0, 30);
    frame.registerChild(button2);

    auto label = new Label(handler, "Label", Vector2f(0, 75), Vector2f(100, 20));
    frame.registerChild(label);

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