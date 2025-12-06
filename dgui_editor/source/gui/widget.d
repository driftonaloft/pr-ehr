module gui.widget;

import std.stdio;

import nudsfml.graphics;

import gui.system;

class Widget { 
    Widget [] children;
    Widget parent;
    Vector2f internalOffset;

    bool visible;
    bool enabled;
    bool hasFocus;

    bool drawOverChildren=false;

    void delegate() [string] events;

    GuiSystem gui;

    string m_value;

    //change these into properties
    string m_name;
    @property {
        string name (string _name) {
            m_name = _name;
            return m_name;
        }
        string name() {
            return m_name;
        }
    }
          
    Vector2f m_position;
    @property {
        Vector2f position (Vector2f _position) {
            m_position = _position;
            return m_position;
        }
        Vector2f position() {
            return m_position;
        }
    }
    
    //size property is a Vector2f
    Vector2f m_size;
    @property {
        Vector2f size (Vector2f _size) {
            m_size = _size;
            return m_size;
        }
        Vector2f size() {
            return m_size;
        }
    }

    //end properties
    this (GuiSystem gui_)  {
        gui = gui_;
        parent = null;
        m_position = Vector2f(0,0);
        m_size = Vector2f(0,0);

        internalOffset = Vector2f(0,0);
        visible = true;
        enabled = true;
    }

    this(GuiSystem gui_, Vector2f position_, Vector2f size_) {
        gui = gui_;
        parent = null;
        m_position = position_;
        m_size = size_;

        internalOffset = Vector2f(0,0);
        visible = true;
        enabled = true;
    }


    bool heldRegion(Vector2f point) {
        return false;
    }

    void handleEvents(Event e) {
        
    }

    Vector2f updateHeldPosition(Vector2f point) {
        return position(point);
    }

   Vector2f getReleativePoint(Vector2f point) {
        if (this !is null) {
            auto temp = this;
            while(temp !is null) {
                point -= temp.position + (temp != this ? temp.internalOffset : Vector2f(0,0));
                temp = temp.parent;
            }
        }
        return point;
    }

    Widget getChildPoint(Vector2f pos) {
		foreach (ref child ; children) {
            auto bounds = child.getGlobalBounds();
            //writeln("w bounds: ", bounds);
			if (bounds.contains(pos)) {
				Widget w = child.getChildPoint(pos);
				if(w !is null) {
					return w;
				} 
				return child;
			}
		}
		return null;
	}

    FloatRect getGlobalBounds() {
        FloatRect bounds;
        if (parent !is null) {
            auto temp = parent;
            while(temp !is null) {
                bounds.left += parent.m_position.x + temp.internalOffset.x;
                bounds.top  += parent.m_position.y + temp.internalOffset.y; 
                temp = temp.parent;
            }
            bounds.left += m_position.x;
            bounds.top += m_position.y;
            bounds.width = m_size.x;
            bounds.height = m_size.y;

        } else {
            bounds = FloatRect(m_position.x, m_position.y, m_size.x, m_size.y);
        }
        return bounds;
    }

    void onClick(Vector2f point) {
        if("click" in events) {
            events["click"]();
        }
    }

    void updateSelf(float dt) {
        //update stuff here
    }

    void update(float deltaTime) {
        if (enabled) {
            updateSelf(deltaTime);
            foreach (ref child; children) {
                child.update(deltaTime);
            }
        }
    }

    void registerChild(Widget child) {
        if(child !is null) {
            child.parent = this;
            children ~= child;
        }
    }

    void drawSelf(RenderTarget target, Vector2f offset) {
        //do draw stuff here
    }

    void draw(ref RenderTarget target,Vector2f offset){
        if( visible ) {
            if(drawOverChildren) {
                foreach (ref child; children) {
                    child.draw(target, position + offset + internalOffset);
                }
                drawSelf(target, offset);
            } else {
                drawSelf(target, offset);
                foreach (ref child; children) {
                    child.draw(target, position + offset + internalOffset);
                }
                
            }

        }
    }
}