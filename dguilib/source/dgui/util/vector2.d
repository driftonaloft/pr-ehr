module dgui.util.vector2;

import std.math;

import nudsfml.system;

T distance(T)(Vector2!T a, Vector2!T b) {
    import std.conv;
    Vector2f offset = a - b;
    return sqrt(offset.x * offset.x + offset.y * offset.y).to!T;
}

T length(T)(Vector2!T a) {
    import std.conv;
    return sqrt(a.x * a.x + a.y * a.y).to!T;   
}

Vector2!T normalize(T)(Vector2!T a) {
    float length = length(a);
    if(length == 0) {
        return Vector2!T(0, 0);
    }
    return a / length;
}

Vector2!T lerp(T)(Vector2!T a, Vector2!T b, float t) {
    return a + (b - a) * t;
}

unittest {
    import std.stdio; 
    writeln("--------------=<[ Testing dgui.util.vector2 ]>=--------------");
    writeln("Testing distance");
    assert(distance(Vector2f(0, 0), Vector2f(0, 0)) == 0);
    assert(distance(Vector2f(0, 0), Vector2f(1, 0)) == 1);
    assert(distance(Vector2f(0, 0), Vector2f(0, 1)) == 1);
    assert(distance(Vector2f(0, 0), Vector2f(1, 1)) == sqrt(2f));
    assert(distance(Vector2f(0, 0), Vector2f(2, 2)) == sqrt(8f));
    assert(distance(Vector2f(0, 0), Vector2f(3, 4)) == 5);
    assert(distance(Vector2f(0, 0), Vector2f(4, 3)) == 5);

    writeln("Testing length");
    assert(length(Vector2f(0, 0)) == 0);
    assert(length(Vector2f(1, 0)) == 1);


    writeln("Testing normalize");
    assert(normalize(Vector2f(0, 0)) == Vector2f(0, 0));
    assert(normalize(Vector2f(1, 0)) == Vector2f(1, 0));
    assert(normalize(Vector2f(0, 1)) == Vector2f(0, 1));
    assert(normalize(Vector2f(1, 1)) == Vector2f(1f / sqrt(2f), 1f / sqrt(2f)));
    assert(normalize(Vector2f(2, 2)) == Vector2f(1f / sqrt(2f), 1f / sqrt(2f)));
    assert(normalize(Vector2f(3, 4)) == Vector2f(3f / 5f, 4f / 5f));
    assert(normalize(Vector2f(4, 3)) == Vector2f(4f / 5f, 3f / 5f));

    writeln("Testing lerp");
    assert(lerp(Vector2f(0, 0), Vector2f(0, 0), 0) == Vector2f(0, 0));
    assert(lerp(Vector2f(0, 0), Vector2f(0, 0), 1) == Vector2f(0, 0));
    assert(lerp(Vector2f(0, 0), Vector2f(1, 0), 0) == Vector2f(0, 0));
    assert(lerp(Vector2f(0, 0), Vector2f(1, 0), 1) == Vector2f(1, 0));
    assert(lerp(Vector2f(0, 0), Vector2f(1, 0), 0.5f) == Vector2f(0.5, 0));
    assert(lerp(Vector2f(0, 0), Vector2f(1, 0), 0.25f) == Vector2f(0.25, 0));
    assert(lerp(Vector2f(0, 0), Vector2f(1, 0), 0.75f) == Vector2f(0.75, 0));
}