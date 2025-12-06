module gui.forms;

import std.stdio;
import std.string;
import std.file;

import gui;

import gfx.roundedrectangle;
import nudsfml.graphics;

class Form : Widget {
	RoundedRectangle background;
	nudsfml.graphics.text.Text title;

	string [] sections;

	this(Gui gui_, string title_ , Vector2f position_ = Vector2f (0,0), Vector2f size_= Vector2f(640,480)) {
		super(gui_);
		m_type = "form";

		title = new nudsfml.graphics.text.Text();
		title.setFont(gui.fonts["default"]);
		title.characterSize = 20;

		background = new RoundedRectangle();
		background.fillColor = Color(100,100,115);
		background.outlineColor = Color(70,70,70);
		background.outlineThickness = 1;
		background.radius = 5; 

		label = title_;
		position = position_;
		size = size_;
	}

	@property{ //size
		override Vector2f size (Vector2f s) {
			m_size = s;
			updateSize();
			return m_size; 
		}
	}

	@property{ //title
		override string label (string l) {
			title.string = l;
			m_label = l;
			return l;
		}
	}
		
	void updateSize(){
		background.size = m_size;
	}

    string eval(){
		return "";
	}
	
    void build(){

	}
   
    override void onDraw(RenderTarget target, Vector2f offset){
		background.position = m_position + offset;
		target.draw(background);

		title.position = m_position + offset + Vector2f(5,0);
		target.draw(title);
	}

    bool load(string file){
		return false;
	}
    bool loadFromString(){
		return false;
	}
    bool save(string file){
		return false;
	}

    string narrative;
    //WindowRef window;
}


/*
void buildFormFromXml(string formfile){
	string s = cast(string) std.file.read(formfile);
	check(s);

	auto e = new DocumentParser(s);
	e.onStartTag["form"] = (ElementParser e){
		writeln("form");
		auto f = new Form();
		e.onStartTag["section"] = (ElementParser e){
			e.onEndTag["label"] = (in Element e){
				writeln("label");
			};
			e.onEndTag["array"] = (in Element e){
				writeln("array");
			};
			e.onEndTag["textbox"] = (in Element e){
				writeln("textbox");
			};
			e.onEndTag["narrative"] = (in Element e){
				writeln("narrative");
			};	
			e.parse();		
		};
		e.onEndTag["narrative"]= (in Element e){
			f.narrative = e.text;
		};
		e.parse();
	};
	e.parse();
	writeln (e);
	//return new Form;
}
*/
