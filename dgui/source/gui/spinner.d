module gui.spinner;

import nudsfml.graphics;
import gfx;
import gui;

import std.stdio;
import std.format;

class Spinner : Widget {
    RoundedRectangle left;
    RoundedRectangle right;
    RectangleShape center;
    Text textLabel;

    RectangleShape controlLeft;
    RectangleShape controlRight;

    float r_value= 0.5;
    float step = .1;
    float min = 0; 
    float max = 1;

    @property { //size
        override Vector2f size(Vector2f s){
            m_size = s;
            updateSize();
            return m_size;
        }
        override Vector2f size(){
            return m_size;
        }
    }
    alias size = Widget.size;

    @property {//value
        override string value(string s){
            m_value = s;
            updateSize();
            return m_value;
        }
        override string value(){
            return m_value;
        }
    }

    this(Gui gui_, Vector2f pos_ = Vector2f (5,5), Vector2f size_ = Vector2f (100,20)){
        super(gui_);

        m_type = "spinner";
    

        left = new RoundedRectangle();
        left.topRight = false;
        left.bottomRight = false;
        left.cornerCount = 4;
        left.radius = 5;
        left.fillColor(Color(140,140,140));
        left.outlineColor(Color(100,100,100));
        left.outlineThickness(1);

        right = new RoundedRectangle();
        right.topLeft = false;
        right.bottomLeft = false;
        right.cornerCount = 4;
        right.radius = 5;
        right.fillColor(Color(140,140,140));
        right.outlineColor(Color(100,100,100));
        right.outlineThickness(1);
        
        center = new RectangleShape();
        center.fillColor(Color(80,80,80));
        center.outlineColor(Color(100,100,100));
        center.outlineThickness(1);

        textLabel = new Text();
        textLabel.setCharacterSize(14);
        textLabel.setFont(gui.fonts["default"]);
        textLabel.fillColor = (gui.theme["text"]);

        controlLeft = new RectangleShape();
        controlLeft.setTexture(gui.controls);
        controlLeft.textureRect = IntRect(2 * 32, 0, 32, 32);
        controlLeft.fillColor = Color.White;

        controlRight = new RectangleShape();
        controlRight.setTexture(gui.controls);
        controlRight.textureRect = IntRect(3 * 32, 0, 32, 32);
        controlRight.fillColor = Color.White;

        size = size_;
        position = pos_;

        updateSize();
        value = "0.5";
    }

    override void onClick(Event e){
        auto p = Vector2i(e.mouseButton.x, e.mouseButton.y);
        p = getReleativePosition(p);

        auto lp = getReleativePosition(Vector2i(left.position));
        auto bounds = FloatRect(lp.x,lp.y,left.size.x, left.size.y);
        if(bounds.contains(p)){
            decrease();
        }

        auto rp = getReleativePosition(Vector2i(right.position));
        bounds = FloatRect(rp.x, rp.y, right.size.x, right.size.y);
        if(bounds.contains(p)){
            increase();
        }   

    }

    void decrease(){
        r_value -= step;
        if(r_value < min){
            r_value = min;
        }
        value = format("%f",r_value);
    }

    void increase(){
        r_value += step;
        if(r_value > max){
            r_value = max;
        }
        value = format("%f",r_value);
    }

    void updateSize(){
        left.size = Vector2f(32, m_size.y);
        right.size = Vector2f(32, m_size.y);
        center.size = Vector2f(m_size.x - 64, m_size.y);

        string temp = m_value;

        textLabel.setString(value );
        FloatRect bounds = textLabel.getLocalBounds();
        if(bounds.width > m_size.x - 64 && bounds.width > 0){
            size_t i = (cast(size_t)((m_size.x - 64) / (bounds.width / value.length)));
            
            if (i > 0 && i < m_value.length){
                temp = m_value[0 .. i];
            } else {
                temp = "";
            }
        }

        float scale = m_size.y < 32 ? m_size.y : 32;

        controlLeft.size = Vector2f(scale,scale);
        controlRight.size = Vector2f(scale,scale);

        textLabel.setString(temp);
    }

    override void onDraw(RenderTarget target, Vector2f offset){
        auto drawpos = position + offset;

        left.position   = drawpos;
        center.position = drawpos + Vector2f(32,0);
        right.position  = drawpos + Vector2f(m_size.x - 32, 0);
        
        textLabel.position = center.position + Vector2f(1,1);

        controlLeft.position = left.position;
        controlRight.position =  drawpos + Vector2f(m_size.x - controlRight.size.x, 0);

        target.draw(left);
        target.draw(center);
        target.draw(right);
        target.draw(textLabel);

        target.draw(controlLeft);
        target.draw(controlRight);
    }
}

