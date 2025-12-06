module dgui.widgets.listbox;

import nudsfml.graphics;
import dgui.graphics.roundedrectangle;

import dgui.handler;

import dgui.widget;

struct ListboxItem {
    string label;
    string value;
}

class Listbox : Widget {
    RoundedRectangle background;
    RoundedRectangle buttonUp;
    RoundedRectangle buttonDown;
    RectangleShape slider;
    RectangleShape sliderGutter;
    Text text;

    int textsize = 15;

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

    this (Handler handler, string label, Vector2f position, Vector2f size){
        text = new Text;
        text.font = handler.font;
        text.characterSize = textsize;
        text.string = label;
        
        super(handler, position, size);

        this.label = label;
        this.size = size;
    }

    override void updateSize(){
       
    }

    override void onDraw(RenderTarget target, Vector2f offset){
        text.position = position + offset;
        target.draw(text);
    }


}