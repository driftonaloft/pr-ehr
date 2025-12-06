module gui.cage;

import gui.widget;
import gui.system;

import nudsfml.graphics;


class Cage : Widget {
    bool snap;
    bool showGrid; //draws grid on parent may need to be moved to widget draws the grid extended to the edge of the parent
    int gridSize;
    Vector2f gridOffset;
    bool showAxis; //draws axis on parent may need to be moved to widget draws the axis of the children extended to the edge of the parent
    bool show;

    Text t;

    CircleShape [8] handles; // maybe replace with rectangles
    int selectedHandle;
    RectangleShape cage;

    this(GuiSystem gui_, Vector2f position_, Vector2f size_){
        super (gui_, position_, size_);

        snap = false;
        showGrid = false;
        showAxis = false;
        show = true;

        for(int i = 0; i < 8; i ++){
            handles[i] = new CircleShape(3);
            handles[i].fillColor(Color.Green);
            handles[i].origin(Vector2f(3,3));
        }

        cage = new RectangleShape;
        t = new Text ("Cage", gui.fonts["default"],18);
    }

    void updateHandles(Vector2f offest){
        handles[0].position(position);
        handles[1].position(position + Vector2f(size.x, 0));
        handles[2].position(position + Vector2f(size.x, size.y));
        handles[3].position(position + Vector2f(0, size.y));
        handles[4].position(position + Vector2f(size.x/2, 0));
        handles[5].position(position + Vector2f(size.x/2, size.y));
        handles[6].position(position + Vector2f(0, size.y/2));
        handles[7].position(position + Vector2f(size.x, size.y/2));
    }

    override void drawSelf(RenderTarget target, Vector2f offset) {
        if (show) {
            updateHandles(offset);

            cage.position = position + offset;
            target.draw(cage);

            foreach (i, h ; handles){
                if(i == selectedHandle){
                    h.fillColor(Color.Red);
                } else {
                    h.fillColor(Color.Green);
                }
                target.draw(h);
            }

            t.setColor = Color.White;
            t.position = position + offset + Vector2f(0, -20);
            target.draw(t);
        }
    }
}