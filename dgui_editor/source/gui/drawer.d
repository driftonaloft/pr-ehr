module gui.drawer;


import std.stdio;

import nudsfml.graphics;

import gfx.roundedrectangle;

import gui.system;
import gui.widget;

enum Dock {
    Left,
    Right,
    Top,
    Bottom
}

class Drawer : Widget {
    RoundedRectangle rect;
    RoundedRectangle rect_handle;

    Text title;

    float width = 0; 
    float height = 0;

    Vector2f m_internal_size;
    Vector2f closedPos;
    Vector2f openPos;

    Dock dock;
    bool open = true;

    this( GuiSystem gui_ , Vector2f position_ , Vector2f size_ , Dock dock_ = Dock.Left ) {
        super( gui_ , position_ , size_ );

        rect = new RoundedRectangle();
        rect.position = position_;
        rect.size = size_;
        rect.fillColor =  gui.theme["panel"];
        rect.outlineColor =  gui.theme["panel_outline"];
        rect.outlineThickness = 1.0f;

        rect_handle = new RoundedRectangle();
        rect_handle.position = position_;
        rect_handle.size = size_;
        rect_handle.fillColor =  gui.theme["panel_handle"];//replace with theme panel_handle
        rect_handle.outlineColor =  gui.theme["panel_outline"];
        rect_handle.outlineThickness = 1.0f;

        width = size_.x; //determin based on dock position  (ie left, right, top, bottom)
        height = size_.y;   //determin based on dock position  (ie left, right, top, bottom)

        dock = dock_;

        setDock(dock_);

    }

    override void handleEvents(Event e){
        switch(e.type){
            case Event.Type.Resized:
                setDock(dock);
                break;
            default:
                break;
        }
    }

    override void onClick(Vector2f point){
        auto pos = getReleativePoint(point);

        switch(dock ){
            case Dock.Left:
                if( pos.x > width - 20 ){
                    open = !open;
                }
                break;
            case Dock.Right:
                if( pos.x < 20 ){
                    open = !open;
                }
                break;
            case Dock.Top:
                if( pos.y > height - 20 ){
                    open = !open;
                }
                break;
            case Dock.Bottom:
                if( pos.y < 20 ){
                    open = !open;
                }
                break;  
            default: 
                break;
        }

        position = open ? openPos : closedPos;
    }

    void setDock( Dock dock_ ) {
        switch( dock_ ) {
            case Dock.Left:
                closedPos = Vector2f( 20 - size.x , 0 );
                openPos= Vector2f( 0 , 0); // adjust based on respected objects ie other drawers or paneles 
                m_size = Vector2f( width , gui.size.y );
                m_internal_size =  Vector2f( width - 20 , gui.size.y - 10 );
                internalOffset = Vector2f( 0 , 5 );
                break;
            case Dock.Right:
                closedPos = Vector2f( gui.size.x - 20 , 0 );
                openPos = Vector2f( gui.size.x - width , 0 ); // adjust based on respected objects ie other drawers or paneles
                size = Vector2f( width , gui.size.y );
                m_internal_size =  Vector2f( width - 20 , gui.size.y - 10 );
                internalOffset = Vector2f( 20 , 5 );
                break;
            case Dock.Top:
                closedPos = Vector2f( 0 , 20 - size.y );
                openPos = Vector2f( 0 , 0 ); // adjust based on respected objects ie other drawers or paneles
                m_size = Vector2f( gui.size.x , height );
                m_internal_size =  Vector2f( gui.size.x - 10 , height - 20 );
                internalOffset = Vector2f( 5 , 0 );
                break;
            case Dock.Bottom:
                closedPos = Vector2f( 0 , gui.size.y - 20 );
                openPos = Vector2f( 0 , gui.size.y - height ); // adjust based on respected objects ie other drawers or paneles
                m_size = Vector2f( gui.size.x , height );
                m_internal_size =  Vector2f( gui.size.x - 10 , height - 20 );
                internalOffset = Vector2f( 5 , 20 );
                break;
            default:
                break;
        }

        position = open ? openPos : closedPos;
    }

    override void drawSelf(RenderTarget target, Vector2f offset) {
        Vector2f tempos;

        if( open ) {
            tempos = m_position + offset;
        } else {
            tempos = closedPos + offset;
        }

        rect_handle.position = tempos;
        rect_handle.size = m_size;
        target.draw( rect_handle );

        rect.position = tempos + internalOffset;
        rect.size = m_internal_size;
        target.draw( rect );
    }
}
