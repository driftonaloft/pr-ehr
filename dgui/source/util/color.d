module util.color;

import std.string;
import std.conv;

import nudsfml.graphics;

Color getColorHex(string hex){
    Color retval = Color(255,0,255);

    hex = hex.replace("#", "");
    hex = hex.strip();
    if(hex.length == 6){
        ubyte r = hex[0..2].to!ubyte;
        ubyte g = hex[2..4].to!ubyte;
        ubyte b = hex[4..6].to!ubyte;        
        retval = Color(r,g,b,255);
    } else if (hex.length == 8){
        ubyte r = hex[0..2].to!ubyte;
        ubyte g = hex[2..4].to!ubyte;
        ubyte b = hex[4..6].to!ubyte; 
        ubyte a = hex[4..6].to!ubyte;        
        retval = Color(r,g,b,a);
    }
    return retval;
}

Vector2f stringToVector2f(string s){
    import std.string;
    import std.conv;
    string[] parts = s.split(",");
    return Vector2f(parts[0].strip.to!float, parts[1].strip.to!float);
}