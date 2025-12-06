module dgui.widgets.textbox;

import std.string;
import std.utf;

import nudsfml.graphics;

import dgui.graphics.roundedrectangle;
import dgui.widget;
import dgui.handler;

import util.string;

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

    /*@property { //position
        override Vector2f position(Vector2f position_) {
            m_position = position_;
            return m_position;
        }
        override Vector2f position() {
            return m_position;
        }
    }
    */

    @property { //size
        override Vector2f size(Vector2f value) {
            mSize = value;
            rect.size = value;
            return mSize;
        }
        override Vector2f size() {
            return mSize;
        }
    }


    this(Handler handler) {
        this(handler, "TextBox", Vector2f(0,0), Vector2f(100,20));
    }

    this(Handler handler, string text_) {
        this(handler, text_, Vector2f(0,0), Vector2f(100, 20));
    }

    this(Handler handler, string text_, Vector2f position_) {
        this(handler, text_, position_, Vector2f(100, 20));
    }

    this(Handler handler_, string text_, Vector2f position_, Vector2f size_) {
        super(handler_, position_, size_);

        rect = new RoundedRectangle();
        rect.size = size;
        rect.position = position;
        rect.fillColor = handler.colors["textbox"];
        rect.outlineColor = handler.colors["textbox_outline"];
        rect.outlineThickness = 1.0f;

        cursor = new RectangleShape();
        cursor.size = Vector2f(8, 13);
        cursor.position = Vector2f(0, 0);
        cursor.fillColor = handler.colors["textbox_cursor"] - Color(0, 0, 0, 128); 

        t = new Text();
        t.setFont(handler.font);
        t.setColor(handler.colors["text"]);
        t.setCharacterSize(13);
        t.setString(m_text);
    }

    override string onTextEntered(Event e){
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

        return super.onTextEntered(e);
    }

    override string onKeyPressed(Event e){
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
        return super.onKeyPressed(e);
    }

/*    override void handleEvents(Event e){
        super.handleEvents(e);
        switch(e.type){
            case Event.EventType.TextEntered: 
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
            case Event.EventType.KeyPressed:
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
    } */

    override void onDraw(RenderTarget target, Vector2f offset) {
        auto pos = position;
        
        rect.position = pos + offset;
        
        auto t_pos = pos + offset + Vector2f(5, 2);
        t.position  = t_pos;

        target.draw(rect);
        target.draw(t);
        if(hasFocus){
            auto cpos = t.findCharacterPos(cursor_pos);
            cursor.position = cpos + t_pos;
            target.draw(cursor);
        }
    }
}

unittest {
    import util.debugwindow;
    import dgui.widgets;
    import std.stdio;

    writeln("Testing TextBox");

    auto dbgwin = new DebugWindow("TextBox", 1f);

    Handler handler = new Handler(dbgwin.win);

    auto frame = new Frame(handler);
    frame.position = Vector2f(10, 10);
    frame.size = Vector2f(200, 200);
    handler.registerChild(frame);

    auto textbox = new TextBox(handler, "Hello World", Vector2f(10, 10));
    frame.registerChild(textbox);

    dbgwin.eventDelegate = delegate(Event e){
        handler.handleEvent(e);
    };
    dbgwin.updateDelegate = delegate(float dt){
        handler.update(dt);
    };
    dbgwin.drawDelegate = delegate(target){
        handler.draw();
    };

    dbgwin.run();
}