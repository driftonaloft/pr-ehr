module dgui.widgets.checkbox;

import std.stdio;

import nudsfml.graphics;

import dgui.graphics.roundedrectangle;

import dgui.widget;
import dgui.handler;

class CheckBox : Widget {
    Text text; 
    RoundedRectangle rect;
    RoundedRectangle check;

    this(Handler handler, string label = "test", bool checked = false, Vector2f position = Vector2f(0,0), Vector2f size = Vector2f(100,20)){
        import std.conv;

        rect = new RoundedRectangle();
        text = new Text();
        this.checked = checked;
        super(handler, position, size);
        
        text.setFont(handler.font);
        text.setCharacterSize(size.y.to!int);
        text.setColor(Color.White);
        
        rect.radius = 5;
        rect.cornerCount = 4;
        rect.fillColor = handler.colors["toggle_checked"] - Color(60, 60, 60, 0);
        rect.outlineColor = handler.colors["toggle"] - Color(60, 60, 60, 0);
        rect.outlineThickness = 2;

        check = new RoundedRectangle();
        check.radius = 5;
        check.cornerCount = 4;
        check.fillColor = handler.colors["toggle_checked"];

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
            updateSize();
			return mLabel;
		}
		override string label(){
			return mLabel;
		}
    }

    @property { //color
        override Color color(Color c){
            mColor = c;
            rect.outlineColor = c;
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
            updateSize();
            return mSize;
        }
        override Vector2f size(){
            return mSize;
        }
    }

    override void updateSize(){
        auto bounds = text.getGlobalBounds();
        Vector2f textSize = Vector2f(bounds.width,bounds.height);
        Vector2f midpoint = mSize/2;
        Vector2f textpos = midpoint - (textSize / 2) - Vector2f(0,3);
        mSize.x = textSize.x + mSize.y + 8;
        
        rect.size = Vector2f(mSize.y, mSize.y) - Vector2f(3,3);
        check.size = Vector2f(mSize.y - 4, mSize.y - 4) - Vector2f(3,3);
    }

    override void onDraw(RenderTarget target, Vector2f offset) {
        auto drawpos = position + offset;
        rect.position = drawpos;
        target.draw(rect);


        check.position = drawpos + Vector2f(2,2);
        if(checked){
            check.fillColor = handler.colors["toggle_checked"];
            target.draw(check);
        } 


        auto bounds = text.getGlobalBounds();
        Vector2f textpos = Vector2f(size.y + 3, 0);
        text.position = drawpos + textpos;

        target.draw(text);
    }
}



//can you create a unittest for testing buttons?
unittest {
    import nudsfml.graphics;
    import dgui.widgets.frame;
    import util.debugwindow;

    writeln("Testing CheckBox");

    auto dbgwin = new DebugWindow("CheckBox", 2f);
    auto handler = new Handler(dbgwin.win);

    auto frame = new Frame(handler, "Frame", Vector2f(20, 20), Vector2f(400, 300));

    auto button = new CheckBox(handler, "Toggle");
    button.size = button.preferredMinSize;
    frame.registerChild(button);

    auto button2 = new CheckBox(handler, "Checked");
    button2.size = button2.preferredMinSize;
    button2.checked = true;
    button2.position = Vector2f(0, 30);
    frame.registerChild(button2);

    handler.registerChild(frame);

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