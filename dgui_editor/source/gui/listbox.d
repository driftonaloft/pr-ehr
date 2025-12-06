module gui.listbox;

import std.algorithm;
import std.conv;

import nudsfml.graphics;

import gui.widget;
import gui.system;

class ListBox : Widget {
    string [] items; // todo creat a class to hold the items
    int selected;
    int selectionOffset;
    int maxViewableItems;

    RectangleShape background;
    Text text;


    this(GuiSystem gui_, string name_,string [] items_ , Vector2f position_, Vector2f size_){
        super(gui_, position_, size_);

        name = name_;
        items = items_;
        selected = 0;
        selectionOffset = 0;
        maxViewableItems = (size.y / 15f).to!int; //text_height - header_height; // define these in the gui system;

        background = new RectangleShape(size);
        background.fillColor = Color(0, 0, 0, 100);
        background.outlineColor = Color(0, 0, 0, 255);
        background.outlineThickness = 1;
        
        text = new Text();
        text.setFont( gui.fonts["default"]);
        text.setCharacterSize(15);
        text.setColor (Color(255, 255, 255));       
    }

    void addItem(string item) {
        items ~= item; //appends the item to the end of the array
    }

    string remItem(int index) {
        string item;
        if(index < 0 || index >= items.length) {
            item = ""; 
        } else {
            item = items[index];
            items.remove(index);
        }
        return item;
    }

    string getItem(int index) {
        string item;
        if(index < 0 || index >= items.length) {
            item = ""; 
        } else {
            item = items[index];
        }
        return item;
    }

    void setItem(int index, string item) {
        if(index < 0 || index >= items.length) {
            return; 
        } else {
            items[index] = item;
        }
    }

    void setSelected(int index) {
        if(index < 0 || index >= items.length) {
            return; 
        } else {
            selected = index;
        }
    }

    override void handleEvents(Event e){
        switch(e.type){
            case Event.Type.KeyPressed:
                switch(e.key.code){
                    case Keyboard.Key.Up:
                        if(selected >= 0) {
                            selected--;
                        }
                        break;
                    case Keyboard.Key.Down:
                        if(selected < items.length.to!int) {
                            selected++;
                        }
                        break;
                    case Keyboard.Key.Return:
                        if(selected < items.length.to!int) {
                            //onclick / onSelect / onEnter/return
                           // gui.sendEvent(Event(Event.Type.Command, name, items[selected]));
                        }
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
        Vector2f pos = position + offset;

        background.position = pos + Vector2f(0,19);
        background.size = size - Vector2f(0,19);
        // draw the background
        target.draw(background);

        // draw the header
        text.position(pos);
        text.setString(name);
        text.setColor( gui.theme["text"] );
        target.draw(text);

        // draw the items
        int start = selected - selectionOffset;
        int end = selected - selectionOffset + maxViewableItems;
        
        if( start < 0 ) {
            start = 0;
        }

        if(end > items.length) {
            end = items.length.to!int;
        }

        for(int i = start; i < end; i++) {
            string item = items[i];
            text.setString(item);
            if(i - start < items.length){
                int posOffset = 19 + (i - start) * 15;
                text.position(Vector2f(pos.x, pos.y + posOffset));
                if(posOffset + 15 > size.y) {
                    break;
                }
                
                if(i == selected) {
                    text.setColor( gui.theme["text"] );
                } else {
                    text.setColor( gui.theme["text_dark"] );
                }

                target.draw(text);
            }
        }
    }
}