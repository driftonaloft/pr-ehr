module gui.console;

import std.uni;
import std.format;
import std.stdio;
import std.array;
import core.vararg;

import nudsfml.graphics;

import gui;
import gfx;
import util.command;

class Console : Widget {
    string [] lines;
    string prompt;

    int index = 0;
    int visableLines;

    Text drawText;
    RoundedRectangle rect;
    RectangleShape cursorRect;

    @property { // size 
        override Vector2f size (Vector2f s){
            m_size = s;
            rect.size = m_size;
            //TODO!  check to see if this should be 2 so that the prompt can fit
            visableLines = (cast(int)(m_size.y) / 15) - 1; 
            return m_size;
        }
    }
    alias size = Widget.size;

    this (Gui gui_,Vector2f size_ = Vector2f(640,200)) {
        super(gui_);

        m_type = "console";
        drawText = new Text();
        drawText.setFont(gui.fonts["default"]);
        drawText.fillColor = (gui.theme["text"]);
        drawText.setCharacterSize(13);

        rect = new RoundedRectangle();
        rect.fillColor = Color(30,30,30);
        rect.outlineColor = Color(140,140,140);
        rect.outlineThickness = 1;
        rect.cornerCount = 4;
        rect.radius = 5;

        cursorRect = new RectangleShape;
        cursorRect.fillColor = Color.Transparent;
        cursorRect.outlineColor = Color(200,200,200);
        cursorRect.size = Vector2f(8,15);
        cursorRect.outlineThickness = 1;

        size = size_;
    }

    override void onDraw(RenderTarget target, Vector2f offset){
        Vector2f drawpos = position + offset;
        rect.position = drawpos;
        
        target.draw(rect);

        Vector2f textpos = drawpos + Vector2f(5,0);
        for(int i = 0; i < visableLines; i++){
            auto ipos = i+index;
            if(ipos < lines.length){
                drawText.position = textpos;
                drawText.string = lines[ipos];
                target.draw(drawText);
                textpos += Vector2f(0,15);
            } else {
                break;
            }
        }
        drawText.position = textpos;
        drawText.string = ":> " ~ prompt;

        if(hasFocus){
            cursorRect.position = drawText.findCharacterPos(cursor+3);
            target.draw(cursorRect);
        }

        target.draw(drawText);
    }

    void print(A...)(string fmtstring, A args){ //look at making it a pass through for writeln/ sprintf/ equivalent
        auto val = format(fmtstring, args);
        //auto startpoint = lines.length;
        lines ~= split(val,"\n");
        if(lines.length > visableLines){
            index = cast(int)(lines.length - visableLines);
        }
    }

    override void onKeyReleased(Event e){
        if(e.key.code == Keyboard.Key.Return){
            print(prompt);
            string retval = parse(prompt);
            print(retval);
            prompt.length = 0;
        }
        if(e.key.code == Keyboard.Key.Up){ //scroll through commands history

        }
        if(e.key.code == Keyboard.Key.Down){ //scroll through command history

        }
        super.onKeyReleased(e);
    }

    override void onScrollWheel (Event e){
        index += e.mouseWheel.delta;
        if(cast(int)(lines.length)-1 < index) {
            index = cast(int)(lines.length) - 1;
        }
        if(0 > index ){
            index = 0;
        }
        super.onScrollWheel(e);
    }

    override void onText(Event e){
        char c = cast(char) (e.text.unicode);
        if(c == '\b') {
            if(prompt.length > 0 && cursor > 0) {
                string temp = prompt[0..(cursor-1)];
                temp ~= prompt[cursor..prompt.length];
                prompt = temp;
                cursor--;
            } 
        } else if ( c == 127) {
            if(prompt.length >0){
                if(cursor >= prompt.length){
                    cursor = cast(int)(prompt.length);
                } else {
                    string temp = prompt[0..cursor];
                    temp ~= prompt[cursor+1..prompt.length];
                    prompt = temp;
                }
            }
        } else {
            if(isGraphical(c)) {
                if(cursor > prompt.length){
                    cursor =cast(int)( prompt.length);
                }
                string temp = prompt[0..cursor];
                temp ~=c;
                temp ~= prompt[cursor..prompt.length];
                prompt = temp;
                cursor++;
            }
        }
        value = prompt;

        if(cursor < 0){
            cursor = 0;
        } else if (cursor > prompt.length) {
            cursor = cast(int)(prompt.length);
        }
    }
}

