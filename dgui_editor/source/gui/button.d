module gui.button;

import std.stdio;

import nudsfml.graphics;

import gui.widget;
import gui.system;


class Button : Widget {
    RectangleShape rect; //replace with rounded rectangle
    Text t;
    string m_text;

    @property { //text
        string text(string text_) {
            m_text = text_;
            t.setString(text_);
            return m_text;
        }

        string text() {
            return m_text;
        }   
    }

    @property { //position
        override Vector2f position(Vector2f position_) {
            m_position = position_;
            return m_position;
        }
        override Vector2f position() {
            return m_position;
        }
    }

    @property { //size
        override Vector2f size(Vector2f size_) {
            m_size = size_;
            rect.size = m_size;
            return m_size;
        }
        override Vector2f size() {
            return m_size;
        }
    }


    this(GuiSystem gui_) {
        this(gui_, "Button", Vector2f(0,0), Vector2f(100,20));
    }

    this(GuiSystem gui_, string text_) {
        this(gui_, text_, Vector2f(0,0), Vector2f(100, 20));
    }

    this(GuiSystem gui_, string text_, Vector2f position_) {
        this(gui_, text_, position_, Vector2f(100, 20));
    }

    this(GuiSystem gui_, string text_, Vector2f position_, Vector2f size_) {
        writeln("Button constructor");
        super(gui_);
        writeln("Button constructor 2");

        m_size =  size_;
        m_position = position_;
        m_text = text_;

        rect = new RectangleShape();
        rect.size = size;
        rect.position = position;
        rect.fillColor = gui.theme["button"];
        rect.outlineColor = gui.theme["button_outline"];
        rect.outlineThickness = 1.0f;

        t = new Text();
        //t.setString = name;
        t.setFont(gui.fonts["default"]);
        t.setColor(gui.theme["text"]);
       // t.setColor(Color.White);
        t.setCharacterSize(13);
        t.setString(m_text);
    }

    override void onClick(Vector2f mouse_position) {
        super.onClick(mouse_position);
        writeln("Button clicked");
    }

    override void drawSelf(RenderTarget target, Vector2f offset) {
        auto pos = position;
        
        rect.position = pos + offset;
        
        auto t_pos = pos + offset + Vector2f(size.x/2, size.y/2) - Vector2f(t.getLocalBounds().width/2, (t.getLocalBounds().height/2) + 3);
        t.position  = t_pos;

        target.draw(rect);
        target.draw(t);
    }


}