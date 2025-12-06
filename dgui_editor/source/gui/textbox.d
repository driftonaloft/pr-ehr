module gui.textbox;

import std.stdio;
import std.string;
import std.utf;

import nudsfml.graphics;

import gui.widget;
import gui.system;

import util;
import gfx;

class TextBox : Widget {
    RoundedRectangle rect; //replace with rounded rectangle
    RectangleShape cursor;
    Text t;
    string m_text;
    ulong cursor_pos;

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
        this(gui_, "TextBox", Vector2f(0,0), Vector2f(100,20));
    }

    this(GuiSystem gui_, string text_) {
        this(gui_, text_, Vector2f(0,0), Vector2f(100, 20));
    }

    this(GuiSystem gui_, string text_, Vector2f position_) {
        this(gui_, text_, position_, Vector2f(100, 20));
    }

    this(GuiSystem gui_, string text_, Vector2f position_, Vector2f size_) {
        super(gui_);

        m_size =  size_;
        m_position = position_;
        m_text = text_;

        rect = new RoundedRectangle();
        rect.size = size;
        rect.position = position;
        rect.fillColor = gui.theme["textbox"];
        rect.outlineColor = gui.theme["textbox_outline"];
        rect.outlineThickness = 1.0f;

        cursor = new RectangleShape();
        cursor.size = Vector2f(1, 13);
        cursor.position = Vector2f(0, 0);
        cursor.fillColor = gui.theme["textbox_cursor"]; 

        t = new Text();
        t.setFont(gui.fonts["default"]);
        t.setColor(gui.theme["text"]);
        t.setCharacterSize(13);
        t.setString(m_text);
    }

    override void onClick(Vector2f mouse_position) {
        super.onClick(mouse_position);
        writeln("Button clicked");
    }

    override void handleEvents(Event e){
        super.handleEvents(e);
        switch(e.type){
            case Event.Type.TextEntered: 
                switch(e.text.unicode){
                    case '\b': //backspace
                        if(cursor_pos > 0){
                            m_text = m_text.subString(0, cursor_pos-1) ~ m_text.subString(cursor_pos);
                            cursor_pos--;
                        }
                        break;
                    case '\n':  //enter
                        break;
                    case '\r': //enter
                        //event compleated // submit ?
                        break;
                    case '\t': //tab // should advance tabstop? // sort children by tabstop index and then advance focus
                        break;
                    case 27: //escape
                        break;
                    case 127: //delete
                        if(cursor_pos < m_text.length){
                            m_text = m_text.subString(0, cursor_pos) ~ m_text.subString(cursor_pos+1);
                        }
                        break;
                    default:
                        string head = m_text.subString(0, cursor_pos);
                        head ~= e.text.unicode;
                        m_text = head ~ m_text.subString(cursor_pos, m_text.length);
                        cursor_pos++;           
                        break;
                }
                t.setString(m_text);
                break;
            case Event.Type.KeyPressed:
                switch(e.key.code){
                    case Keyboard.Key.Left:
                        if(cursor_pos > 0){
                            cursor_pos--;
                        }
                        break;
                    case Keyboard.Key.Right:
                        if(cursor_pos < m_text.length){
                            cursor_pos++;
                        }
                        break;
                    case Keyboard.Key.Home:
                        cursor_pos = 0;
                        break;
                    case Keyboard.Key.End:
                        cursor_pos = m_text.length;
                        break;
                    default:
                        break;
                } 
                break;

            default: 
                break;
        }
    }

    override void drawSelf(RenderTarget target, Vector2f offset) {
        auto pos = position;
        
        rect.position = pos + offset;
        
        auto t_pos = pos + offset + Vector2f(5, 2);
        t.position  = t_pos;

        target.draw(rect);
        target.draw(t);
        if(hasFocus){
            auto cpos = t.findCharacterPos(cursor_pos);
            cursor.position = cpos;
            target.draw(cursor);
        }
    }
}