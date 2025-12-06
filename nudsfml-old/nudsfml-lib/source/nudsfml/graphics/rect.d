/*--+{ NuDSFML 2.5.1 }+------------------------------------------------------*\
| NuDSFML 2.5.1 (new DSFML) is a refactor of DSFML 2.4 by Jeremy Dahaan       |
| it has been refactored to be based on CSFML 2.5.1 via the bindbc.sfml       |
| library by Drifton Aloft                                                    |
|                                                                             |
| Caution not all current DSFML features have been replicated / implimented   |
| yet. use at your own risk this software probably contains bugs, clever      |
| fixes and other programmer hijinks                                          |
\*---------------------------------------------------------------------------*/

/*
 * DSFML - The Simple and Fast Multimedia Library for D
 *
 * Copyright (c) 2013 - 2018 Jeremy DeHaan (dehaan.jeremiah@gmail.com)
 *
 * This software is provided 'as-is', without any express or implied warranty.
 * In no event will the authors be held liable for any damages arising from the
 * use of this software.
 *
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 *
 * 1. The origin of this software must not be misrepresented; you must not claim
 * that you wrote the original software. If you use this software in a product,
 * an acknowledgment in the product documentation would be appreciated but is
 * not required.
 *
 * 2. Altered source versions must be plainly marked as such, and must not be
 * misrepresented as being the original software.
 *
 * 3. This notice may not be removed or altered from any source distribution
 *
 *
 * DSFML is based on SFML (Copyright Laurent Gomila)
 */

module nudsfml.graphics.rect;

import std.traits;

import nudsfml.system.vector2;

struct Rect(T)
    if(isNumeric!(T))
{
    T left = 0;
    T top = 0;
    T width = 0;;
    T height = 0;

    this(T rectLeft, T rectTop, T rectWidth, T rectHeight){
        left = rectLeft;
        top = rectTop;
        width = rectWidth;
        height = rectHeight;
    }

    this(Vector2!(T) position, Vector2!(T) size){
        left = position.x;
        top = position.y;
        width = size.x;
        height = size.y;
    }

    bool contains(E)(E x, E y) const
        if(isNumeric!(E))
    {
        return x >= left && x <= left + width && y >= top && y <= top + height;
    }

    bool contains(E)(Vector2!(E) point) const
        if(isNumeric!(E))
    {
        return contains(point.x, point.y);
    }

    bool intersects(E)(Rect!(E) rectangle)
        if(isNumeric!(E)) 
    {
        Rect!(T) rect;
        return intersects(rectangle, rect);

    }

    bool intersects(E,O)(Rect!(E) rectangle, out Rect!(O) intersection)  
        if(isNumeric!(O) && isNumeric!(E)) 
    {
        O interLeft = max(left, rectangle.left);
        O interTop = max(top, rectangle.top);
        O interRight = min(left + width, rectangle.left + rectangle.width);
        O interBottom = min(top + height, rectangle.top + rectangle.height);

        if(interLeft < interRight && interTop < interBottom) {
            intersection = Rect!(O)(interLeft, interTop, interRight - interLeft, interBottom - interTop);
            return true;
        } else {
            intersection = Rect!(O)(0, 0, 0, 0);
            return false;
        }
    }

    bool opEquals(E)(const Rect!(E) otherRect) const
        if(isNumeric!(E)) 
    {
        return ((left == otherRect.left) && (top == otherRect.top) && 
                (width == otherRect.width) && (height == otherRect.height));
    }

    string toString() const {
        import std.conv;
        return "Rect(" ~ text(left) ~ ", " ~ text(top) ~ ", " ~ text(width) ~ ", " ~ text(height) ~ ")";
    }

    private T max(T a, T b) const {
        return a > b ? a : b;
    }

    private T min(T a, T b) const {
        return a < b ? a : b;
    }
}
    
alias IntRect = Rect!(int);
alias FloatRect = Rect!(float);
