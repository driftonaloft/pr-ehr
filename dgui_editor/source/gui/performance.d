module gui.performance;

import nudsfml.graphics;

import std.format;
import std.conv;

class DebugBox{
    float range;
    float peak = 0;
    float min;
    float max;
    float avg;
    
    RectangleShape box;
    RectangleShape peakBox;
    RectangleShape current;

    Text t;

    Font font;

    Vector2f position;
    Vector2f size;
    string data;

    this(string data_, Font font_, Vector2f position_,float width,float height){
        font = font_;
        position = position_;

        size = Vector2f(width,height);

        box = new RectangleShape(Vector2f(range, size.y));
        box.position = position;
        box.size(size);
        box.fillColor(Color(0,0,0,127));
        box.outlineColor(Color.White);
        box.outlineThickness(1);

        peakBox = new RectangleShape(Vector2f(3, height   ));
        peakBox.position = position + Vector2f(peak, 0);
        peakBox.size(Vector2f(4,15));
        peakBox.fillColor(Color.Red);

        current = new RectangleShape(Vector2f(1, height));
        current.position = position + Vector2f(avg, 0);
        current.fillColor(Color.Green);

        t = new Text(data, font, size.y.to!int);
        t.position = position + Vector2f(0, 0);
        t.setColor(Color.White);

        data = data_;
    }

    void update(float current_){
        float cur = current_;
        float peakdiff = peak;

        if (current_ > peak || peak == float.nan){
            peak = current_;
        } else {
            peak -= peak * 0.005;
        }

        peakdiff = peakdiff - peak;
        if (peakdiff < 2){
            peakdiff = 2;
        }

        peakBox.size = Vector2f(5, size.y);
        peakBox.position = position + Vector2f(peak, 0);

        current.size(Vector2f(cur, size.y));
        current.position = position;
        box.position = position;

        t.setString(format("%s: %.2f %.2f", data, cur,peak));
    }

    void draw(RenderWindow window){
        window.draw(box);
        window.draw(current);
        window.draw(peakBox);
        window.draw(t);
    }
}