module gui.richtextbox;

import std.array;
import std.string;
import std.conv;
import std.stdio;
import std.algorithm;

import gui.system;
import gui.widget;

import util;

import nudsfml.graphics;

import gfx;

class RichTextBox : Widget {
    RoundedRectangle rect;
    RectangleShape cursor;
    Text debugText;

    string rawText;
    Line [] lines; // formatted text

    ulong cursorLine;
    ulong cursorColumn;

    this(GuiSystem gui_, Vector2f position_, Vector2f size_) {
        super(gui_, position_, size_);

        rect = new RoundedRectangle();
        rect.fillColor(gui.theme["textbox"]);
        //rect.setCornerRadius(5);
        rect.position(position_);
        rect.size(size_);

        cursor = new RectangleShape();
        cursor.fillColor(gui.theme["text"]);

        debugText = new Text(format("Line: %4d Col: %4d",0,0), gui.fonts["default"], 12);
        debugText.position( position + Vector2f(0,size.y - 15));
        debugText.setColor(gui.theme["text"]);
        
    }

    override void handleEvents(Event e){
        switch(e.type) {
            case Event.Type.KeyPressed:
                switch(e.key.code){
                    case Keyboard.Key.Left:
                        if( cursorColumn > 0){
                            cursorColumn--;
                        } else {
                            if( cursorLine > 0){
                                cursorLine--;
                                cursorColumn = lines[cursorLine].visibleLine.length;
                            }
                        }
                        break;
                    case Keyboard.Key.Right:
                        if( cursorColumn < lines[cursorLine].visibleLine.length - 1){
                            cursorColumn++;
                        } else {
                            if( cursorLine < lines.length - 1 ){
                                cursorLine++;
                                cursorColumn = 0;
                            }
                        }
                        break;
                    case Keyboard.Key.Up:
                        if( cursorLine > 0 ){
                            cursorLine--;
                            if( cursorColumn > lines[ cursorLine ].visibleLine.length ){
                                cursorColumn = lines[ cursorLine ].visibleLine.length;
                            }
                        }
                        break;
                    case Keyboard.Key.Down:
                        if( cursorLine < lines.length.to!long - 1 ){
                            cursorLine++;
                            if( cursorColumn > lines[ cursorLine ].visibleLine.length ){
                                cursorColumn = lines[ cursorLine ].visibleLine.length;
                            }
                        }
                        break;
                    default:
                        break;
                }
                break;
            case Event.Type.TextEntered:
                switch( e.text.unicode ){
                    case '\b':
                        if( cursorColumn > 0 ){
                            lines[ cursorLine ].remove( cursorColumn - 1);
                            cursorColumn--;
                        }
                        break;
                    case '\n':
                        if(cursorLine < lines.length.to!long - 1){
                            cursorLine++;
                            cursorColumn = 0;
                        }
                        break;
                    case 127: // delete
                        if(cursorColumn < lines[cursorLine].visibleLine.length){
                            lines[ cursorLine ].remove(cursorColumn);
                        }
                        break;
                    default:
                        //writeln("raw unicode: ", e.text.unicode.to!int);
                        string text = e.text.unicode.to!string;
                        lines[cursorLine].insert(text, cursorColumn);
                        cursorColumn++;
                        break;
                }
                break;
            default:
                break;
        }
        validatePosition();
    }

    bool validatePosition(){
        if( cursorLine < lines.length.to!long ){
            if( cursorColumn < lines[cursorLine].visibleLine.length ){
                //cursor.position( position + Vector2f(lines[cursorLine].visibleLine[cursorColumn].position,0) );
                //cursor.size( Vector2f(lines[cursorLine].visibleLine[cursorColumn].size,size.y) );
                return true;
            }
        } else {
            cursorLine = min(cursorLine, lines.length.to!long - 1);
            cursorColumn = min(cursorColumn, lines[cursorLine].visibleLine.length);
        }
        return false;
    }

    void parseText(string input) {
        lines.length = 0;
        rawText = input;
        string [] rawlines = input.split("\n");

        TextFormat textFormat = TextFormat(gui.fonts[ "default" ],"default",12,gui.theme["text"]);

        foreach(rawline ; rawlines){
            Line l = new Line(gui, rawline.strip, 12,textFormat);
            textFormat = l.currentTextFormat;
            lines ~= l;
        }
    }

    override void onClick(Vector2f point){
        auto pos = getReleativePoint(point);
        int height = 0;

        foreach(i, line ; lines){
            height += line.height;
            if(height > pos.y){
                cursorLine = i;
                float x = 0;
                int l = 0;

                foreach(j, text ; line.visibleText){
                    foreach(k, c ; text.text){
                        float advance = text.format.font.getGlyph(c, text.format.size, false).advance;
                        x += advance;
                        if(x > pos.x){
                            break;
                        }
                        l++;
                    }
                }

                cursorColumn = l;
                break;
            }
        }    
    }

    override void drawSelf(RenderTarget target, Vector2f offset ){
        rect.position = position + offset;
        target.draw(rect);
        auto textOffset = offset;
        foreach(line ; lines){
            line.calcPositions(position + textOffset);
            foreach(text ; line.texts){
                target.draw(text);
            }
            textOffset += Vector2f(0, line.height);
        }

        if(hasFocus){
            cursor.position(lines[cursorLine].getTextPosition(cursorColumn));
            cursor.size(Vector2f(3, lines[cursorLine].height));
            target.draw(cursor);
        }

        if(gui.isDebug){
            auto l = lines[ cursorLine ].getFormatAtIndex(cursorColumn);
            debugText.setString(format( "Line:%4d Col:%3d format: %s ", cursorLine, cursorColumn, l));
            debugText.position = position + offset + Vector2f(5,size.y - 15);
            target.draw(debugText);
        }
    }
}

struct TextFormat {
    Font font;
    string fontID = "default";
    int size;
    Color color;
    //alignment ? enum line specific  formating ? 

    enum {
        ID_HEX,
        ID_RGB,
        ID_NAMED
    }    
    string getFormat(int colorIDType = 0){
    
        string colorID = "";
        final switch(colorIDType){
            case ID_RGB:
                 colorID = format("#%x%x%x", color.r, color.g, color.b);
                 break;
            case ID_HEX:
                colorID = format("%d:%d:%d", color.r, color.g, color.b);
                break;
            case ID_NAMED:
                colorID = "not implemented";
                break;
        }
        string formated = format("{font:%s:size:%d:color:%s}",fontID,size,colorID); 
        return formated;
    }
}

struct TextBlock {
    string text;
    TextFormat format;
}

class Line {
    GuiSystem gui;
    int height;

    enum Alignment {
        Left,
        Center,
        Right
    }

    Alignment alignment = Alignment.Left;

    Text [] texts;
    TextBlock [] visibleText;
    
    string visibleLine;
    string line;
    
    
    TextFormat currentTextFormat;

    this(GuiSystem gui_ , string line, int  height, TextFormat format_ ) {
        currentTextFormat = format_;
        this.line = line;
        this.height = height;
        gui = gui_;

        if(line.length) {
            parseLine(line);
        }
    }

    TextFormat parseLine(string line_ = line, TextFormat  tf = currentTextFormat) {
        parseLine(line_);
        return currentTextFormat;
    }

    string getFormattedString() {
        string str = "";
        foreach(t ;  visibleText) {
            str ~= t.format.getFormat();
            str ~= t.text;
        }
        return str;
    }   

    final void parseLine(string line_ = line ) {
        visibleLine = "";
        texts.length = 0;

        if(line != line_ ){
            line = line_;
        }

        height = currentTextFormat.size;

        string buffer;
        for(long i = 0; i < line.length; i++){
            switch(line[i]) {
                case '{':   //if there is a { then we are in a format block
                    if (line[i + 1] == '{') {
                        buffer ~='{';
                        i++;
                    } else {
                        auto k = line.indexOf('}',i+1);
                        string commandBuffer = subString(line, i + 1, k); // grab the command buffer from the string 
                        TextFormat textFormat = getTextFormat(commandBuffer, currentTextFormat); // get the text format from the command buffer
                        if(buffer.length ){ //if there is data in the buffer add it to the visible line and create a text object
                            visibleText ~= TextBlock( buffer, currentTextFormat);
                            Text t = createText(buffer, currentTextFormat);                        
                            texts ~= t;
                            buffer = ""; // clears buffer
                        }

                        i = k; // move the index to the end of the format block
                        currentTextFormat = textFormat; // set the current text format to the new one
                    }
                    break;
                default:
                    buffer ~= line[i];
                    visibleLine ~= line[i];
                    break;
            }
        }

        if(buffer.length){ 
            visibleText ~= TextBlock(buffer, currentTextFormat);
            Text t = createText(buffer,currentTextFormat);
            texts ~= t;
        }

        calcPositions();
    }

    TextFormat getTextFormat(string commandBuffer, TextFormat currentTextFormat) {
        TextFormat textFormat = currentTextFormat;
        writeln(commandBuffer);
        string [] tokens = commandBuffer.split(':');
        for(int j = 0 ; j < tokens.length; j++){
            if(tokens[j].strip() == "font"){
                //textformat.font = gui.getFont(tokens[i+1].strip());
            }
            if(tokens[j].strip() == "size"){
                int s = tokens[j+1].strip().to!int();
                textFormat.size = s;
                if (s > height) {
                    height = s;
                }
            }
            if(tokens[j].strip() == "color"){
                string color = tokens[j+1].strip();
                //TODO: impliment colorList usage example colorList["red"] = Color(255,0,0);
                if (color[0] == '#') {
                    textFormat.color = colorFromHex(color);
                } else {
                    textFormat.color = Color(   tokens[j+1].strip.to!ubyte, // r 
                                                tokens[j+2].strip.to!ubyte, // g
                                                tokens[j+3].strip.to!ubyte); // b
                    j += 3; 
                }
            }               
        }
        return textFormat;
    }

    Vector2f getTextPosition(ulong index) {
        Vector2f pos = Vector2f(0,0);
        foreach(i, t ; visibleText ) {
            if(index > t.text.length){
                index -= t.text.length;
            } else {
                if (i < texts.length) {
                    pos = texts[i].findCharacterPos(index);
                    break;
                }
            }
        }
        return pos;
    }

    TextFormat getFormatAtIndex(ulong index){
        TextFormat format = currentTextFormat;
        foreach(i, t ; visibleText ) {
            if(index >= t.text.length){
                index -= t.text.length;
            } else {
                if (i < t.text.length) {
                    format = t.format;
                    break;
                }
            }
        }
        return format;
    }

    Text createText(string text, TextFormat textFormat) {
        if(text.length == 0){
            return null;
        }

        Text t = new Text();
        t.setFont(textFormat.font);
        t.setCharacterSize(textFormat.size);
        t.setColor(textFormat.color);
        t.setString(text);
        
        return t;
    }

    void calcPositions(Vector2f offset = Vector2f(0,0)) {
        int x = 5;
        int y = 5;

        for(int i = 0; i < texts.length; i++) {
            int h = visibleText[i].format.size;
            int offsety = (height - h); 
            auto tempOffset  = Vector2f (0, offsety);
            string text = texts[i].getU8String();
            //y = 5;//abs(texts[i].getLocalBounds().height.to!int - height);
            texts[i].position = Vector2f(x,y) + offset + tempOffset;

            //writeln( format("text[%d] = %s @ pos( %d, %d )", i, texts[i].getString(), x, y));

            x += texts[i].getLocalBounds().width.to!int;
        }
    }

    void insert(string text, ulong index) {
       /* if (index <= visbleLine.length){
            int tempIndex = index;
            int i = 0;
            while (tempIndex < visibleText[i].text.length) {
                tempIndex -= visibleText[i].text.length;
                i++;
            }
            if(tempIndex >= 0){
                visibleText[i].text.insert(tempIndex, text);
                visibleLine.insert(index, text);
             
            }
        }*/
    //    line = subString(line,0,index) + text + subString(line,index);
        parseLine(line);
    }

    void remove(ulong index, ulong length = 1) {
    //    line = subString(line,0,index) + subString(line,index + length);
        parseLine(line);
    }
}