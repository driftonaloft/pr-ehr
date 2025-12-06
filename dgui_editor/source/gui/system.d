module gui.system;

import std.stdio;

import nudsfml.graphics;

import gui.widget;

class DockableRegion{
	DockableRegion [] dockables;

	this(Vector2f size) {

	}

	void alignment(){

	}

	void resize(Vector2f size) {

	}
}

class GuiSystem : Drawable {
	bool isDebug = true;
    Color [string] theme;
    Font [string] fonts;

	Vector2f size;	
	Vector2f mousePos;

	Widget [] children;
	Widget held;
	Vector2f heldOffset;
	Widget focus;
	Widget active;

	Widget overlay;

	RenderWindow win;

	Event currentEvent;

    this(RenderWindow win_) {
		win = win_;
		size = Vector2f(win.getSize().x, win.getSize().y);


    	theme["background"] =  Color(20, 20, 20);
		theme["text"] =  Color(255,255,255);
		theme["text_dark"] = Color(150,150,150);
		theme["border"] =  Color(255,255,255);

		theme["panel"] =  Color(50, 50, 50);
		theme["panel_handle"] =  Color(80, 80, 80);
		theme["panel_outline"] =  Color(30, 30, 30);
		
		theme["button"] =  Color(80,80,80);
		theme["button_outline"] = Color(60,60,60);

		theme["toggle_button_outline"] =  Color(80,80,80);
		theme["toggle_button_true"] =  Color(40,40,40);
		theme["toggle_button_false"] =  Color(120,120,120);

		theme["textbox"] =  Color(30,30,30);
		theme["textbox_outline"] =  Color(130,130,130);
		theme["textbox_cursor"] =  Color(200,200,200);

		theme["button_hover"] =  Color(255,255,255);
		theme["button_pressed"] =  Color(255,255,255);
		theme["button_disabled"] = Color(255,255,255);
		theme["button_text"] =  Color(255,255,255);
		theme["button_text_hover"] = Color(255,255,255);
		theme["button_text_pressed"] = Color(255,255,255);
		theme["button_text_disabled"] = Color(255,255,255);
		theme["button_border_hover"] = Color(255,255,255);
		theme["button_border_pressed"] = Color(255,255,255);
		theme["button_border_disabled"] = Color(255,255,255);
		theme["button_background"] = Color(255,255,255);
		theme["button_background_hover"] = Color(255,255,255);
		theme["button_background_pressed"] = Color(255,255,255);
		theme["button_background_disabled"] = Color(255,255,255);
		
		theme["window_background"] = Color(60,60,60);
		theme["window_outline"] = Color(20,20,20);
		theme["window_title_background"] = Color(80,80,80);
		theme["window_title_outline"] = Color(20,20,20);

		theme["window_title_text"] = Color(255,255,255);
		theme["window_title_text_hover"] = Color(255,255,255);
		theme["window_title_text_pressed"] = Color(255,255,255);
		theme["window_title_text_disabled"] = Color(255,255,255);
		
		theme ["fontColor"] = Color.White;
		theme ["backgroundColor"] = Color.Black;
		theme ["borderColor"] = Color(0x50,0x50,0x50);
		theme ["formColor"] = Color(0x40,0x40,0x40);
		theme ["headerColor"] = Color(0x80,0x80,0x80);

        auto font = new Font();
        font.loadFromFile("data/fonts/FiraMono-Regular.ttf");
        fonts["default"] = font;

		//load themeing  file if it exists // TODO: make this a function 
		
    }

	Widget getChildPoint(Vector2f pos) {
		foreach_reverse (ref child ; children) {
            auto bounds = child.getGlobalBounds();
			if (bounds.contains(pos)) {
				Widget w = child.getChildPoint(pos);
				if(w !is null) {
					return w;
				} else {
					return child;
				}
			}
		}
		return null;
	}

	void handleEvents(Event e) {
		currentEvent = e;
		switch(e.type){
			case Event.Type.MouseButtonPressed:
				mousePos = win.mapPixelToCoords(Vector2i(e.mouseButton.x, e.mouseButton.y));
				writeln(mousePos);
				Widget w = getChildPoint(mousePos);
				if(w !is focus) {
					if(focus !is null) {
						focus.hasFocus = false;
						if(w is overlay) {
							overlay = null;
						}
					}
					focus = w;
					if(focus !is null) {
						focus.hasFocus = true;
					}
				}
				if(w !is null) {
					if(w.heldRegion(mousePos)) {	
						held = w;				
						heldOffset = w.getReleativePoint(mousePos);
					}

					if(w !is null) {
						w.onClick(mousePos);
						break;
					}
				}
				
				break;
			case Event.Type.MouseButtonReleased:
				if(held !is null) {
					held = null;
				}
				auto mousePos = win.mapPixelToCoords(Vector2i(e.mouseButton.x, e.mouseButton.y));
				foreach(ref child ;  children) {
					if(child.enabled) {
						Widget w = getChildPoint(mousePos);
						if(w !is null) {
							//w.onClick(mousePos);
							break;
						}
					}
				}
				break;

			case Event.Type.Resized :
				int w = e.size.width;
				int h = e.size.height;
				auto v  = View(FloatRect(0,0,w,h));
				win.view = v;

				size = Vector2f(w, h);

				foreach(ref child ; children) {
					child.handleEvents(e);
				}
				
				break;
						
			default:
		}
		if(focus !is null){
			focus.handleEvents(e);
		}
	}

	void update(float deltaTime){
		if(held !is null){
			auto mousePos = win.mapPixelToCoords(Vector2i(Mouse.getPosition(win).x, Mouse.getPosition(win).y));
			held.updateHeldPosition(mousePos - heldOffset);
		}
		
	}

	void registerChild(Widget child) {
        if(child !is null) {
            child.parent = null;
            children ~= child;
        }
    }

    void draw(RenderTarget target, RenderStates states) {
        foreach(ref w ; children) {
            w.draw(target, Vector2f(0,0));
        }
		if(overlay !is null) {
			FloatRect location = overlay.getGlobalBounds();
			overlay.draw(target, Vector2f(location.left,location.top));
		}
    }
}