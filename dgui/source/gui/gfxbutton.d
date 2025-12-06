module gui.gfxbutton;

import gui;
import gfx;

import nudsfml.graphics;


class GfxButton : Widget {
    Atlas atlas;

    IntRect texRect; // stored reference to texture rect
    Texture tex; //Stored reference to atlas texture

    RectangleShape img;
    RoundedRectangle button;
    Text buttonText;

    this(Gui gui_, string label_, Vector2f pos_ = Vector2f(5, 5), Vector2f size_ = Vector2f(64, 64)) {
        super (gui_);
        img = new RectangleShape;
        button = new RoundedRectangle;
        buttonText = new Text;
        buttonText.setFont(gui.fonts["default"]);
        buttonText.setCharacterSize(12);
        buttonText.fillColor = (Color.White);

        size = size_;
        position = pos_;
        label = label_;
    }
}