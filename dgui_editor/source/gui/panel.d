module gui.panel;

import std.stdio;

import nudsfml.graphics;

import gfx;

import gui.system;
import gui.widget;

class Panel : Widget {
    RoundedRectangle shape;

    this( GuiSystem gui_ , Vector2f position_ , Vector2f size_ ){
        super( gui_ , position_ , size_ );


        shape = new RoundedRectangle();
        shape.position = position_ ;
        shape.size = size_ ;
        shape.fillColor =  gui.theme["panel"] ;
        shape.outlineColor =  gui.theme["panel_outline"] ;
        shape.outlineThickness = 1.0f ;

    }

    override void drawSelf(RenderTarget target, Vector2f offset) {
        gui.win.draw( shape );
    }


}
