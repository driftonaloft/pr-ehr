module gui.checkbox;

import gui;

import nudsfml.graphics;
import std.stdio;

class CheckBox : Widget {
    Text text;
    RectangleShape checkBox;

    bool checked;
    
	override @property{ //label
        override string label(string l){
			m_label = l;
            text.string = l;
            m_size.x = text.getGlobalBounds.width + 18;
            m_size.y = text.getCharacterSize() + 6;
			return m_value;
		}
		override string label(){
			return m_label;
		}
    }
    alias label = Widget.label;

    override @property{ //color
        override Color color(Color c){
			m_color = c;
            text.fillColor = (m_color);
            checkBox.fillColor = m_color;
			return m_color;
		}
		override Color color(){
			return m_color;
		}
    }
    alias color = Widget.color;

    this(Gui gui_, string label_ = "default",Vector2f pos_ = Vector2f(5, 5), bool checked_ = false){
        super(gui_);

        m_type = "checkbox";

        text = new Text;
        text.setFont(gui.fonts["default"]);
        text.setCharacterSize(12);
        text.fillColor = (Color.White);

        checkBox = new RectangleShape();
        checkBox.size = Vector2f(16,16); 
        checkBox.setTexture(gui.controls);
        checkBox.textureRect = IntRect(0,32,32,32);

        checked = checked_;
        position = pos_;
        label = label_;
    }

    override void onClick(Event e){
        checked = checked ? false : true;
        if(checked){
            checkBox.textureRect = IntRect(32,32,32,32);
        } else {
            checkBox.textureRect = IntRect(0,32,32,32);
        }
    }

    override void onDraw(RenderTarget target, Vector2f offset){
        checkBox.position = position + offset;
        text.position = position + Vector2f(18,0) + offset;
        target.draw(checkBox);
        target.draw(text);
    }
}