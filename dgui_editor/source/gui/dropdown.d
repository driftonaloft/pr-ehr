module gui.dropdown;

import std.stdio;
import std.string;
import std.utf;
import std.algorithm;
import std.conv;

import nudsfml.graphics;

import gui.widget;
import gui.system;

import util;
import gfx;

class DropDownBox : Widget {
    RoundedRectangle rect; //replace with rounded rectangle
    RoundedRectangle dropdownbutton;
    RectangleShape cursor;
    Text t;
    Text startsWith;

    string m_text;
    string [] m_items;
    long cursor_pos;

    bool m_open;
    bool m_match;

    @property { //text
        string text() { 
            return m_text; 
        }
        string text(string v) { 
            m_text = v;
            t.setString(m_text);
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

            dropdownbutton.size = Vector2f(m_size.y, m_size.y);
            dropdownbutton.position = position + Vector2f(size.x - size.y, 0);
            return m_size;
        }
        override Vector2f size() {
            return m_size;
        }
    }


    this(GuiSystem gui_) {
        this(gui_, ["DropDownBox"], Vector2f(0,0), Vector2f(100,20));
    }

    this(GuiSystem gui_, string [] text_) {
        this(gui_, text_, Vector2f(0,0), Vector2f(100, 20));
    }

    this(GuiSystem gui_, string [] text_, Vector2f position_) {
        this(gui_, text_, position_, Vector2f(100, 20));
    }

    this(GuiSystem gui_, string [] text_, Vector2f position_, Vector2f size_) {
        super(gui_);

        m_size =  size_;
        m_position = position_;
        m_items = text_;

        rect = new RoundedRectangle();
        rect.size = size;
        rect.position = position;
        rect.fillColor = gui.theme["textbox"];
        rect.radius = 5;
        rect.outlineColor = gui.theme["textbox_outline"];
        rect.outlineThickness = 1.0f;

        cursor = new RectangleShape();
        cursor.size = Vector2f(1, 13);
        cursor.position = Vector2f(0, 0);
        cursor.fillColor = gui.theme["textbox_cursor"]; 

        dropdownbutton = new RoundedRectangle();
        dropdownbutton.size = Vector2f(size.y, size.y);
        dropdownbutton.position = position + Vector2f(size.x - size.y, 0);
        dropdownbutton.fillColor = gui.theme["button"];
        dropdownbutton.radius = 5;
        dropdownbutton.outlineColor = gui.theme["textbox_outline"];
        dropdownbutton.outlineThickness = 1.0f;
        dropdownbutton.topLeft = false;
        dropdownbutton.bottomLeft = false;
    


        t = new Text();
        t.setFont(gui.fonts["default"]);
        t.setColor(gui.theme["text"]);
        t.setCharacterSize(13);
        if(m_items.length){
            m_text = m_items[0];
            t.setString(m_text);
        }

        startsWith = new Text();
        startsWith.setFont(gui.fonts["default"]);
        startsWith.setColor(gui.theme["text"]);
        startsWith.setCharacterSize(13);
        startsWith.setString("Starts with: ");
    }

    void addItem(string item) {
        m_items ~= item;
    }

    string getItem(int index){
        return m_items[index];
    }

    void removeItem(int index) {
        m_items.remove(index);
    }

    string [] itemsStartWith (string key){
        string [] result;
        foreach(item ; m_items){
            if(item.startsWith(key)){
                result ~= item;
            }
        }
        return result;
    }

    override void onClick(Vector2f mouse_position) {
        super.onClick(mouse_position);

        auto rel_pos = getReleativePoint(mouse_position);
        if(rel_pos.y > 0 && rel_pos.y < m_size.y && rel_pos.x > m_size.x - m_size.y && rel_pos.x <  m_size.x) {
            m_open = !m_open;
        }
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

        dropdownbutton.position = pos+offset + Vector2f(size.x - size.y, 0);
        dropdownbutton.size = Vector2f(size.y, size.y);
        
        target.draw(dropdownbutton);

        if(hasFocus){
            auto cpos = t.findCharacterPos(cursor_pos);
            cursor.position = cpos;
            target.draw(cursor);

            if(m_open){
                auto s_pos = pos + offset + Vector2f(5, 20);


                foreach(s ; itemsStartWith(m_text)){
                    startsWith.setString(s);
                    startsWith.position = s_pos;
                    target.draw(startsWith);
                    s_pos.y += startsWith.getLocalBounds().height;
                }
                startsWith.position = s_pos;
                target.draw(startsWith);
                s_pos.y += 15;
            }
        }
    }
}