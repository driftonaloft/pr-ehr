module gui.cage;

import gui;
import std.stdio;

import nudsfml.graphics;

class Cage : Widget {
    RectangleShape boundry;
    RectangleShape[8] handles;

    Vector2f handleSize;
    bool edit;
    int rows;
    int colums;
    int padding;

    int index;

    this(Gui gui_,string id_ = "default", Vector2f pos_ = Vector2f(0,0), Vector2f size_ = Vector2f(80,20)) {
        super(gui_);
        m_type = "cage"; //Convert to enums 

        id = id_;
        position = pos_;
        size = size_;

        rows = 1;
        colums = 1;
        padding = 0;

        handleSize = Vector2f(6, 6);
        boundry = new RectangleShape();

        foreach (ref h; handles) {
            h = new RectangleShape();
            h.size = handleSize;
            h.fillColor = Color(255, 128, 128);
        }
        
        boundry.fillColor = Color.Transparent;
        boundry.outlineColor = Color.White;
        boundry.outlineThickness = 1;

        index = -1;
        edit = false;
        updateSize();
    }

    void updateSize() {
        import std.conv;
        m_handle = IntRect(0,0,m_size.x.to!int ,m_size.y.to!int);
        if (children.length > 0) {
            Vector2f childSize, childOffset;
            childSize.x = cast(float)((m_size.x / colums) - padding - 1);
            childSize.y = (m_size.y / rows) - padding - 1;
            childOffset.x = (m_size.x / colums);
            childOffset.y = (m_size.y / rows);

            int i = 0;

            Vector2f pos = Vector2f(0, 0);
            for (int r = 0; r < rows; r++) {
                pos.y = childOffset.y * r;
                for (int c = 0; c < colums; c++) {
                    pos.x = childOffset.x * c;
                    if (i < children.length) {
                        children[i].position = pos;
                        children[i].size = childSize;
                    } else {
                        goto done__;
                    }
                    i++;
                }
            }
            done__:
        }
    }

    override void onDrag(Vector2i current, Vector2i offset) {
        enum PointName{
            TopLeft = 0,
            TopRight = 1,
            BottomRight = 2,
            BottomLeft  = 3,
            Top = 4,
            Right = 5,
            Bottom = 6,
            Left = 7,
            None =  -1
        }

        auto p = getReleativePosition(current);
        Vector2i delta = p - offset;

        if (edit) {
            PointName pn = cast(PointName)index;
            switch (pn) {
                case PointName.TopLeft:
                    m_position += Vector2f(delta.x, delta.y);
                    m_size -= delta;
                    break;
                case PointName.TopRight:
                    m_size.x = p.x;
                    m_position.y += delta.y;
                    m_size.y -= delta.y;
                    break;
                case PointName.BottomRight:
                    m_size = p;
                    break;
                case PointName.BottomLeft:
                    m_position.x += delta.x;
                    m_size.x -= delta.x;
                    m_size.y = p.y;
                    break;
                case PointName.Top:
                    m_position.y += delta.y;
                    m_size.y -= delta.y;
                    break;
                case PointName.Right:
                    m_size.x = p.x;
                    break;
                case PointName.Bottom:
                    m_size.y = p.y;
                    break;
                case PointName.Left:
                    m_position.x += delta.x;
                    m_size.x -= delta.x;
                    break;
                case PointName.None:
                    m_position += p - offset;
                    if (parent !is null) {
                        if (m_position.x < 0)
                            m_position.x = 0;
                        if (m_position.y < 0)
                            m_position.y = 0;
                        if (m_position.x + m_size.x > parent.size.x)
                            m_position.x = parent.size.x - size.x;
                        if (m_position.y + m_size.y > parent.size.y)
                            m_position.y = parent.size.y - size.y;
                    }
                    break;
                default:
                    m_position += delta;
                    break;
            }

            if (m_size.x < 6 && m_size.y < 6) {
                switch (pn) {
                case PointName.TopLeft:
                    pn = PointName.BottomRight;
                    break;
                case PointName.BottomRight:
                    pn = PointName.TopLeft;
                    break;
                case PointName.TopRight:
                    pn = PointName.BottomLeft;
                    break;
                case PointName.BottomLeft:
                    pn = PointName.TopRight;
                    break;
                default:
                    break;
                }
            } else if (m_size.x < 0) {
                switch (pn) {
                case PointName.TopLeft:
                    pn = PointName.TopRight;
                    break;
                case PointName.TopRight:
                    pn = PointName.TopLeft;
                    break;
                case PointName.BottomRight:
                    pn = PointName.BottomLeft;
                    break;
                case PointName.BottomLeft:
                    pn = PointName.BottomRight;
                    break;
                case PointName.Right:
                    pn = PointName.Left;
                    break;
                case PointName.Left:
                    pn = PointName.Right;
                    break;
                default:
                    break;
                }
            } else if (m_size.y < 0) {
                switch (index) {
                case 0:
                    index = 3;
                    break;
                case 1:
                    index = 2;
                    break;
                case 2:
                    index = 1;
                    break;
                case 3:
                    index = 0;
                    break;
                case 4:
                    index = 6;
                    break;
                case 6:
                    index = 4;
                    break;
                default:
                    break;
                }
            }

            index = cast(int)pn;

            if (m_size.x < 0) {
                m_position.x += m_size.x;
                m_size.x = m_size.x * -1;
            }
            if (m_size.y < 0) {
                m_position.y += m_size.y;
                m_size.y = m_size.y * -1;
            }

            updateSize();
        }

    }

    override void onClick(Event e) {
        Vector2i p = Vector2i(e.mouseButton.x, e.mouseButton.y);

        if (edit) {
            int i;
            for (i = 0; i < 8; i++) {
                IntRect box = IntRect(  Vector2i(handles[i].position) - Vector2i(3, 3), 
                                        Vector2i(handles[i].size) + Vector2i(3, 3));
                if (box.contains(p)) {
                    index = i;
                    break;
                }
            }
            if (i == 8)
                index = -1;

            if("click" in events){
                events["click"](e);
            }
        } else {
            super.onClick(e);
        }
        writeln("cage::onClick index: " , index);
    }

    override Widget contains(Vector2i point) {
        if (enabled) {
            IntRect box;
            Vector2f box_offset = Vector2f(5,5);
            if(edit){
                box = IntRect(Vector2i(m_position - box_offset),Vector2i( m_size + box_offset));
            } else {
                box = IntRect(Vector2i(m_position), Vector2i(m_size));
            }
            point -= position;
            auto tempSize = m_size + (handleSize / 2);
            if (!edit) {
                foreach (ref child; children) {
                    auto c = child.contains(point);
                    if (c !is null) {
                        return c;
                    }
                }
            }
            if (point.x < tempSize.x && point.x >= -3 && point.y < tempSize.y && point.y >= -3) {
                return this;
            }
        }
        return null;
    }

    override void draw(RenderTarget target, Vector2f offset) {
        if (enabled) {
            foreach (ref child; children) {
                child.draw(target, Vector2f(position) + offset);
            }
            onDraw(target, offset);
        }
    }

    override void onDraw(RenderTarget target, Vector2f offset) {
        if (edit) {
            boundry.position = position + offset;
            boundry.size = m_size;
            target.draw(boundry);

            Vector2f pos = position + offset;
            handles[0].position = pos - (handleSize / 2);
            handles[1].position = pos - (handleSize / 2) + Vector2f(m_size.x, 0);
            handles[2].position = pos - (handleSize / 2) + m_size;
            handles[3].position = pos - (handleSize / 2) + Vector2f(0, m_size.y);

            handles[4].position = pos - (handleSize / 2) + Vector2f((m_size.x / 2), 0);
            handles[5].position = pos - (handleSize / 2) + Vector2f(m_size.x, (m_size.y / 2));
            handles[6].position = pos - (handleSize / 2) + Vector2f((m_size.x / 2), m_size.y);
            handles[7].position = pos - (handleSize / 2) + Vector2f(0, (m_size.y / 2));

            int i = 0;
            foreach (ref handle; handles) {
                if (i++ == index) {
                    handle.fillColor = Color.Red;
                } else {
                    handle.fillColor = Color(255, 128, 128);
                }
                target.draw(handle);
            }
        }
    }
}
