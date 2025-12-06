module util.string;

import std.string;
import std.traits;
import std.utf;
import std.math;

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
