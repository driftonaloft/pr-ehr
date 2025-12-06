module gui.section;

import nudsfml.graphics;
import gui;
import gfx;

class Section : Widget {
    bool m_edit;
    RoundedRectangle rect;
    Text sectionLabel;

    @property {//size
        override Vector2f size(Vector2f s){
            m_size = s;
            rect.size = m_size;
            return m_size;
        }
        override Vector2f size(){
            return m_size;
        }
    }
    alias size = Widget.size;

    @property { // edit
        import std.algorithm;
        bool edit(bool e){
            m_edit = e;
            foreach(ref child; children){
                if(child.m_type == "cage"){
                    Cage temp = cast(Cage)(child);
                    temp.edit = m_edit;
                    if(temp.children.length == 1){
                        Vector2f topLeft;
                        Vector2f bottomRight;
                        foreach( cageChild; temp.children){
                            topLeft = Vector2f(min(topLeft.x , cageChild.position.x), min(topLeft.y, cageChild.position.y));
                            bottomRight = Vector2f(max(bottomRight.x, cageChild.position.x + cageChild.size.x), max(bottomRight.y, cageChild.position.y + cageChild.size.y));
                        }
                        temp.size = bottomRight - topLeft;                    }
                }
            }
            return m_edit;
        }
        bool edit(){
            return m_edit;
        }
    }

    this (Gui gui_, string id_ , Vector2f position_ , Vector2f size_){
        super(gui_);
        m_type = "section";

        //form color
        // background.fillColor = Color(100,100,115);
		// background.outlineColor = Color(70,70,70);

        // TODO: get colours from gui theme (or from theme) 
        rect = new RoundedRectangle();
        rect.fillColor = Color(80,80,80);
        rect.outlineColor = Color(70,70,70);
        rect.outlineThickness = 1;
        
        sectionLabel = new Text;
        sectionLabel.setFont(gui.fonts["default"]);
        sectionLabel.setCharacterSize(15);
        sectionLabel.fillColor = (Color.White);

        m_id = id_;
        position = position_;
        size = size_;

    }

    Vector2f findFreePosition(T:Widget)(T check){ // @suppress(dscanner.suspicious.unused_parameter)
        Vector2f loc = Vector2f(10,10);
        foreach(child ; children){
            if(loc.y < child.position.y + child.size.y){
                loc.y = child.position.y + child.size.y + 10;
            }
        }
        return loc;
    }

    override void onDraw(RenderTarget target, Vector2f offset){
        Vector2f drawpos = position + offset;

        rect.position = drawpos;
        target.draw(rect);

        sectionLabel.position = drawpos;// + Vector2f(5,5);
        sectionLabel.setString(label);
        target.draw(sectionLabel);
    }
}