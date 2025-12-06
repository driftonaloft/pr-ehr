module util;

import std.string;
import std.traits;
import std.utf;
import std.math;

import nudsfml.graphics.color;
import nudsfml.graphics;

string subString(string s, ulong start, long end) {
    ulong startindex = s.toUTFindex(start);
    ulong endindex = s.toUTFindex(end) + startindex;
    return s[start .. end];
}

string subString(string s, ulong start) {
    ulong startindex = s.toUTFindex(start);
    return s[startindex .. $];
}

unittest {
    import std.stdio;
    writeln("subString Tests");
    writeln("subString(\"abcdef\", 0, 2) = " ~ subString("abcdef", 0, 2));
    string s = "abcdefghijklmnopqrstuvwxyz";
    assert(subString(s, 0, 1) == "a");
    assert(subString(s, 0, 2) == "ab");
    assert(subString(s, 0, 3) == "abc");
    assert(subString(s, 0, 4) == "abcd");
    assert(subString(s, 0, 5) == "abcde");
    assert(subString(s, 0, 6) == "abcdef");
    assert(subString(s, 0, 7) == "abcdefg");
    assert(subString(s, 1, 8) == "bcdefgh");
    assert(subString(s, 2, 9) == "cdefghi");
    assert(subString(s, 3, 10) == "defghij");
    assert(subString(s, 4, 11) == "efghijk");


    s = "abdefghi";
    assert(subString(s, 4) == "fghi");
    assert(subString(s, 5) == "ghi");
    assert(subString(s, 6) == "hi");
    assert(subString(s, 7) == "i");
    assert(subString(s, 8) == "");

    writeln("subString(\"abcdef\",2) = " ~ subString("abcdef", 2));
    writeln("done");

}

Color colorFromHex(string hexColor){
    import std.conv;
    import std.stdio;
    hexColor = hexColor.subString(1);
    
    /*  debug conversion
     writeln("hexColor: " ~ hexColor);
    writeln("r: ", hexColor.subString(0,2));
    writeln("g: ", hexColor.subString(2,4));
    writeln("b: ", hexColor.subString(4,6));
    */

    ubyte r = hexColor.subString(0,2).to!ubyte(16);
    ubyte g = hexColor.subString(2,4).to!ubyte(16);
    ubyte b = hexColor.subString(4,6).to!ubyte(16);
    return Color(r,g,b);
}

unittest {
    import std.stdio;
    writeln("colorFromHex Tests");
    assert(colorFromHex("#FF0000") == Color(255,0,0));
    assert(colorFromHex("#00FF00") == Color(0,255,0));
    assert(colorFromHex("#0000FF") == Color(0,0,255));
    writeln("done");
}


float lineToAngle(Vector2f p1, Vector2f p2){
    return lineToAngle(p1.x, p1.y,p2.x, p2.y);
}

float lineToAngle(float x1, float y1, float x2, float y2){
    import std.math;
    float angle = atan2(y2 - y1, x2 - x1);
    if(angle < 0){
        angle += 2*PI;
    }
    return angle * 180/PI;
}


float distance(Vector2f p1, Vector2f p2){
    return distance(p1.x, p1.y,p2.x, p2.y);
}

float distance(float x1, float y1, float x2, float y2){
    return sqrt(pow(x2-x1,2) + pow(y2-y1,2));
}



unittest {
    import std.stdio;
    writeln("lineToAngle Tests");
    writeln(lineToAngle(0,0,0,1));

}