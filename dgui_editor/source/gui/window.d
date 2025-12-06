module gui.window;

import std.stdio;

import nudsfml.graphics;

import gui.widget;
import gui.system;

import gfx;


class WindowGui : Widget {
    RoundedRectangle rect;
    RoundedRectangle title;
    Text title_text;

    string m_text;

    this(GuiSystem gui_) {
        this(gui_, "Window", Vector2f(0,0), Vector2f(320,240));
    }

    this(GuiSystem gui_, string text_) {
        this(gui_, text_, Vector2f(0,0), Vector2f(100, 20));
    }

    this(GuiSystem gui_, string text_, Vector2f position_) {
        this(gui_, text_, position_, Vector2f(100, 20));
    }

    this(GuiSystem gui_, string text_, Vector2f position_, Vector2f size_) {
        writeln("Window constructor");
        super(gui_, position_, size_);

        m_text = text_;

        internalOffset = Vector2f(0, 24);

        title = new RoundedRectangle();
        title.bottomLeft = false;
        title.bottomRight = false;
        title.size = Vector2f(m_size.x, 24);
        title.position = position ;
        title.fillColor = gui.theme["window_title_background"];
        title.outlineColor = gui.theme["window_title_outline"];
        title.outlineThickness = 1.0f;

        rect = new RoundedRectangle();
        rect.topLeft = false;
        rect.topRight = false;
        rect.size = Vector2f(m_size.x, m_size.y - 24);
        rect.position = position   + Vector2f(0, 24);
        rect.fillColor = gui.theme["window_background"];
        rect.outlineColor = gui.theme["window_outline"];
        rect.outlineThickness = 1.0f;

        title_text = new Text();
        title_text.setString = name;
        title_text.position = position + Vector2f(5, 3);
        title_text.setFont(gui.fonts["default"]);
        title_text.setColor(gui.theme["window_title_text"]);
        title_text.setCharacterSize(13);
        title_text.setString(m_text);
    }
    
    override bool heldRegion(Vector2f point) {
        auto bounds = title.getGlobalBounds();
        return bounds.contains(point);
    }

    override void drawSelf(RenderTarget target, Vector2f offset) {
        auto totalOffset = offset + m_position;
        title.position = totalOffset;
        title_text.position = totalOffset + Vector2f(5, 3);
        rect.position = totalOffset + Vector2f(0, 24);

        gui.win.draw( title );
        gui.win.draw( title_text );
        gui.win.draw( rect );
    }
}
