module dgui.widgets.togglebuttonarray;

import std.stdio;
import nudsfml.graphics;
import dgui.graphics.roundedrectangle;
import dgui.widget;
import dgui.handler;

import dgui.widgets.togglebutton;

class ToggleButtonArray : Widget {
    ToggleButton [] buttons;
    bool spaceEvenly = false;

    this (Handler handler, string [] labels, Vector2f position = Vector2f(0,0), Vector2f size = Vector2f(100,20), bool spaceEvenly = false){
        super(handler, position, size);
        this.spaceEvenly = spaceEvenly;

        assert(labels.length > 0, "ToggleButtonArray: labels.length must be > 0");
        buttons.length = labels.length;

        if(spaceEvenly){
            float buttonWidth = size.x / labels.length;
            float buttonHeight = size.y;
            for(int i = 0; i < labels.length; i++){
                buttons[i] = new ToggleButton(handler, labels[i], false, Vector2f(i * buttonWidth, 0), Vector2f(buttonWidth, buttonHeight));
            }

        } else {
            Vector2f offset = Vector2f(0, 0);
            for(int i = 0; i < labels.length; i++){
                buttons[i] = new ToggleButton(handler, labels[i], false, Vector2f(0, 0), size);
                buttons[i].position = Vector2f(offset.x, 0);
                buttons[i].size = buttons[i].preferredMinSize();
                offset = offset + Vector2f(buttons[i].size.x, 0);
            }
        } 

        for(int i = 0; i < labels.length; i++){
            if(labels.length != 1){
                if(i == 0){
                    buttons[i].rect.topRight = false;
                    buttons[i].rect.bottomRight = false;
                } else if(i == labels.length - 1){
                    buttons[i].rect.topLeft = false;
                    buttons[i].rect.bottomLeft = false;
                } else {
                    buttons[i].rect.topRight = false;
                    buttons[i].rect.bottomRight = false;
                    buttons[i].rect.topLeft = false;
                    buttons[i].rect.bottomLeft = false;
                }
            }
        }
    }

    override string onMouseClicked(Event e) {
        Vector2i mousePos = Vector2i(e.mouseButton.x, e.mouseButton.y);
        Vector2i relative = getReleativePosition(mousePos);

        foreach(button ; buttons){
            if(button.contains(relative)){
                button.onMouseClicked(e);
                return button.label;
            }
        }
        return super.onMouseClicked(e);
    }

    override void updateSize(){
        if(spaceEvenly){
            float buttonWidth = size.x / buttons.length;
            float buttonHeight = size.y;

            for(int i = 0; i < buttons.length; i++){
                buttons[i].position = Vector2f(i * buttonWidth, 0);
                buttons[i].size = Vector2f(buttonWidth, buttonHeight);
            }
        } else {
            Vector2f offset = Vector2f(0, 0);
            for(int i = 0; i < buttons.length; i++){
                buttons[i].position = Vector2f(offset.x, 0);
                buttons[i].size = buttons[i].preferredMinSize();
                offset = offset + Vector2f(buttons[i].size.x, 0);
            }
        } 
        for(int i = 0; i < buttons.length; i++){
            
            if(buttons.length != 1){
                if(i == 0){
                    buttons[i].rect.topRight = false;
                    buttons[i].rect.bottomRight = false;
                } else if(i == buttons.length - 1){
                    buttons[i].rect.topLeft = false;
                    buttons[i].rect.bottomLeft = false;
                } else {
                    buttons[i].rect.topRight = false;
                    buttons[i].rect.bottomRight = false;
                    buttons[i].rect.topLeft = false;
                    buttons[i].rect.bottomLeft = false;
                }
            }
        }

    }

    override void onDraw(RenderTarget target, Vector2f offset){
        Vector2f drawPosition = position + offset;
        Vector2f drawAdjust = Vector2f(0,0);
        for(int i = 0; i < buttons.length; i++){
            drawPosition = position + offset;// + drawAdjust;;
            buttons[i].draw(target, drawPosition);
            drawAdjust += Vector2f(buttons[i].size.x, 0);
        }
    }
}

unittest {
    import util.debugwindow;
    import std.stdio;

    import dgui.widgets.frame;

    auto dbgwin = new DebugWindow("ToggleButtonArray", 30f);
    auto handler = new Handler(dbgwin.win);

    auto frame = new Frame(handler, "Toggle Button Array - Test", Vector2f (20, 20), Vector2f(400, 300));
    handler.registerChild(frame);

    auto tba = new ToggleButtonArray(handler, ["Button 1", "Button 2", "Button 3"], Vector2f(10, 10), Vector2f(380, 20), true); 
    auto tbaa = new ToggleButtonArray(handler, ["bright", "Butasdf ton 2", "Bsdd on 3"], Vector2f(10, 10 + 25), Vector2f(380, 20), true); 
    auto tbab = new ToggleButtonArray(handler, ["Car", "Button 2", "list", "Salid"], Vector2f(10, 10 + 25 * 2), Vector2f(380, 20), false); 
    auto tbac = new ToggleButtonArray(handler, ["Car", "Salid"], Vector2f(10, 85), Vector2f(380, 10 + 25 * 3), false); 
    auto tbad = new ToggleButtonArray(handler, ["Car Salid"], Vector2f(10, 110), Vector2f(380, 10 + 25 * 4), false); 

    frame.registerChild(tba);
    frame.registerChild(tbaa);
    frame.registerChild(tbab);
    frame.registerChild(tbac);
    frame.registerChild(tbad);

    dbgwin.updateDelegate = (delta) {
        handler.update(delta);
    };
    dbgwin.eventDelegate = &handler.handleEvent;
    
    dbgwin.drawDelegate = (window) {
        handler.draw();
    };

    dbgwin.run();
}

unittest {
    import std.stdio;
    writeln("math example");

    ulong value = 32;
    value = value  * (1024 * 1024 * 1024);
    writeln(value);
    value = value >> 31;
    writeln(value);

    writeln ("math example end");
}