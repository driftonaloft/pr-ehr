module gui.label;

import std.stdio;
import std.conv;

import nudsfml.graphics;

import gui.system;
import gui.widget;

//create class called label based on button
class Label : Widget {
    Text t;
    string m_text;

    @property { //text
        string text(string text_){
            m_text = text_;
            t.setString(text_);
            return m_text;
        }

        string text(){
            return m_text;
        }
    }

    @property { //font
        Font font(Font font_){
            t.setFont(font_);
            return font_;
        }

        
    }

    @property { //font size
        override Vector2f size(Vector2f size_){
            m_size = size_;
            t.setCharacterSize(size_.y.to!int());
            return m_size;
        }

        override Vector2f size(){
            return m_size;
        }
    }


   this(GuiSystem gui_, string text_, Vector2f pos_){
        this(gui_, text_, pos_, Vector2f(0,0));

    }
    
    this(GuiSystem gui_, string text_, Vector2f pos_, Vector2f size_) {
        super(gui_);
        m_size = size_;
        m_position = pos_;
        m_text = text_;
        t = new Text(text_, gui.fonts["default"], size_.y.to!int());
        t.position = pos_ ;
        t.setColor(Color.White);

        writeln("label string: ", t.getString());
    }
    
    override void drawSelf(RenderTarget target, Vector2f offset) {
        auto pos = position + offset;
           
        t.position  = pos;

        target.draw(t);
    }
}