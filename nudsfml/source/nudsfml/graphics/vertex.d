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