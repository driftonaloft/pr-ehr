module gfx.hsv;

import nudsfml.graphics.color;

import std.conv;

Color HSVtoRGB(float h, float s, float v){
    import std.math;
    Color rgb;
    float r = 0;
    float g = 0;
    float b = 0;
    int i = floor(h / 60.0).to!int;
    float f = h / 60.0 - i;
    float p = v * (1.0 - s);
    float q = v * (1.0 - f * s);
    float t = v * (1.0 - (1.0 - f) * s);

    if (i == 0) {
        r = v;
        g = t;
        b = p;
    } else if (i == 1) {
        r = q;
        g = v;
        b = p;
    } else if (i == 2) {
        r = p;
        g = v;
        b = t;
    } else if (i == 3) {
        r = p;
        g = q;
        b = v;
    } else if (i == 4) {
        r = t;
        g = p;
        b = v;
    } else if (i == 5) {
        r = v;
        g = p;
        b = q;
    }

    rgb.r = (r * 255).to!ubyte;
    rgb.g = (g * 255).to!ubyte;
    rgb.b = (b * 255).to!ubyte;
    return rgb;
}