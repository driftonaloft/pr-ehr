module nudsfml.graphics.color;

import std.traits;
import std.algorithm;

import bindbc.sfml.graphics;

struct Color {
    ubyte r = 0;
    ubyte g = 0;
    ubyte b = 0;
    ubyte a = 255;

    static immutable Black = Color(0, 0, 0, 255);
    static immutable White = Color(255, 255, 255, 255);
    static immutable Red = Color(255, 0, 0, 255);
    static immutable Green = Color(0, 255, 0,255);
    static immutable Blue = Color(0, 0, 255,255);
    static immutable Yellow = Color(255, 255, 0, 255);
    static immutable Magenta = Color(255, 0, 255, 255);
    static immutable Cyan = Color(0, 255, 255, 255);
    static immutable Transparent = Color(0, 0, 0, 0);

    string toString() const {
        import std.conv;
        return "(R: " ~ text(r) ~ " G: " ~ text(g) ~ " B: " ~ text(b) ~ " A: " ~ text(a) ~")";
    }

    Color opBinary(string op)(Color otherColor) const
        if((op == "+") || (op == "-") || (op == "*"))
    {
        static if(op == "+")
        {
            return Color(cast(ubyte)min(r+otherColor.r, 255),
                         cast(ubyte)min(g+otherColor.g, 255),
                         cast(ubyte)min(b+otherColor.b, 255),
                         cast(ubyte)min(a+otherColor.a, 255));
        }
        static if(op == "-")
        {
            return Color(cast(ubyte)max(r-otherColor.r, 0),
                         cast(ubyte)max(g-otherColor.g, 0),
                         cast(ubyte)max(b-otherColor.b, 0),
                         cast(ubyte)max(a-otherColor.a, 0));
        }
        static if(op == "*")
        {
            return Color(cast(ubyte)(r*otherColor.r / 255),
                         cast(ubyte)(g*otherColor.g / 255),
                         cast(ubyte)(b*otherColor.b / 255),
                         cast(ubyte)(a*otherColor.a / 255));
        }
    }

    Color opBinary(string op, E)(E num) const
        if(isNumeric!(E) && ((op == "*") || (op == "/")))
    {
        static if(op == "*")
        {
            //actually dividing or multiplying by a negative
            if(num < 1)
            {
                return Color(cast(ubyte)max(r*num, 0),
                             cast(ubyte)max(g*num, 0),
                             cast(ubyte)max(b*num, 0),
                             cast(ubyte)max(a*num, 0));
            }
            else
            {
                return Color(cast(ubyte)min(r*num, 255),
                             cast(ubyte)min(g*num, 255),
                             cast(ubyte)min(b*num, 255),
                             cast(ubyte)min(a*num, 255));
            }
        }
        static if(op == "/")
        {
            //actually multiplying or dividing by a negative
            if(num < 1)
            {
                return Color(cast(ubyte)min(r/num, 255),
                             cast(ubyte)min(g/num, 255),
                             cast(ubyte)min(b/num, 255),
                             cast(ubyte)min(a/num, 255));
            }
            else
            {
                return Color(cast(ubyte)max(r/num, 0),
                             cast(ubyte)max(g/num, 0),
                             cast(ubyte)max(b/num, 0),
                             cast(ubyte)max(a/num, 0));
            }
        }
    }

    ref Color opOpAssign(string op)(Color otherColor)
        if((op == "+") || (op == "-") || (op == "*"))
    {
        static if(op == "+")
        {
            r = cast(ubyte)min(r+otherColor.r, 255);
            g = cast(ubyte)min(g+otherColor.g, 255);
            b = cast(ubyte)min(b+otherColor.b, 255);
            a = cast(ubyte)min(a+otherColor.a, 255);
        }
        static if(op == "-")
        {
            r = cast(ubyte)max(r-otherColor.r, 0);
            g = cast(ubyte)max(g-otherColor.g, 0);
            b = cast(ubyte)max(b-otherColor.b, 0);
            a = cast(ubyte)max(a-otherColor.a, 0);
        }
        static if(op == "*")
        {
            r = cast(ubyte)(r*otherColor.r / 255);
            g = cast(ubyte)(g*otherColor.g / 255);
            b = cast(ubyte)(b*otherColor.b / 255);
            a = cast(ubyte)(a*otherColor.a / 255);
        }

        return this;
    }

ref Color opOpAssign(string op, E)(E num)
        if(isNumeric!(E) && ((op == "*") || (op == "/")))
    {
        static if(op == "*")
        {
            //actually dividing or multiplying by a negative
            if(num < 1)
            {
                r = cast(ubyte)max(r*num, 0);
                g = cast(ubyte)max(g*num, 0);
                b = cast(ubyte)max(b*num, 0);
                a = cast(ubyte)max(a*num, 0);
            }
            else
            {
                r = cast(ubyte)min(r*num, 255);
                g = cast(ubyte)min(g*num, 255);
                b = cast(ubyte)min(b*num, 255);
                a = cast(ubyte)min(a*num, 255);
            }

            return this;
        }
        static if(op == "/")
        {
            //actually multiplying or dividing by a negative
            if( num < 1)
            {
                r = cast(ubyte)min(r/num, 255);
                g = cast(ubyte)min(g/num, 255);
                b = cast(ubyte)min(b/num, 255);
                a = cast(ubyte)min(a/num, 255);
            }
            else
            {
                r = cast(ubyte)max(r/num, 0);
                g = cast(ubyte)max(g/num, 0);
                b = cast(ubyte)max(b/num, 0);
                a = cast(ubyte)max(a/num, 0);
            }

            return this;
        }
    }
    /**
     * Overload of the `==` and `!=` operators.
     *
     * This operator compares two colors and check if they are equal.
     *
     * Params:
     * otherColor = the Color to be compared with
     *
     * Returns: true if colors are equal, false if they are different.
     */
    bool opEquals(Color otherColor) const
    {
        return ((r == otherColor.r) && (g == otherColor.g) && (b == otherColor.b) && (a == otherColor.a));
    }


}

sfColor fromColor(Color color) {
    sfColor c = sfColor(color.r,
                        color.g, 
                        color.b, 
                        color.a);
    return c;
}