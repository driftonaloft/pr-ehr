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

module nudsfml.graphics.primitivetype;

/**
 * Types of primitives that a $(VERTEXARRAY_LINK VertexArray) can render.
 *
 * Points and lines have no area, therefore their thickness will always be 1
 * pixel, regarldess the current transform and view.
 */
enum PrimitiveType
{
    /// List of individual points.
    Points,
    /// List of individual lines.
    Lines,
    /// List of connected lines; a point uses the previous point to form a line.
    LineStrip,
    /// List of individual triangles.
    Triangles,
    /**
     * List of connected triangles; a point uses the two previous points to form
     * a triangle.
     */
    TriangleStrip,
    /**
     * List of connected triangles; a point uses the common center and the
     * previous point to form a triangle.
     */
    TriangleFan,
    /// List of individual quads.
    Quads,

    /// //deorecated: List of individual triangles.
    LinesStrip = LineStrip,
    /// //deorecated: List of connected triangles.
    TrianglesStrip = TriangleStrip,
    /// //deorecated: List of connected triangles.
    TrianglesFan   = TriangleFan
}