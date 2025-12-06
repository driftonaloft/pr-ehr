module gui.button;

import nudsfml.graphics;

import std.stdio;
import gui;
import gfx;

class Button : Widget {
    Text text;
    RoundedRectangle rect;

	override @property{ //value
        override string value(string v){
			m_value = v;
            text.string = v;
			return m_value;
		}
		override string value(){
			return m_value;
		}
    }
    alias value = Widget.value;

    @property{ //label
        override string label(string v){
			m_label = v;
			return m_label;
		}
		override string label(){
			return m_label;
		}
    }
    alias label = Widget.label;

    @property { //color
        override Color color(Color c){
            m_color = c;
            rect.fillColor = c;
            return m_color;
        }
        override Color color(){
            return m_color;
        }
    }
    alias color = Widget.color;

    @property { //size
        override Vector2f size(Vector2f s){
            m_size = s;
            rect.size = s;
            return m_size;
        }
        override Vector2f size(){
            return m_size;
        }
    }
    alias size = Widget.size;
    
    this(Gui gui_, string label_ = "default", Vector2f pos_ = Vector2f(5,5), Vector2f size_ = Vector2f(100,30)){
        super(gui_);

        m_type = "button";
        m_position = Vector2f(0,0);
        m_color = Color(128,128,128);

        text = new Text();
        text.setFont(gui.fonts["default"]);
        text.setCharacterSize(14);
        text.fillColor = (Color.White);
        text.string = "test";
        
        rect = new RoundedRectangle();
        rect.radius = 5;
        rect.cornerCount = 4;
        rect.fillColor = color;

        label = label_;
        value = "";
        size = size_;
        position = pos_;
    }

    override void onDraw(RenderTarget target, Vector2f offset){
        auto drawpos = position + offset;
        rect.position = drawpos;
        rect.size = m_size;

        auto bounds = text.getGlobalBounds();
        Vector2f textSize = Vector2f(bounds.width,bounds.height);
        Vector2f midpoint = m_size/2;
        Vector2f textpos = midpoint - (textSize / 2) - Vector2f(0,3);
        
        
        text.position = drawpos + textpos;

        target.draw(rect);
        target.draw(text);
    }
}