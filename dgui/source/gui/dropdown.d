module gui.dropdown;

import nudsfml.graphics;
import std.stdio;

import gui;
import gfx;

class DropDown : Widget {
    RoundedRectangle rect;
    RoundedRectangle control;
    RectangleShape controls;
    RoundedRectangle dropdown;

    Text label;

    /*
    RectangleShape rect;
    RectangleShape control;
    RectangleShape controls;
    RectangleShape dropdown;
    */
    bool checked = false;

    string [] items;
    int index;

    @property{
        override Vector2f size ( Vector2f s){
            m_size = s;
            updateSize();
            return m_size;
        }
        override Vector2f size(){
            return m_size;
        }
    }

    this(Gui gui_, Vector2f pos_, Vector2f size_){
        super(gui_); 

        index = -1;
        m_type = "dropdown";
        position = Vector2f(0,0);
        m_size = Vector2f(200,30);
        color = Color(60,60,60);

        rect = new RoundedRectangle();
        rect.fillColor = color;
        rect.outlineColor = Color(140,140,140);
        rect.outlineThickness = 1;
        rect.topRight = false;
        rect.bottomRight = false;
        rect.radius = 5;
        rect.cornerCount = 4;

        control = new RoundedRectangle();
        control.fillColor = color + Color(40,40,40);
        control.outlineColor = Color(140,140,140);
        control.outlineThickness = 1;
        control.topLeft = false;
        control.bottomLeft = false;
        control.radius = 5;
        control.cornerCount = 4;

        controls = new RectangleShape();
        controls.setTexture(gui.controls);
        controls.fillColor = Color.White;
        controls.size = Vector2f(16,16);
        controls.setTexture(gui.controls);
        controls.textureRect = IntRect(4*32,0,32,32);

        dropdown = new RoundedRectangle();
        dropdown.fillColor = color;
        dropdown.outlineColor = Color(140,140,140);
        dropdown.outlineThickness = 1;
        dropdown.topLeft = false;
        dropdown.topRight = false;
        dropdown.radius = 5;
        dropdown.cornerCount = 4;

        label = new Text();
        label.fillColor = (gui.theme["text"]);
        label.setFont(gui.fonts["default"]);
        label.setCharacterSize(12);

        size = size_;
        position = pos_;


        updateSize();
    }

    void addItem(string str){
        items ~= str;
    }

    final void updateSize(){
        if(checked){
            rect.bottomLeft = false;
            control.bottomRight = false;
        } else {
            rect.bottomLeft = true;
            control.bottomRight = true;
        }

        rect.size = m_size - Vector2f(32,0);
        control.size = Vector2f(32, m_size.y);
        controls.size = control.size;
        dropdown.size = Vector2f(m_size.x,200);
    }

    override void onClick(Event e){
        // TODO! handle scrolling via buttons on larger drop downs
        // scrollwheel should flip through options on hover in both open and closed
        // if checked and up and down scroll buttons clicked don't close dropdown 
        
        Vector2i p = Vector2i(e.mouseButton.x, e.mouseButton.y);
        
        if(checked){
            p = getReleativePosition(p);
            if(p.y > m_size.y) p.y -=cast(int)(m_size.y) + 3;
            
            int newIndex = p.y / 15;
            if (newIndex >= 0 && newIndex < items.length){
                index = newIndex;
            } else {
                index = -1;
            }
        }

        checked = checked ? false : true;
        updateSize();
        super.onClick(e);
    }

    override Widget contains(Vector2i point){
        if(enabled){
            point -= position;
            //final widget like this shouldn't contain children but ... 
            
            foreach_reverse(ref child; children){
                auto c = child.contains(point);
                if(c !is null) return c;
            }

            auto mySize = m_size;
            if(checked) {
                mySize += Vector2f(0,dropdown.size.y);
                writeln("my size is larger");
            }
            if(point.x < mySize.x && point.x >= 0 && point.y < mySize.y && point.y >=0){
                return this;
            }
        }
		return null;
	}

    override void onDraw(RenderTarget target, Vector2f offset){
        Vector2f drawpos = position + offset;

        rect.position = drawpos;
        control.position = drawpos + Vector2f(rect.size.x, 0);
        dropdown.position = drawpos + Vector2f(0, m_size.y);

        target.draw(rect);

        if(index >= 0 && index < items.length){
            label.position = drawpos + Vector2f(3,3);
            label.setString(items[index]);
            target.draw(label);
        }

        target.draw(control);
        controls.position = control.position;
        target.draw(controls);

        if(checked){
            target.draw(dropdown);
            auto textPos = drawpos + Vector2f(3, m_size.y+3);
            foreach(item; items){
                label.setString( item);
                label.position = textPos;
                textPos += Vector2f(0,15);
                target.draw(label);
            }
        }
    }
}