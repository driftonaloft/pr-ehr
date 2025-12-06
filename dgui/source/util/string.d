module util.string;

import std.conv;
import std.algorithm;

string erase(string s, int i){
    char [] temparray = s.to!(char[]);
    string temp = temparray.remove(i).to!string;
    return temp;
}

string stringFill(string fillChars, ulong length ){
    string retval; 
    for(int i = 0 ; i < length ; i ++ ){
        retval ~= fillChars;
    }
    return retval;
}



unittest {
    import std.stdio;
    writeln("util.string erase");
    string test = "0123456789";
    string testb = test.erase(5);
    writeln(test);
    writeln(testb);
}