module gui.table;

import nudsfml.graphics;
import gui.widgets;
import gui.system;
import gfx;

import std.algorithm;
import std.uni;
import std.stdio;

struct TableElement {
    string value;
    bool editable;
    bool shaded;
}

class Table : Widget {
    TableElement[] table;
    int[] columnsWidth;

    int rows;
    int columns;
    int selectedRow;
    int selectedColumn;

    int endWidth = 20;

    Color outline = Color(140, 140, 140);
    Color shaded = Color(60, 60, 60);
    Color selected = Color(80, 80, 80);
    Color base = Color(40, 40, 40);
    Color uneditable = Color(210, 0, 0);

    Text t;

    RoundedRectangle ul, ur, ll, lr;
    RectangleShape rect;
    RectangleShape c;

    this(Gui gui_, int width, int height) {
        super(gui_);

        columns = width;
        rows = height;

        table.length = width * height;
        columnsWidth = [100, 100];

        ul = new RoundedRectangle();
        ul.fillColor = shaded;
        ul.outlineColor = outline;
        ul.outlineThickness = 1;
        ul.bottomRight = false;
        ul.topRight = false;
        ul.bottomLeft = false;

        ur = new RoundedRectangle();
        ur.outlineColor = outline;
        ur.fillColor = shaded;
        ur.outlineThickness = 1;
        ur.bottomRight = false;
        ur.topLeft = false;
        ur.bottomLeft = false;

        ll = new RoundedRectangle();
        ll.fillColor = shaded;
        ll.outlineColor = outline;
        ll.outlineThickness = 1;
        ll.bottomRight = false;
        ll.topLeft = false;
        ll.topRight = false;

        lr = new RoundedRectangle();
        lr.fillColor = shaded;
        lr.outlineColor = outline;
        lr.outlineThickness = 1;
        lr.bottomLeft = false;
        lr.topLeft = false;
        lr.topRight = false;

        rect = new RectangleShape();
        rect.fillColor = base;
        rect.outlineThickness = 1;
        rect.outlineColor = outline;

        c = new RectangleShape();
        c.fillColor = Color(255, 255, 255, 30);
        c.size = Vector2f(9, 16);

        t = new Text("", gui.fonts["default"], 16);
        t.fillColor = (gui.theme["text"]);
    }

    ref TableElement opIndex(int c, int r) {
        int index = c + r * columns;
        if (index < table.length) {
            return table[index];
        }
        return table[0];
    }

    override void onCursor() {
        if (cursor < 0) {
            cursor = 0;
        }
        if (cursor >= m_value.length) {
            cursor = cast(int)(m_value.length);
        }
    }

    // TODO: write code to handle if the drawn table fits within the size of the table widget
    // so that the corners fo the table are rounded
    // provide method determin the max length of text within a cell and indicate the text is abriviated

    override void onDraw(RenderTarget target, Vector2f offset) {
        Vector2f drawpos = m_position + offset;
        Vector2f pos = drawpos;

        for (int y = 0; y < rows; y++) {
            pos.x = drawpos.x;
            for (int x = 0; x < columns; x++) {
                if (x == 0 && y == 0) {
                    ul.position = pos;
                    ul.size = Vector2f(columnsWidth[x], endWidth);
                    target.draw(ul);
                } else {
                    rect.position = pos;
                    rect.size = Vector2f(columnsWidth[x], endWidth);
                    target.draw(rect);
                }

                t.position = pos;
                auto v = opIndex(x, y);
                bool drawC = false;

                if (v.value.length > 0) {
                    t.setString(v.value);
                    auto cp = t.findCharacterPos(cursor) + Vector2f(0, 2);
                    if (v.editable) {
                        t.fillColor = (gui.theme["text"]);
                    } else {
                        t.fillColor = (uneditable);
                    }
                    if (x == selectedColumn && y == selectedRow) {
                        t.fillColor = (selected);
                        drawC = true;
                    }

                    target.draw(t);
                    c.position = cp;
                    if (drawC) {
                        target.draw(c);
                    }
                }
                pos.x += columnsWidth[x];
            }
            pos.y += endWidth;
        }

        ur.position = Vector2f(pos.x, drawpos.y);
        ur.size = Vector2f(endWidth, endWidth);
        target.draw(ur);

        rect.position = Vector2f(pos.x, drawpos.y + endWidth);
        rect.size = Vector2f(endWidth, (pos.y - drawpos.y) - endWidth);
        target.draw(rect);

        lr.position = pos;
        lr.size = Vector2f(endWidth, endWidth);
        target.draw(lr);

        ll.position = Vector2f(drawpos.x, pos.y);
        ll.size = Vector2f(endWidth, endWidth);
        target.draw(ll);

        rect.position = Vector2f(drawpos.x + endWidth, pos.y);
        rect.size = Vector2f(pos.x - drawpos.x - endWidth - 1, endWidth);
        target.draw(rect);
    }

    override void onClick(Event e) {
        auto r = getReleativePosition(Vector2i(e.mouseButton.x, e.mouseButton.y));
        int y = r.y / endWidth;
        int x = -1;
        int px = 0;

        foreach (i, w; columnsWidth) {
            if (r.x >= px && r.x < px + w) {
                x = cast(int)(i);
                break;
            }
            px = px + w;
        }

        if (x >= 0 && x < columns && y >= 0 && y < rows) {
            selectedColumn = x;
            selectedRow = y;
            m_value = opIndex(x, y).value;
            cursor = (m_value.length < cursor) ? cursor : cast(int)(m_value.length);
        }

        super.onClick(e);
    }

    override void onText(Event e) {
        if (opIndex(selectedColumn, selectedRow).editable) {
            char c = cast(char)(e.text.unicode);
            if (c == '\b') {
                if (m_value.length > 0 && cursor > 0 && cursor <= m_value.length) {
                    string temp = m_value[0 .. (cursor - 1)];
                    temp ~= m_value[cursor .. m_value.length];
                    value = temp;
                    cursor--;
                }
            } else if (c == 127) {
                if (m_value.length > 0) {
                    if (cursor >= m_value.length) {
                        cursor = cast(int)(m_value.length);
                    } else {
                        string temp = m_value[0 .. cursor];
                        temp ~= m_value[(cursor + 1) .. m_value.length];
                        value = temp;
                    }
                }
            } else {
                if (isGraphical(c)) {
                    if (cursor <= m_value.length && cursor >= 0) {
                        string temp = m_value[0 .. cursor];
                        temp ~= c;
                        temp ~= m_value[cursor .. m_value.length];
                        m_value = temp;
                        cursor++;
                    }
                }
            }

            if (cursor < 0) {
                cursor = 0;
            } else if (cursor > m_value.length) {
                cursor = cast(int)(m_value.length);
            }
            opIndex(selectedColumn, selectedRow).value = m_value;
        }
    }
}
