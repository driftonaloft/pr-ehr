module gui.mltextbox;

import gui.system;
import gui.widgets;
import gfx.roundedrectangle;

import nudsfml.graphics;
import nudsfml.window.clipboard;

import std.array;
import std.stdio;
import std.conv;

import util.array;
import util.string;

class MultilineTextbox : Widget {
    RoundedRectangle m_background;
    RectangleShape cursorLoc;
    RectangleShape selectionBox;
    Text t;
    bool locked = false;
    bool wordwrap = false;

    int currentLine = 0;

    string m_text;
    string [] lines;

    long selectLineStart;
    long selectCursorStart;
    long selectLineEnd;
    long selectCursorEnd;

    this (Gui gui_, string id_, string text_ ="", Vector2f pos_ = Vector2f(0,0), Vector2f size_ = Vector2f(320,240)) {
        import std.string;

        super(gui_);

        t = new Text();
        t.setFont(gui.fonts["default"]);
        t.characterSize = 12;
        t.fillColor = Color.White; //TODO: get via theme;

        m_background = new RoundedRectangle(size_);
        m_background.fillColor = Color(64,64,64,255);//TODO: get via theme;
        m_background.outlineColor = Color(128,128,128,255);//TODO: get via theme;
        m_background.outlineThickness = 1;

        cursorLoc = new RectangleShape();
        cursorLoc.size = Vector2f(6,12);
        cursorLoc.fillColor = Color(128,128,128,64);
        cursorLoc.outlineColor = Color(255,255,255,128);
        cursorLoc.outlineThickness = 1;

        selectionBox = new RectangleShape();
        selectionBox.fillColor = Color(0,0,0,128);
        selectionBox.outlineColor = Color(192,192,192,255);

        id = id_;
        position = pos_;
        size = size_;

        text = text_;
        lines = text.split("\n");
    }

    @property {
        string text(string v){
            m_text = v;
            lines = v.split("\n");
            return v;
        }

        string text(){
            return lines.join("\n");
        }
    }

    @property {
        override string value(string v){
            m_text = v;
            return v;
        }

        override string value(){
            return m_text;
        }
    }
    alias value = Widget.value;

    void absoluteCursorConverstion(long position, out long line, out long cursorpos){
        int l;
        int cp;

        while (position >= lines[l].length && position >= 0){
            position -= lines[l].length + 1;
            l++;
            if(l >= lines.length ){
                line = -1;
                cursorpos = -1;
                return;
            }
        }
        
        line = l;
        cursorpos = position;
    }

    long lineCursorConversion(int line, int cursorPos , bool attemptCursorPosOvershootConversion = false){
        //code reduction function
        long addSection ( int l, int cp) {
            long retval = 0;
            for(int i = 0 ; i < l; i ++){
                retval += lines[i].length;
            }
            retval += cp + l;
            return retval;
        }

        long charPos =-1;
        if ( line >= 0 && line < lines.length ){
            string theLine = lines[line];
            if(cursorPos >= 0 && cursorPos <= theLine.length ){
                charPos = addSection(line, cursorPos);
            } else {
                if(attemptCursorPosOvershootConversion){
                    while ( cursorPos >= lines[line].length ){
                        cursorPos -= lines[line].length;
                        line++;
                        if(line >= lines.length){
                            return charPos;
                        }
                    }
                    charPos = addSection(line, cursorPos);
                }
            }
        }
        return charPos;
    }

    string selection(ulong startCharacter, ulong endCharacter){
        string retval;
        string fullText = text;
        if (startCharacter > endCharacter){
            if(startCharacter < fullText.length && endCharacter < fullText.length){
                retval = fullText[startCharacter .. endCharacter];
            }
        }
        return retval;
    }

    override void onKeyReleased(Event e){
        if(e.key.code == Keyboard.Key.Up){
            currentLine --;
        }
        if(e.key.code == Keyboard.Key.Down){
            currentLine ++;
        }

        version(OSX){
            if(e.key.code == Keyboard.Key.V && e.key.system ){
                string currentText = text;
                long p = lineCursorConversion(currentLine, cursor);

                string paste = Clipboard.getString();
                string newText = currentText[0..p] ~ paste ~ currentText[p .. $];
                text = newText;

            }
        } else {
            if(e.key.code == Keyboard.Key.V && e.key.control){
                string currentText = text;
                long p = lineCursorConversion(currentLine, cursor);

                string paste = Clipboard.getString();
                string newText = currentText[0..p] ~ paste ~ currentText[p .. $];
                text = newText;

            }
        }

        version(OSX){
        if(e.key.code == Keyboard.Key.C && e.key.system ){
                string currentText = text;
                long p = lineCursorConversion(currentLine, cursor);

                string paste = Clipboard.getString();
                string newText = currentText[0..p] ~ paste ~ currentText[p .. $];
                text = newText;

            }
        } else {
            if(e.key.code == Keyboard.Key.C && e.key.control){
                string currentText = text;
                long p = lineCursorConversion(currentLine, cursor);

                string paste = Clipboard.getString();
                string newText = currentText[0..p] ~ paste ~ currentText[p .. $];
                text = newText;

            }
        }

        if(!(currentLine >= 0 && currentLine < lines.length)){    
            if (currentLine < 0){
                currentLine = 0;
            } 
            if (currentLine >= lines.length) {
                currentLine = cast(int)lines.length - 1;
            }
        }

        if(lines.length){
            cursor = cast(int)validateIndex(lines[currentLine],cursor,true);
        } else {
            cursor = 0;        
        }


        version(DEBUG_TEXT){
            auto lcc  = lineCursorConversion(currentLine, cursor);
            long l, cp;
            absoluteCursorConverstion(lcc, l, cp);
            writeln("Absolut cursor position: ",lcc, 
                " Line: ", currentLine, " Cursor: ", cursor , 
                " absoluteCursorConvertion: ", l, " , ", cp);
        }
    }

    override void onEnd(){
        cursor = cast(int)lines[currentLine].length;
    }

    override void onHome(){
        cursor = 0;
    }

    override void onDraw(RenderTarget target, Vector2f offset){
        m_background.position = position + offset;
        target.draw(m_background);

        Vector2f pos = position + offset;
        //TODO: get rid of magic number
        Vector2f lineSpacing = Vector2f(0,t.characterSize() + 3); 

        Vector2f cursoPos;

        foreach(i, line; lines){
            t.string = line;
            t.position = pos;

            target.draw(t);
            if(i == currentLine) {
                cursoPos = t.findCharacterPos(cursor) + pos;
                cursorLoc.position = cursoPos;
                target.draw(cursorLoc);             
            }
            pos += lineSpacing;
        }
    }

    override void onClick(Event e){
        import std.conv;
        super.onClick(e);

        Vector2i point = Vector2i(e.mouseButton.x, e.mouseButton.y);
        point = this.getReleativePosition(point);

        int tempLine = point.y / (t.characterSize + 3);
        tempLine = cast(int) validateIndex(lines, tempLine);

        auto s = lines[tempLine];
        t.setString (s);
        auto tposition = Vector2f(0, (t.getCharacterSize() + 3)*tempLine);

        const(Font) font = t.font;
        int i;
        for(i = 0; i < s.length; i++){
            Vector2f cpos = t.findCharacterPos(i) + tposition;
            Vector2i charPos = Vector2i(   cpos.x.to!int , 
                                            cpos.y.to!int);
            uint codepoint = s[i];
            Glyph glyph = font.getGlyph(codepoint,t.characterSize, false);
            int advance = glyph.advance.to!int;
            IntRect charBox = IntRect(  charPos.x,
                                        charPos.y,
                                        advance,
                                        t.characterSize + 3);
            if(charBox.contains(point)){
                break;
            }
        }
        currentLine = tempLine;
        cursor = i;

        if(cursor < 0){
            cursor = 0;
        } else if (cursor > s.length) {
            cursor = cast(int)(s.length);
        }
    }

    void characterLocationFromVector(Vector2i point, out long line, out long cursorpos){
        line = point.y / (t.characterSize + 3);
        line = validateIndex(lines, line);
        auto temp = lines[line];
        t.setString (temp);
        auto tposition = Vector2f(0, (t.getCharacterSize() + 3)*line);

        const(Font) font = t.font;
        int i;
        for(i = 0; i < temp.length; i++){
            Vector2f cpos = t.findCharacterPos(i) + tposition;
            Vector2i charPos = Vector2i(   cpos.x.to!int , 
                                            cpos.y.to!int);
            uint codepoint = temp[i];
            Glyph glyph = font.getGlyph(codepoint,t.characterSize, false);
            int advance = glyph.advance.to!int;
            IntRect charBox = IntRect(  charPos.x,
                                        charPos.y,
                                        advance,
                                        t.characterSize + 3);
            if(charBox.contains(point)){
                break;
            }
        }
        currentLine = line.to!int;
        cursor = i;

        if(cursor < 0){
            cursor = 0;
        } else if (cursor > temp.length) {
            cursor = cast(int)(temp.length);
        }
    }

    override void onText(Event e){
        import std.uni;
        import std.stdio;
        import std.string;
        import std.algorithm;
        string currentTextLine;

        if(lines.length){
            currentTextLine = lines[currentLine];
        }
        bool doAssign = true;

         if(!locked ){
            char c = cast(char) (e.text.unicode);
            if(c == '\b') {
                cursor = cast(int)validateIndex(currentTextLine, cursor);
                if( currentTextLine.length > 0 && cursor > 0 ) {
                    string tempA = currentTextLine[ 0 .. ( cursor - 1 ) ];
                    tempA ~= currentTextLine[ cursor .. currentTextLine.length ];
                    currentTextLine = tempA;
                    cursor--;
                } else if(cursor == 0) {
                    if(currentLine > 0 ){
                        string tempB = currentTextLine;
                        if(lines.length){
                            lines = lines.remove(currentLine);
                        }
                        currentLine -- ;
                        string strippedLine = lines[currentLine].strip("\n");
                        cursor = cast(int)strippedLine.length;
                        currentTextLine = strippedLine ~ tempB;
                        writeln("lines after", lines);
                    }
                }
            } else if ( c == 127) { //DELETE
                if(currentTextLine.length > 0) {
                    if(cursor >= currentTextLine.length) {
                        cursor = cast(int)(currentTextLine.length);
                        if(currentLine + 1 < lines.length) {
                            string tempDelete = lines[currentLine + 1];
                            currentTextLine = currentTextLine.strip("\n") ~ tempDelete;
                            if(lines.length){
                                currentLine = cast(int) validateIndex(lines, currentLine);
                                lines = lines.remove(currentLine);
                            }
                        }
                    } else {
                        currentTextLine = currentTextLine.erase(cursor);
                    }
                } else {
                    doAssign = false;
                    if(lines.length){
                        currentLine = cast(int) validateIndex(lines, currentLine);
                        lines = lines.remove(currentLine);
                    }
                }
            } else if (c == '\n') {
                currentLine = cast(int)validateIndex(lines, currentLine,true);
                cursor = cast(int)validateIndex(lines[ currentLine ], cursor,true);
                writeln(currentLine , " , " , cursor);
                if(currentTextLine.length > 0){   
                    string newLinePt1 = currentTextLine[ 0 .. cursor ];
                    string newLinePt2 = currentTextLine[ cursor .. $ ];
                    if(currentLine + 1 >= lines.length){
                        lines[currentLine] = newLinePt1;
                        lines ~= newLinePt2;
                        currentLine = cast(int)lines.length;
                    } else {
                        lines[currentLine] = newLinePt1;
                        string [] temparray = lines[ 0 .. currentLine + 1 ];
                        temparray ~= newLinePt2;
                        string [] temparray2 = lines[ currentLine + 1 .. $ ];
                        lines = temparray  ~ temparray2;
                        currentLine ++;
                    }
                    cursor = 0;
                } else {
                    currentLine = cast(int) validateIndex(lines, currentLine);
                    cursor = 0;
                    string [] temparray = lines[0 .. currentLine + 1];
                    temparray ~= "";
                    string [] temparray2 = lines[ currentLine + 1 .. $ ];
                    lines = temparray  ~ temparray2;
                    currentLine ++;
                }
                doAssign = false;
            } else {
                if(isGraphical(c)) {
                    if(cursor >= currentTextLine.length){
                        currentTextLine ~= c;                        
                        cursor = cast(int)currentTextLine.length ;
                    } else {
                        string temp = currentTextLine[ 0 .. cursor ];
                        temp ~= c;
                        temp ~= currentTextLine[ cursor .. currentTextLine.length ];
                        currentTextLine = temp;
                        cursor++;
                    }
                    if(lines.length == 0){
                        string text;
                        text  ~= c;
                        lines ~= text;
                        currentLine = 0;
                        cursor = 1; 
                    }
                }
            }

            if(doAssign){
                if(lines.length){
                    if(currentLine >= lines.length){
                        currentLine = cast(int)lines.length - 1;
                    } else if (currentLine < 0){
                        currentLine = 0;
                    }
                    lines[currentLine] = currentTextLine;
                }
            }
        }

        if(lines.length){
            currentLine = cast(int)validateIndex( lines, currentLine ,false);
            cursor = cast(int)validateIndex( lines[ currentLine ], cursor,true );
        }

    }
}