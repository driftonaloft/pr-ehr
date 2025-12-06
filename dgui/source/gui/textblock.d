module gui.textblock;

import gui;

import nudsfml.graphics;
import std.stdio;
import std.string;

class TextBlock : Widget {
    Text text;
    int linespacing=3;

    string [] lines;
    
	override @property{ //value
        override string value(string v){
			m_value = v;
            lines = split(v, "\n");
            foreach(ref string line ; lines){
                line = line.stripRight(); // 
            }
            m_size.x = text.getGlobalBounds.width;
            m_size.y = (text.getCharacterSize()+ linespacing) * lines.length;
			return m_value;
		}
		override string value(){
			return m_value;
		}
    }
    alias value = Widget.value;


    this(Gui gui_, string value_ = "default", string id_= "lbl", Vector2f position_ = Vector2f(5,5),Vector2f size_ = Vector2f(100,100)){
        this(gui_);

        id = id_;
        value = value_;
        size = size_;
        position = position_;
    }

    this(Gui gui_) {
        super(gui_);
        m_type = "label";

        text = new Text;
        text.setFont(gui.fonts["default"]);
        text.setCharacterSize(12);
        text.fillColor = (Color.White);
    }

    override void onDraw(RenderTarget target, Vector2f offset){
        Vector2f drawpos = position + offset;
        Vector2f lineAdvance = Vector2f(0, text.getCharacterSize() + linespacing);

        foreach(ref line; lines){
            text.string = line;
            text.position = drawpos;
            target.draw(text);
            drawpos += lineAdvance; 
        }
    }
}