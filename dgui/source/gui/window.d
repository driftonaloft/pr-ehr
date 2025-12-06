module gui.window;

import gfx;
import gui;

import nudsfml.graphics;
import std.stdio;

class Window : Widget {
    string title;

    RoundedRectangle titleBar;
    RoundedRectangle body;

    Text titleText;

    @property { //Size
        override Vector2f size(Vector2f s){
            m_size = s;
            updateSize();
            return m_size;
        }
        override Vector2f size(){
            return m_size;
        }
    }

    this(Gui gui_, string label_ = "Default", Vector2f pos_ = Vector2f(0,0), Vector2f size_ = Vector2f(300,300)){
        super(gui_);
        m_type = "window";

        titleBar = new RoundedRectangle();
        titleBar.bottomLeft = false;
        titleBar.bottomRight = false;
        titleBar.radius = 5;
        titleBar.cornerCount = 4;
        titleBar.fillColor = Color(100, 100, 100);
        titleBar.outlineColor = Color(80, 80, 80);
        titleBar.outlineThickness = 1;

        body = new RoundedRectangle();
        body.topLeft = false;
        body.topRight = false;
        body.radius = 5;
        body.cornerCount = 4;
        body.fillColor = Color(80,80,80);
        body.outlineColor = Color(70,70,70);
        body.outlineThickness = 1;

        titleText = new Text();
        titleText.fillColor = (gui.theme["text"]);
        titleText.setFont(gui.fonts["default"]);
        titleText.setCharacterSize(16);

        size = size_;
        label = label_;
        position = pos_;
    }

    void updateSize(){
        import std.conv;
        titleBar.size = Vector2f(m_size.x , 20);
        m_handle = IntRect(0,0,titleBar.size.x.to!int, titleBar.size.y.to!int);
        body.size = Vector2f(m_size.x, m_size.y - 20);
    }

    override void onDrag(Vector2i current, Vector2i offset) {
        auto relative = getReleativePosition(current);
        version(DEBUG_LOG){writeln("window draggin ",relative , current , offset);}

        Vector2i delta = relative - offset;
               
        m_position += Vector2f(delta.x,delta.y);
        version(DEBUG_LOG){writeln("titleBar Dragging");}

        updateSize();
    }

    override void onDraw(RenderTarget target, Vector2f offset) {
        auto drawpos = offset + position;
 
        titleBar.position = drawpos;
        target.draw(titleBar);

        body.position = drawpos + Vector2f(0,20);
        target.draw(body);

        titleText.string = (label);
        titleText.position = drawpos + Vector2f(5,0);
        target.draw(titleText);
    }
}