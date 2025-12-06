module gui.label;

import gui;

import nudsfml.graphics;
import std.stdio;

class Label : Widget {
    Text text;
    
	override @property{ //value
        override string value(string v){
			m_value = v;
            text.setString(v);
            m_size.x = text.getGlobalBounds.width;
            m_size.y = text.getCharacterSize();
			return m_value;
		}
		override string value(){
			return m_value;
		}
    }
    alias value = Widget.value;

    override void onDraw(RenderTarget target, Vector2f offset){
        text.position = Vector2f(position) + offset;
        target.draw(text);
    }

    this(Gui gui_, string value_ = "default", string id_= "lbl", Vector2f position_ = Vector2f(5,5)){
        this(gui_);
        value = value_;
        id = id_;
        position = position_;
    }

    this(Gui gui_) {
        super(gui_);

        text = new Text;
        m_type = "label";
        text.setFont(gui.fonts["default"]);
        text.setCharacterSize(15);
        text.fillColor = (Color.White);
    }
}