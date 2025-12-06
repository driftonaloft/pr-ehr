module gui.textbox;

import nudsfml.graphics;
import gui;
import std.algorithm;
import std.uni;
import std.stdio;
import util.string;



class TextBox : Widget {
    RectangleShape tb;
    RectangleShape curse;
    Text t;

    bool m_password;
    string m_displayText;

    alias value = Widget.value;
    @property { //value
        override string value(string input){
            m_value = input;
            if(m_password == true){
                m_displayText = stringFill("*", m_value.length);
            } else {
                m_displayText = m_value;
            }
            return m_value;
        }
        override string value(){
            return m_value;
        }
    }

    @property { // password
        bool password( bool b){
            m_password = b;
            if(m_password == true){
                m_displayText = stringFill("*", m_value.length);
            } else {
                m_displayText = m_value;
            }

            return b;
        }
        bool password(){
            return m_password;
        }
    }
    
    this(Gui gui_, string id_,Vector2f pos_ = Vector2f(5,5), Vector2f size_ = Vector2f(100,20), string value_ = "default"){
        super(gui_);
        m_id = id_;
        m_type = "TextBox";

        curse = new RectangleShape();

        tb = new RectangleShape();
        tb.fillColor = Color(60, 60, 60);
        tb.outlineColor = Color(140, 140, 140);
        tb.outlineThickness = 1;

        t = new Text();
        t.setFont(gui.fonts["default"]);
        t.setCharacterSize(14);
        t.fillColor = (Color.White);

        curse.fillColor = Color(255,255,255,64);
        curse.size = Vector2f(8,16);

        size = size_;
        position = pos_;
        value = value_;
    }

    override void onClick(Event e){
        import std.conv;
        super.onClick(e);

        Vector2i point = Vector2i(e.mouseButton.x, e.mouseButton.y);
        point = this.getReleativePosition(point);

        auto s = t.string;

        Vector2i firstPos = Vector2i(   t.findCharacterPos(0).x.to!int , 
                                        t.findCharacterPos(0).y.to!int);

        int i;
        for(i = 1; i < s.length; i++ ) {
            Vector2i secondPos = Vector2i(  t.findCharacterPos(i).x.to!int , 
                                            t.findCharacterPos(i).y.to!int);
            IntRect characterBox = IntRect( firstPos.x, 
                                            firstPos.y, 
                                            secondPos.x - firstPos.x , 
                                            secondPos.y + 14 - firstPos.y);
            if(characterBox.contains(point)) {
                writeln("cursorindex: ", i, " - ", firstPos );
                i = i - 1;
                break;
            }
            
            firstPos = secondPos;
        }
        
        cursor = i;
        if(cursor < 0){
            cursor = 0;
        } else if (cursor > m_value.length) {
            cursor = cast(int)(m_value.length);
        }
    }

    override void onDraw(RenderTarget target, Vector2f offset){
        tb.size = size;
        tb.position = position + offset;
        target.draw(tb);

        t.setString (m_displayText);


        t.position = position + offset + Vector2f(3,2);
        if(hasFocus && !locked){
            if(cursor <=0) cursor = 0;
            if(cursor > value.length) cursor = cast(int)(value.length);

            Vector2f cpos = t.findCharacterPos(cursor);
            curse.position = t.position + cpos + Vector2f(0,2);
            target.draw(curse);
        }
        target.draw(t);
    }

    override void onText(Event e){
        if(!locked ){
            char c = cast(char) (e.text.unicode);
            if(c == '\b') {
                if(m_value.length > 0 && cursor > 0) {
                    string temp = m_value[0..(cursor-1)];
                    temp ~= m_value[cursor..m_value.length];
                    value = temp;
                    cursor--;
                } 
            } else if ( c == 127) {
                if(m_value.length >0){
                    if(cursor >= m_value.length){
                        cursor = cast(int)(m_value.length);
                    } else {
                        string temp = m_value[0..cursor];
                        temp ~= m_value[cursor+1..m_value.length];
                        value = temp;
                    }
                }
            } else if(isGraphical(c)) {
                writeln(c);

                writeln(m_value);

                string temp = m_value[0..cursor];
                temp ~=c;
                temp ~= m_value[cursor..m_value.length];

                value = temp;

                cursor++;
            }
        
            if(cursor < 0){
                cursor = 0;
            } else if (cursor > m_value.length) {
                cursor = cast(int)(m_value.length);
            }
        }
    }
}