module gui.listbox;

import gui;
import std.stdio;

import nudsfml.graphics;

class ListBoxItem{
    string label;
    string value;
    bool selected;
    this(string l, string v, bool select = false){
        label = l;
        value = v;
        selected = select;
    }
}

class ListBox : Widget {
    int index;
    int i_offset;
    ListBoxItem[] items;

    bool multiSelect = false;

    Text labelText;
    Text itemsText;

    RectangleShape base;
    RectangleShape control;

    @property{
        override string label(string l){
            m_label = l;
            labelText.setString(l);
            return m_label;
        }
        override string label(){
            return m_label;
        }
    }
    alias label = Widget.label;

    this(Gui gui_, string label_ = "ListBox", Vector2f pos_ = Vector2f(5,5), Vector2f size_= Vector2f(100,200)){
        super(gui_);

        m_type = "listbox";

        index = -1;
        i_offset = 0;

        base = new RectangleShape();
        base.fillColor(Color(60,60,60));
        base.outlineColor = Color(140, 140, 140);
        base.outlineThickness = 1;

        control = new RectangleShape();
        control.size = Vector2f(16,16);
        control.setTexture(gui.controls);
        control.fillColor(Color.White);

        labelText = new Text();
        labelText.setFont(gui.fonts["default"]);
        labelText.setCharacterSize(15);
        labelText.fillColor = (Color.White);

        itemsText = new Text();
        itemsText.setFont(gui.fonts["default"]);
        itemsText.setCharacterSize(12);
        itemsText.fillColor = (Color(200,200,200));

        position = pos_;
        size = size_;
        label = label_;
    }

    void addItem(string l,string v,bool b=false){
        auto item = new ListBoxItem(l,v,b);
        items ~= item;
    }

    void removeItem(string id){
        import std.algorithm;
        items = items.remove!(i => i.label == id)();
    }

    void removeItem(int target){
        if (target >= 0 && target < items.length){
            if(target == 0){
                if(items.length > 1){
                    items = items[1..$];
                } else {
                    items.length = 0;
                }
            } else if(target == items.length - 1){
                if(items.length > 1){
                    items = items[0..$-1];
                } else {
                    items.length = 0;
                }
            } else {
                items = items[0..target-1] ~ items[target+1..$];
            }
        }
    }

    void clear(){
        items.length = 0;
    }

    override void onScrollWheel(Event e){
        int delta = e.mouseWheel.delta;
        i_offset += delta;

        writeln("mouse Wheel Delta: ",delta, " i_offset: ",i_offset);

        if(cast(int)(items.length)-1 < i_offset) {
            i_offset = cast(int)(items.length) - 1;
        }
        if(0 > i_offset ){
            i_offset = 0;
        }

        super.onScrollWheel(e);
    }

    override void onClick(Event e){
        Vector2i p = Vector2i(e.mouseButton.x, e.mouseButton.y);

        IntRect labelRect = IntRect(0,0,cast(int)(size.x), 20);
        IntRect itemsRect = IntRect(0,20,cast(int)(size.x)-16, cast(int)(size.y) - 20);
        IntRect upRect =    IntRect(cast(int)(size.x)-16,20,16,16);
        IntRect downRect = IntRect(cast(int)(size.x)-16,cast(int)(size.y)-16,16,16);
        
        auto r=getReleativePosition(p);
        //r -= position;
        writeln(r);
        if(labelRect.contains(r)){
            index = -1;
        } else if(upRect.contains(r)){
            if(--i_offset < 0) i_offset = 0;
        } else if(downRect.contains(r)){
            if(++i_offset > cast(int)(items.length) - 1) i_offset = cast(int)(items.length ) - 1 ;
        } else if(itemsRect.contains(r)){
            Vector2i n = r - Vector2i(itemsRect.left, itemsRect.top);
            int selection = (n.y / 14) + i_offset;
            if(multiSelect){
                if(selection >= 0 && selection < items.length){
                    items[selection].selected =  items[selection].selected ? false : true ;
                }
            } else {
                for (int i = 0 ; i < items.length; i++){
                    if(i == selection){
                        items[i].selected = true;
                    } else {
                        items[i].selected = false;
                    }
                }
            }
            string myValue;
            foreach(item; items){
                if(item.selected){
                    myValue ~= item.value;
                }
            }
            m_value = myValue;
        } 
        super.onClick(e);
    }

    override void onDraw(RenderTarget target, Vector2f offset){
        Vector2f drawpos = position + offset;
        labelText.position = drawpos;
        base.position = drawpos + Vector2f(0,18);
        base.size = size - Vector2f(0,18);

        target.draw(labelText);
        target.draw(base); 

        if(items.length){

            Vector2f itempos = drawpos + Vector2f(0,18);
            for(int i = 0; i < (base.size.y / 14) - 1; i++){
                if(i+i_offset < items.length) {
                    itemsText.position = itempos + (Vector2f(0,14) * i);
                    itemsText.string = items[i+i_offset].label;
                    if(items[i+i_offset].selected){
                        itemsText.fillColor = (Color.White);
                    } else {
                        itemsText.fillColor = (Color(160,160,160));
                    }
                    target.draw(itemsText);
                }
            }

            if(items.length > base.size.y / 14){
                //display controls 
                if(i_offset != 0){
                    control.position = drawpos + Vector2f(size.x - 16, 18);
                    control.textureRect = IntRect(0,0,32,32);
                    target.draw(control);
                } 
                if((i_offset + 1) < items.length){
                    control.position = drawpos + Vector2f(size.x - 16, size.y - 16);
                    control.textureRect = IntRect(32,0,32,32);
                    target.draw(control);
                }
            }
        }

    }
}
