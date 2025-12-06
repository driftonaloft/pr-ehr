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

/**
 * $(U RenderTexture) is the little brother of $(RENDERWINDOW_LINK). It
 * implements the same 2D drawing and OpenGL-related functions (see their base
 * class $(RENDERTARGET_LINK) for more details), the difference is that the
 * result is stored in an off-screen texture rather than being show in a window.
 *
 * Rendering to a texture can be useful in a variety of situations:
 * $(UL
 * $(LI precomputing a complex static texture (like a level's background from
 *   multiple tiles))
 * $(LI applying post-effects to the whole scene with shaders)
 * $(LI creating a sprite from a 3D object rendered with OpenGL)
 * $(LI etc.))
 *
 * Example:
 * ---
 * // Create a new render-window
 * auto window = new RenderWindow(VideoMode(800, 600), "DSFML window");
 *
 * // Create a new render-texture
 * auto texture = new RenderTexture();
 * if (!texture.create(500, 500))
 *     return -1;
 *
 * // The main loop
 * while (window.isOpen())
 * {
 *    // Event processing
 *    // ...
 *
 *    // Clear the whole texture with red color
 *    texture.clear(Color.Red);
 *
 *    // Draw stuff to the texture
 *    texture.draw(sprite);
 *    texture.draw(shape);
 *    texture.draw(text);
 *
 *    // We're done drawing to the texture
 *    texture.display();
 *
 *    // Now we start rendering to the window, clear it first
 *    window.clear();
 *
 *    // Draw the texture
 *    auto sprite = new Sprite(texture.getTexture());
 *    window.draw(sprite);
 *
 *    // End the current frame and display its contents on screen
 *    window.display();
 * }
 * ---
 *
 * $(PARA Like $(RENDERWINDOW_LINK), $(U RenderTexture) is still able to render
 * direct OpenGL stuff. It is even possible to mix together OpenGL calls and
 * regular DSFML drawing commands. If you need a depth buffer for 3D rendering,
 * don't forget to request it when calling `RenderTexture.create`.)
 *
 * See_Also:
 * $(RENDERTARGET_LINK), $(RENDERWINDOW_LINK), $(VIEW_LINK), $(TEXTURE_LINK)
 */
module nudsfml.graphics.rendertexture;

import bindbc.sfml.graphics;
import bindbc.sfml.window;
import bindbc.sfml.system;

import nudsfml.graphics.color;
import nudsfml.graphics.drawable;
import nudsfml.graphics.primitivetype;
import nudsfml.graphics.rect;
import nudsfml.graphics.renderstates;
import nudsfml.graphics.rendertarget;
import nudsfml.graphics.shader;
import nudsfml.graphics.text;
import nudsfml.graphics.texture;
import nudsfml.graphics.transform;
import nudsfml.graphics.vertex;
import nudsfml.graphics.view;

//import nudsfml.system.err;
import nudsfml.system.vector2;

/**
 * Target for off-screen 2D rendering into a texture.
 */
class RenderTexture : RenderTarget
{
    package sfRenderTexture* sfPtr;
    private Texture m_texture;
    private View m_currentView, m_defaultView;

    /// Default constructor.
    this()
    {
        sfPtr = null;//sfRenderTexture_construct();
        m_texture = null; //new Texture(sfRenderTexture_getTexture(sfPtr));
    }

    /// Desructor.
    ~this()
    {
        sfRenderTexture_destroy(sfPtr);
    }

    /**
     * Create the render-texture.
     *
     * Before calling this function, the render-texture is in an invalid state,
     * thus it is mandatory to call it before doing anything with the
     * render-texture.
     *
     * The last parameter, depthBuffer, is useful if you want to use the
     * render-texture for 3D OpenGL rendering that requires a depth-buffer.
     * Otherwise it is unnecessary, and you should leave this parameter to false
     * (which is its default value).
     *
     * Params:
     * 	width		= Width of the render-texture
     * 	height		= Height of the render-texture
     * 	depthBuffer	= Do you want this render-texture to have a depth buffer?
     *
     * Returns: True if creation has been successful.
     */
    bool create(uint width, uint height, bool depthBuffer = false) {
        if(sfPtr !is null){
            sfRenderTexture_destroy(sfPtr);
        }
        sfPtr = sfRenderTexture_create(width, height, depthBuffer);
         m_texture = new Texture(cast(sfTexture*)sfRenderTexture_getTexture(sfPtr));

        return sfPtr != null;
    }

    @property
    {
        /**
         * Enable or disable texture smoothing.
         */
        bool smooth(bool newSmooth)
        {
            sfRenderTexture_setSmooth(sfPtr, newSmooth);
            return newSmooth;
        }

        /// ditto
        bool smooth() const
        {
            return (sfRenderTexture_isSmooth(sfPtr)) > 0;
        }
    }

    @property
    {
        /**
         * Change the current active view.
         *
         * The view is like a 2D camera, it controls which part of the 2D scene
         * is visible, and how it is viewed in the render-target. The new view
         * will affect everything that is drawn, until another view is set.
         *
         * The render target keeps its own copy of the view object, so it is not
         * necessary to keep the original one alive after calling this function.
         * To restore the original view of the target, you can pass the result
         * of `getDefaultView()` to this function.
         */
        override View view(View newView)
        {
            sfView *viewPtr = sfView_create();
            sfView_setCenter(viewPtr, cast(sfVector2f)newView.center);
            sfView_setSize(viewPtr, cast(sfVector2f)newView.size);
            sfView_setRotation(viewPtr, newView.rotation);
            sfView_setViewport(viewPtr,cast(sfFloatRect) newView.viewport);

            sfRenderTexture_setView(sfPtr, viewPtr);
            return newView;
        }

        /// ditto
        override View view() const
        {
            View currentView;

            Vector2f currentCenter, currentSize;
            float currentRotation;
            FloatRect currentViewport;

            const(sfView*) v = sfRenderTexture_getView(sfPtr);

            currentView.center = cast(Vector2f)sfView_getCenter(v);
            currentView.size = cast(Vector2f)sfView_getSize(v);
            currentView.rotation = sfView_getRotation(v);
            currentView.viewport = cast(FloatRect)sfView_getViewport(v);

            return currentView;
        }
    }

    /**
     * Get the default view of the render target.
     *
     * The default view has the initial size of the render target, and never
     * changes after the target has been created.
     *
     * Returns: The default view of the render target.
     */
    View getDefaultView() const
    {
        View currentView;

        Vector2f currentCenter, currentSize;
        float currentRotation;
        FloatRect currentViewport;

        const(sfView*) v = sfRenderTexture_getDefaultView(sfPtr);

        currentView.center = cast(Vector2f)sfView_getCenter(v);
        currentView.size = cast(Vector2f)sfView_getSize(v);
        currentView.rotation =  sfView_getRotation(v);
        currentView.viewport = cast(FloatRect)sfView_getViewport(v);

        return currentView;
    }

    /**
     * Return the size of the rendering region of the target.
     *
     * Returns: Size in pixels.
     */
    Vector2u getSize() const
    {
        Vector2u temp = cast(Vector2u)sfRenderTexture_getSize(sfPtr);
        return temp;
    }

    /**
     * Get a read-only reference to the target texture.
     *
     * After drawing to the render-texture and calling Display, you can retrieve
     * the updated texture using this function, and draw it using a sprite
     * (for example).
     *
     * The internal Texture of a render-texture is always the same instance, so
     * that it is possible to call this function once and keep a reference to
     * the texture even after it is modified.
     *
     * Returns: Const reference to the texture.
     */
    const(Texture) getTexture() const
    {
        return m_texture;
    }

    /**
     * Activate or deactivate the render-texture for rendering.
     *
     * This function makes the render-texture's context current for future
     * OpenGL rendering operations (so you shouldn't care about it if you're not
     * doing direct OpenGL stuff).
     *
     * Only one context can be current in a thread, so if you want to draw
     * OpenGL geometry to another render target (like a $(RENDERWINDOW_LINK))
     * don't forget to activate it again.
     *
     * Params:
     * 		active	= true to activate, false to deactivate
     */
    void setActive(bool active = true)
    {
        sfRenderTexture_setActive(sfPtr, active);
    }

    /**
     * Clear the entire target with a single color.
     *
     * This function is usually called once every frame, to clear the previous
     * contents of the target.
     *
     * Params:
     * 		color	= Fill color to use to clear the render target
     */
    void clear(Color color = Color.Black) {
        sfRenderTexture_clear(sfPtr, cast(sfColor)color);
    }

    /**
     * Update the contents of the target texture.
     *
     * This function updates the target texture with what has been drawn so far.
     * Like for windows, calling this function is mandatory at the end of
     * rendering. Not calling it may leave the texture in an undefined state.
     */
    void display()
    {
        sfRenderTexture_display(sfPtr);
    }

    /**
     * Draw a drawable object to the render target.
     *
     * Params:
     * 		drawable	= Object to draw
     * 		states		= Render states to use for drawing
     */
    override void draw(Drawable drawable, RenderStates states = RenderStates.init)
    {
        drawable.draw(this, states);
    }

    /**
     * Draw primitives defined by an array of vertices.
     *
     * Params:
     * 		vertices	= Array of vertices to draw
     * 		type		= Type of primitives to draw
     * 		states		= Render states to use for drawing
     */
    override void draw(const(Vertex)[] vertices, PrimitiveType type, RenderStates states = RenderStates.init)
    {
        import std.algorithm;

        sfRenderStates sfStates;
        sfStates.blendMode = cast(sfBlendMode)states.blendMode;
        sfStates.transform = getFromTransform(states.transform);
        sfStates.texture = states.texture ? states.texture.sfPtr : null;
        sfStates.shader = states.shader ? states.shader.sfPtr : null;

        sfRenderTexture_drawPrimitives(sfPtr, cast(sfVertex*)vertices.ptr, cast(uint)min(uint.max, vertices.length),cast(sfPrimitiveType)type, &sfStates);
    }

    /**
     * Restore the previously saved OpenGL render states and matrices.
     *
     * See the description of pushGLStates to get a detailed description of
     * these functions.
     */
    void popGLStates()
    {
        sfRenderTexture_popGLStates(sfPtr);
    }

    /**
     * Save the current OpenGL render states and matrices.
     *
     * This function can be used when you mix SFML drawing and direct OpenGL
     * rendering. Combined with PopGLStates, it ensures that:
     * $(UL
     * $(LI DSFML's internal states are not messed up by your OpenGL code)
     * $(LI your OpenGL states are not modified by a call to an SFML function))
     *
     * $(PARA More specifically, it must be used around the code that calls
     * `draw` functions.
     *
     * Note that this function is quite expensive: it saves all the possible
	 * OpenGL states and matrices, even the ones you don't care about.Therefore
	 * it should be used wisely. It is provided for convenience, but the best
	 * results will be achieved if you handle OpenGL states yourself (because
	 * you know which states have really changed, and need to be saved and
	 * restored). Take a look at the `resetGLStates` function if you do so.)
     */
    void pushGLStates()
    {
        sfRenderTexture_pushGLStates(sfPtr);
    }

    /**
     * Reset the internal OpenGL states so that the target is ready for drawing.
     *
     * This function can be used when you mix DSFML drawing and direct OpenGL
     * rendering, if you choose not to use pushGLStates/popGLStates. It makes
     * sure that all OpenGL states needed by DSFML are set, so that subsequent
     * `draw()` calls will work as expected.
     */
    void resetGLStates()
    {
        sfRenderTexture_resetGLStates(sfPtr);
    }
}

unittest
{
    version(DSFML_Unittest_Graphics)
    {
        import std.stdio;
        import nudsfml.graphics.sprite;

        writeln("Unit tests for RenderTexture");

        auto renderTexture = new RenderTexture();

        renderTexture.create(100,100);

        //doesn't need a texture for this unit test
        Sprite testSprite = new Sprite();

        //clear before doing anything
        renderTexture.clear();

        renderTexture.draw(testSprite);

        //prepare the RenderTexture for usage after drawing
        renderTexture.display();

        //grab that texture for usage
        auto texture = renderTexture.getTexture();

        writeln();
    }
}
