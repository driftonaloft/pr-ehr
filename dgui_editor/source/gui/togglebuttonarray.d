module gui.togglebuttonarray;

import std.conv;
import std.stdio;

import nudsfml.graphics;
import gfx;

import gui.widget;
import gui.system;

import gui.togglebutton;

class ToggleButtonArray : Widget {
    ToggleButton [] buttons;
    string [] items;

    int colums;
    int rows;

    Vector2f buttonSize;
    int selected;

    @property {
        override Vector2f position (Vector2f pos) {
            m_position = pos;
            return m_position;
        }

        override Vector2f position(){
            return m_position;
        }
    }

    this (GuiSystem gui_, Vector2f pos_ , Vector2f size_ , string [] items_ , int colums_ = 2) {
        super(gui_, pos_, size_);
        items = items_;
        selected = 0;
        colums = colums_;
        buttonSize = Vector2f (size.x / colums, 20);
        


        for (int i = 0; i < items.length; i++) {
            auto button = new ToggleButton(gui, items[i]);
            if(i == 0){
                button.rect.topRight = false;
                button.rect.bottomRight = false;
                button.rect.bottomLeft = false;
            } else  if (i == colums - 1) {
                button.rect.topLeft = false;
                button.rect.bottomLeft = false;
                button.rect.bottomRight = false;
            } else if (i == items.length - 1) {
                button.rect.topRight = false;
                button.rect.topLeft = false;
                button.rect.bottomLeft = false;
            } else if (i == items.length - colums) {
                button.rect.topRight = false;
                button.rect.topLeft = false;
                button.rect.bottomRight = false;
            } else {
                button.rect.topRight = false;
                button.rect.topLeft = false;
                button.rect.bottomRight = false;
                button.rect.bottomLeft = false;
            }
            button.size = buttonSize;

            buttons ~= button;

        }
    }

    void calcToggleButtonsPosition(){
        rows = ((items.length / colums) + 1).to!int;
        for (int i = 0; i < buttons.length; i++) {
            Vector2f pos = Vector2f( m_position.x + (i % colums) * buttonSize.x,
                                     m_position.y + (i / colums) * buttonSize.y );
            buttons[i].position = pos;
        }

        float width = (colums * buttonSize.x);
        float height = (rows * buttonSize.y);
        m_size = Vector2f(width, height);
    }

    override void onClick(Vector2f point){
        auto pos = getReleativePoint(point);
        for (int i = 0; i < buttons.length; i++) {
            if (buttons[i].getGlobalBounds().contains(pos)) {
                selected = i;
                break;
            }
        }
        if(selected < items.length) {
            foreach(i , button ; buttons) {
                if(i == selected) {
                    button.value = true;
                } else {
                    button.value = false;
                }
            }
        }
        writeln ("toggle button selected: ",selected);
    }

    override void drawSelf(RenderTarget target, Vector2f offset) {
        calcToggleButtonsPosition();
        for (int i = 0; i < buttons.length; i++) {
            buttons[i].draw(target, offset);
        }
    }
}