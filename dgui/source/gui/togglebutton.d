module gui.togglebutton;

import nudsfml.graphics;

import std.stdio;
import gui;
import gfx;

class ToggleButton : Widget {
    Text text;
    RoundedRectangle rect;

    override @property { //value
        override string value(string v) {
            m_value = v;
            if (v == "false"){
                checked = false;
            } else if (v == "true"){
                checked = true;
            }
            return m_value;
        }

        override string value() {
            return m_value;
        }
    }
    alias value = Widget.value;

    @property { //label
        override string label(string v) {
            m_label = v;
            text.setString = (v);
            return m_label;
        }

        override string label() {
            return m_label;
        }
    }
    alias label = Widget.label;

    this(Gui gui_, string label_ = "Default", Vector2f pos_ = Vector2f(0,0), Vector2f size_ = Vector2f(80,20), bool checked_ = false) {
        super(gui_);

        m_type = "togglebutton";
        color = Color(160, 160, 160, 255);

        text = new Text();
        text.setFont(gui.fonts["default"]);
        text.setCharacterSize(14);
        text.fillColor = (Color.White);

        rect = new RoundedRectangle();
        rect.radius = 5;
        rect.cornerCount = 4;
        rect.fillColor = color;
        rect.outlineColor = color - Color(2,2,2);
        rect.outlineThickness = 1;

        position = pos_;
        size = size_;
        label = label_;
        checked = checked_;
    }

    override void onClick(Event e) {
        checked = checked ? false : true;
        super.onClick(e);
    }

    override void onDraw(RenderTarget target, Vector2f offset) {
        //writeln("drawing togglebutton: ", label , " checked: ", checked);
        auto drawpos = position + offset;
        rect.position = drawpos;
        rect.size = size;
        if (checked) {
            rect.fillColor = color - Color(60, 60, 60,0);
            rect.outlineColor(color);
        } else {
            rect.fillColor = color;
        }

        auto bounds = text.getGlobalBounds();
        Vector2f textSize = Vector2f(bounds.width, bounds.height);
        Vector2f midpoint = size / 2;
        Vector2f textpos = midpoint - (textSize / 2) - Vector2f(0, 3);

        text.position = drawpos + textpos;

        target.draw(rect);
        target.draw(text);
    }
}
