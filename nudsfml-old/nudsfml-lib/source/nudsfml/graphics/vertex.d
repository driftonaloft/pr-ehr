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

module nudsfml.graphics.vertex;

import nudsfml.graphics.color;
import nudsfml.system.vector2;

/**
 * Define a point with color and texture coordinates.
 */
struct Vertex {
    /// 2D position of the vertex
    Vector2f position = Vector2f(0,0);
    /// Color of the vertex. Default is White.
    Color color = Color.White;
    /// 2D coordinates of the texture's pixel map to the vertex.
    Vector2f texCoords = Vector2f(0,0);

    /**
     * Construct the vertex from its position
     *
     * The vertex color is white and texture coordinates are (0, 0).
     *
     * Params:
     * thePosition = Vertex position
     */
    this(Vector2f thePosition) {
        position = thePosition;
    }

    /**
     * Construct the vertex from its position and color
     *
     * The texture coordinates are (0, 0).
     *
     * Params:
     *  thePosition = Vertex position
     *  theColor    = Vertex color
     */
    this(Vector2f thePosition, Color theColor){
        position = thePosition;
        color = theColor;
    }

    /**
     * Construct the vertex from its position and texture coordinates
     *
     * The vertex color is white.
     *
     * Params:
     *  thePosition  = Vertex position
     *  theTexCoords = Vertex texture coordinates
     */
    this(Vector2f thePosition, Vector2f theTexCoords) {
        position = thePosition;
        texCoords = theTexCoords;
    }

    /**
     * Construct the vertex from its position, color and texture coordinates
     *
     * Params:
     *  thePosition  = Vertex position
     *  theColor     = Vertex color
     *  theTexCoords = Vertex texture coordinates
     */
    this(Vector2f thePosition, Color theColor, Vector2f theTexCoords){
        position = thePosition;
        color = theColor;
        texCoords = theTexCoords;
    }
}