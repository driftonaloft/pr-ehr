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

/**
 * $(U RenderWindow) is the main class of the Graphics package. It defines an OS
 * window that can be painted using the other classes of the graphics module.
 *
 * $(U RenderWindow) is derived from $(WINDOW_LINK), thus it inherits all its
 * features : events, window management, OpenGL rendering, etc. See the
 * documentation of $(WINDOW_LINK) for a more complete description of all these
 * features, as well as code examples.
 *
 * On top of that, $(U RenderWindow) adds more features related to 2D drawing
 * with the graphics module (see its base class $(RENDERTARGET_LINK) for more
 * details).
 *
 * Here is a typical rendering and event loop with a $(U RenderWindow):
 * ---
 * // Declare and create a new render-window
 * auto window = new RenderWindow(VideoMode(800, 600), "DSFML window");
 *
 * // Limit the framerate to 60 frames per second (this step is optional)
 * window.setFramerateLimit(60);
 *
 * // The main loop - ends as soon as the window is closed
 * while (window.isOpen())
 * {
 *    // Event processing
 *    Event event;
 *    while (window.pollEvent(event))
 *    {
 *        // Request for closing the window
 *        if (event.type == Event.Type.Closed)
 *            window.close();
 *    }
 *
 *    // Clear the whole window before rendering a new frame
 *    window.clear();
 *
 *    // Draw some graphical entities
 *    window.draw(sprite);
 *    window.draw(circle);
 *    window.draw(text);
 *
 *    // End the current frame and display its contents on screen
 *    window.display();
 * }
 * ---
 *
 * $(PARA Like $(WINDOW_LINK), $(U RenderWindow) is still able to render direct
 * OpenGL stuff. It is even possible to mix together OpenGL calls and regular
 * DSFML drawing commands.)
 * ---
 * // Create the render window
 * auto window = new RenderWindow(VideoMode(800, 600), "DSFML OpenGL");
 *
 * // Create a sprite and a text to display
 * auto sprite = new Sprite();
 * auto text = new Text();
 * ...
 *
 * // Perform OpenGL initializations
 * glMatrixMode(GL_PROJECTION);
 * ...
 *
 * // Start the rendering loop
 * while (window.isOpen())
 * {
 *     // Process events
 *     ...
 *
 *     // Draw a background sprite
 *     window.pushGLStates();
 *     window.draw(sprite);
 *     window.popGLStates();
 *
 *     // Draw a 3D object using OpenGL
 *     glBegin(GL_QUADS);
 *         glVertex3f(...);
 *         ...
 *     glEnd();
 *
 *     // Draw text on top of the 3D object
 *     window.pushGLStates();
 *     window.draw(text);
 *     window.popGLStates();
 *
 *     // Finally, display the rendered frame on screen
 *     window.display();
 * }
 * ---
 *
 * See_Also:
 * $(WINDOW_LINK), $(RENDERTARGET_LINK), $(RENDERTEXTURE_LINK), $(VIEW_LINK)
 */
module nudsfml.graphics.renderwindow;

import bindbc.sfml.graphics;
import bindbc.sfml.window;
import bindbc.sfml.system;

import nudsfml.graphics.color;
import nudsfml.graphics.image;
import nudsfml.graphics.rect;
import nudsfml.graphics.drawable;
import nudsfml.graphics.primitivetype;
import nudsfml.graphics.renderstates;
import nudsfml.graphics.rendertarget;
import nudsfml.graphics.shader;
import nudsfml.graphics.text;
import nudsfml.graphics.texture;
import nudsfml.graphics.transform;
import nudsfml.graphics.view;
import nudsfml.graphics.vertex;

import nudsfml.window.contextsettings;
import nudsfml.window.windowhandle;
import nudsfml.window.event;
import nudsfml.window.window;
import nudsfml.window.videomode;

//import nudsfml.system.err;
import nudsfml.system.vector2;

/**
 * Window that can serve as a target for 2D drawing.
 */
class RenderWindow : Window, RenderTarget
{
    package sfRenderWindow* sfPtr;
    private View m_currentView, m_defaultView;

    /**
     * Default constructor.
     *
     * This constructor doesn't actually create the window, use the other
     * constructors or call `create()` to do so.
     */
    this()
    {
        sfPtr = null; //sfRenderWindow_construct();
        super(0);
    }

    /**
     * Construct a new window.
     *
     * This constructor creates the window with the size and pixel depth defined
     * in mode. An optional style can be passed to customize the look and
     * behavior of the window (borders, title bar, resizable, closable, ...).
     *
     * The fourth parameter is an optional structure specifying advanced OpenGL
     * context settings such as antialiasing, depth-buffer bits, etc. You
     * shouldn't care about these parameters for a regular usage of the graphics
     * module.
     *
     * Params:
     * mode     = Video mode to use (defines the width, height and depth of the
     * 			  rendering area of the window)
     * title    = Title of the window
     * style    = Window style, a bitwise OR combination of Style enumerators
     * settings = Additional settings for the underlying OpenGL context
     *
     * //deorecated: Use the constructor that takes a 'const(dchar)[]' instead.
     */
    //deorecated("Use the constructor that takes a 'const(dchar)[]' instead.")
    this(T)(VideoMode mode, const(T)[] title, Style style = Style.DefaultStyle, ContextSettings settings = ContextSettings.init)
        if (is(T == wchar)||is(T == char))
    {
        this();
        create(mode, title, style, settings);
    }

    /**
     * Construct a new window.
     *
     * This constructor creates the window with the size and pixel depth defined
     * in mode. An optional style can be passed to customize the look and
     * behavior of the window (borders, title bar, resizable, closable, ...).
     *
     * The fourth parameter is an optional structure specifying advanced OpenGL
     * context settings such as antialiasing, depth-buffer bits, etc. You
     * shouldn't care about these parameters for a regular usage of the graphics
     * module.
     *
     * Params:
     * mode     = Video mode to use (defines the width, height and depth of the
     * 			  rendering area of the window)
     * title    = Title of the window
     * style    = Window style, a bitwise OR combination of Style enumerators
     * settings = Additional settings for the underlying OpenGL context
     */
    this(T)(VideoMode mode, const(dchar)[] title, Style style = Style.DefaultStyle, ContextSettings settings = ContextSettings.init)
    {
        this();
        create(mode, title, style, settings);
    }

    /**
     * Construct the window from an existing control.
     *
     * Use this constructor if you want to create an DSFML rendering area into
     * an already existing control.
     *
     * The second parameter is an optional structure specifying advanced OpenGL
     * context settings such as antialiasing, depth-buffer bits, etc. You
     * shouldn't care about these parameters for a regular usage of the graphics
     * module.
     *
     * Params:
     * handle   = Platform-specific handle of the control
     * settings = Additional settings for the underlying OpenGL context
     */
    this(WindowHandle handle, ContextSettings settings = ContextSettings.init)
    {
        this();
        create(handle, settings);
    }

    ~this() {
        if (sfPtr != null)
            sfRenderWindow_destroy(sfPtr);
    }

    @property
    {
        /**
         * Change the position of the window on screen.
         *
         * This property only works for top-level windows (i.e. it will be
         * ignored for windows created from the handle of a child
         * window/control).
         */
        override Vector2i position(Vector2i newPosition)
        {
            sfRenderWindow_setPosition(sfPtr,cast(sfVector2i)newPosition);
            return newPosition;
        }

        /// ditto
        override Vector2i position() const
        {
            Vector2i temp = cast(Vector2i)sfRenderWindow_getPosition(sfPtr);
            return temp;
        }
    }

    @property
    {
        /**
         * The size of the rendering region of the window.
         */
        override Vector2u size(Vector2u newSize)
        {
            sfRenderWindow_setSize(sfPtr, cast(sfVector2u)newSize);
            return newSize;
        }

        /// ditto
        override Vector2u size() const
        {
            Vector2u temp = cast(Vector2u) sfRenderWindow_getSize(sfPtr);
            return temp;
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
            
            sfRenderWindow_setView(sfPtr, viewPtr);
            return newView;
        }

        /// ditto
        override View view() const
        {
            View currentView;

            Vector2f currentCenter, currentSize;
            float currentRotation;
            FloatRect currentViewport;

            const(sfView*) v = sfRenderWindow_getView(sfPtr);

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

         const(sfView*) v = sfRenderWindow_getDefaultView(sfPtr);

        currentView.center = cast(Vector2f)sfView_getCenter(v);
        currentView.size = cast(Vector2f)sfView_getSize(v);
        currentView.rotation = sfView_getRotation(v);
        currentView.viewport = cast(FloatRect)sfView_getViewport(v);

        return currentView;
    }

    /**
     * Get the settings of the OpenGL context of the window.
     *
     * Note that these settings may be different from what was passed to the
     * constructor or the `create()` function, if one or more settings were not
     * supported. In this case, DSFML chose the closest match.
     *
     * Returns: Structure containing the OpenGL context settings
     */
    override ContextSettings getSettings() const
    {
        sfContextSettings settings;
		ContextSettings temp;
		//sfWindow_getSettings(sfPtr,&temp.depthBits, &temp.stencilBits, &temp.antialiasingLevel, &temp.majorVersion, &temp.minorVersion);
		settings =	 sfRenderWindow_getSettings(sfPtr);
		temp = cast(ContextSettings)settings;
		return temp;
    }

    //this is a duplicate with the size property. Need to look into that
    //(Inherited from RenderTarget)
    /**
     * Return the size of the rendering region of the target.
     *
     * Returns: Size in pixels
     */
    Vector2u getSize() const {
        Vector2u temp = cast(Vector2u) sfRenderWindow_getSize(sfPtr);
        return temp;
    }

    /**
     * Get the OS-specific handle of the window.
     *
     * The type of the returned handle is WindowHandle, which is a typedef to
     * the handle type defined by the OS. You shouldn't need to use this
     * function, unless you have very specific stuff to implement that SFML
     * doesn't support, or implement a temporary workaround until a bug is
     * fixed.
     *
     * Returns: System handle of the window
     */
    override WindowHandle getSystemHandle() const
    {
        WindowHandle temp = cast(WindowHandle) sfRenderWindow_getSystemHandle(sfPtr);   
        return temp;
    }

    /**
     * Get the viewport of a view, applied to this render target.
     *
     * A window is active only on the current thread, if you want to make it
     * active on another thread you have to deactivate it on the previous thread
     * first if it was active. Only one window can be active on a thread at a
     * time, thus the window previously active (if any) automatically gets
     * deactivated.
     *
     * Params:
     * 		active	= true to activate, false to deactivate
     *
     * Returns: true if operation was successful, false otherwise
     */
    override bool setActive(bool active)
    {
        int v = active ? 1 : 0;
        return sfRenderWindow_setActive(sfPtr, cast(sfBool)v) > 0;
    }

    /**
     * Limit the framerate to a maximum fixed frequency.
     *
     * If a limit is set, the window will use a small delay after each call to
     * `display()` to ensure that the current frame lasted long enough to match
     * the framerate limit.
     *
     * DSFML will try to match the given limit as much as it can, but since it
     * internally uses sleep, whose precision depends on the underlying OS, the
     * results may be a little unprecise as well (for example, you can get 65
     * FPS when requesting 60).
     *
     * Params:
     * limit = Framerate limit, in frames per seconds (use 0 to disable limit)
     */
    override void setFramerateLimit(uint limit)
    {
        sfRenderWindow_setFramerateLimit(sfPtr, limit);
    }

    /**
     * Change the window's icon.
     *
     * pixels must be an array of width x height pixels in 32-bits RGBA format.
     *
     * The OS default icon is used by default.
     *
     * Params:
     * 		width	= Icon's width, in pixels
     * 		height	= Icon's height, in pixels
     * 		pixels	= Icon pixel array to load from
     */
    override void setIcon(uint width, uint height, const(ubyte[]) pixels)
    {
        sfRenderWindow_setIcon(sfPtr,width, height, pixels.ptr);
    }

    /**
     * Change the joystick threshold.
     *
     * The joystick threshold is the value below which no JoystickMoved event
     * will be generated.
     *
     * The threshold value is 0.1 by default.
     *
     * Params:
     * 		threshold	= New threshold, in the range [0, 100]
     */
    override void setJoystickThreshold(float threshold)
    {
        sfRenderWindow_setJoystickThreshold(sfPtr, threshold);
    }

     /**
     * Change the joystick threshold.
     *
     * The joystick threshold is the value below which no JoystickMoved event
     * will be generated.
     *
     * The threshold value is 0.1 by default.
     *
     * Params:
     * 		threshhold	= New threshold, in the range [0, 100]
	 *
	 * //deorecated: Use set `setJoystickThreshold` instead.
	 */
	//deorecated("Use setJoystickThreshold instead.")
    override void setJoystickThreshhold(float threshhold)
    {
        sfRenderWindow_setJoystickThreshold(sfPtr, threshhold);
    }

    /**
     * Enable or disable automatic key-repeat.
     *
     * If key repeat is enabled, you will receive repeated KeyPressed events
     * while keeping a key pressed. If it is disabled, you will only get a
     * single event when the key is pressed.
     *
     * Key repeat is enabled by default.
     *
     * Params:
     * 		enabled	= true to enable, false to disable
     */
    override void setKeyRepeatEnabled(bool enabled)
    {
        sfRenderWindow_setKeyRepeatEnabled(sfPtr,enabled);
    }

    /**
     * Show or hide the mouse cursor.
     *
     * The mouse cursor is visible by default.
     *
     * Params:
     * 		visible	= true show the mouse cursor, false to hide it
     */
    override void setMouseCursorVisible(bool visible)
    {
        sfRenderWindow_setMouseCursorVisible(sfPtr, visible);
    }

    //Cannot use templates here as template member functions cannot be virtual.

    /**
     * Change the title of the window
     *
     * Params:
     * 		newTitle = New title
     */
    override void setTitle(const(char)[] newTitle)
    {
        import std.string;
        sfRenderWindow_setTitle(sfPtr, newTitle.toStringz);
    }
    /**
     * Change the title of the window
     *
     * Params:
     * 		newTitle = New title
     */
    override void setTitle(const(wchar)[] newTitle)
    {
        import std.utf;
		auto convertedTitle = newTitle.toUTFz!(dchar*);
        sfRenderWindow_setUnicodeTitle(sfPtr, cast(uint*)convertedTitle);
    }
    /**
     * Change the title of the window
     *
     * Params:
     * 		newTitle = New title
     */
    override void setTitle(const(dchar)[] newTitle)
    {
        //import nudsfml.system.string;
        import std.utf;
        auto convertedTitle = newTitle.toUTFz!(dchar*);
        sfRenderWindow_setUnicodeTitle(sfPtr,cast(uint*) newTitle);
    }

    /**
     * Enable or disable vertical synchronization.
     *
     * Activating vertical synchronization will limit the number of frames
     * displayed to the refresh rate of the monitor. This can avoid some visual
     * artifacts, and limit the framerate to a good value (but not constant
     * across different computers).
     *
     * Vertical synchronization is disabled by default.
     *
     * Params:
     * 		enabled	= true to enable v-sync, false to deactivate it
     */
    override void setVerticalSyncEnabled(bool enabled)
    {
        sfRenderWindow_setVerticalSyncEnabled(sfPtr, enabled);
    }

    /**
     * Show or hide the window.
     *
     * The window is shown by default.
     *
     * Params:
     * 		visible	= true to show the window, false to hide it
     */
    override void setVisible(bool visible)
    {
        sfRenderWindow_setVisible(sfPtr,visible);
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
    void clear(Color color = Color.Black)
    {
        sfRenderWindow_clear(sfPtr,cast(sfColor)color);
    }

    /**
     * Close the window and destroy all the attached resources.
     *
     * After calling this function, the Window instance remains valid and you
     * can call `create()` to recreate the window. All other functions such as
     * `pollEvent()` or `display()` will still work (i.e. you don't have to test
     * `isOpen()` every time), and will have no effect on closed windows.
     */
    override void close()
    {
        sfRenderWindow_close(sfPtr);
    }

    //Cannot use templates here as template member functions cannot be virtual.

    /**
    * Create (or recreate) the window.
    *
    * If the window was already created, it closes it first. If style contains
    * Window.Style.Fullscreen, then mode must be a valid video mode.
    *
    * The fourth parameter is an optional structure specifying advanced OpenGL
    * context settings such as antialiasing, depth-buffer bits, etc.
    *
    * Params:
    * mode     = Video mode to use (defines the width, height and depth of the
    * rendering area of the window)
    * title    = Title of the window
    * style    = Window style, a bitwise OR combination of Style enumerators
    * settings = Additional settings for the underlying OpenGL context
    *
	 * //deorecated: Use the version of create that takes a 'const(dchar)[]'.
    */
    ////deorecated("Use the version of create that takes a 'const(dchar)[]'.")
    override void create(VideoMode mode, const(char)[] title, Style style = Style.DefaultStyle, ContextSettings settings = ContextSettings.init) {
        import std.string;

        if(sfPtr!=null) {
            sfRenderWindow_destroy(sfPtr);
        }
        sfPtr = sfRenderWindow_create(cast(sfVideoMode)mode, cast(const(char*))title.toStringz, cast(sfUint32)style, cast(sfContextSettings*)&settings);
		
        //sfRenderWindow_createFromSettings(sfPtr, mode.width, mode.height, mode.bitsPerPixel, convertedTitle.ptr, convertedTitle.length, style, settings.depthBits, settings.stencilBits, settings.antialiasingLevel, settings.majorVersion, settings.minorVersion);

    }

    /// ditto
    override void create(VideoMode mode, const(wchar)[] title, Style style = Style.DefaultStyle, ContextSettings settings = ContextSettings.init)
    {
        import std.utf;
        if(sfPtr!=null) {
            sfRenderWindow_destroy(sfPtr);
        }
        sfPtr = sfRenderWindow_createUnicode(cast(sfVideoMode)mode, cast(const(uint*))title.toUTFz!(dchar*), cast(sfUint32)style, cast(sfContextSettings*)&settings);
    }

    /**
     * Create (or recreate) the window.
     *
     * If the window was already created, it closes it first. If style contains
     * Window.Style.Fullscreen, then mode must be a valid video mode.
     *
     * The fourth parameter is an optional structure specifying advanced OpenGL
     * context settings such as antialiasing, depth-buffer bits, etc.
     *
     * Params:
     * mode     = Video mode to use (defines the width, height and depth of the
     * rendering area of the window)
     * title    = Title of the window
     * style    = Window style, a bitwise OR combination of Style enumerators
     * settings = Additional settings for the underlying OpenGL context
     */
    override void create(VideoMode mode, const(dchar)[] title, Style style = Style.DefaultStyle, ContextSettings settings = ContextSettings.init)
    {
        import std.utf;
        if(sfPtr!=null) {
            sfRenderWindow_destroy(sfPtr);
        }
        sfPtr = sfRenderWindow_createUnicode(cast(sfVideoMode)mode, cast(const(uint*))title.toUTFz!(dchar*), cast(sfUint32)style, cast(sfContextSettings*)&settings);
    }

    /**
    * Create (or recreate) the window from an existing control.
    *
    * Use this function if you want to create an OpenGL rendering area into an
    * already existing control. If the window was already created, it closes it
    * first.
    *
    * The second parameter is an optional structure specifying advanced OpenGL
    * context settings such as antialiasing, depth-buffer bits, etc.
    *
    * Params:
    * handle   = Platform-specific handle of the control
    * settings = Additional settings for the underlying OpenGL context
    */
    override void create(WindowHandle handle, ContextSettings settings = ContextSettings.init)
    {
        if(sfPtr!=null) {
            sfRenderWindow_destroy(sfPtr);
        }
        //verify this is correct
        sfPtr = sfRenderWindow_createFromHandle(cast(sfWindowHandle)&handle, cast(sfContextSettings*)&settings);
    }

    /**
     * Copy the current contents of the window to an image
     *
     * //deorecated:
     * Use a $(TEXTURE_LINK Texture) and its `Texture.update()` function and
     * copy its contents into an $(IMAGE_LINK Image) instead.
     *
     * This is a slow operation, whose main purpose is to make screenshots of
     * the application. If you want to update an image with the contents of the
     * window and then use it for drawing, you should rather use a
     * $(TEXTURE_LINK Texture) and its `update()` function. You can also draw
     * things directly to a texture with the $(RENDERTEXTURE_LINK RenderTexture)
     * class.
     *
     * Returns: An Image containing the captured contents.
     */
    //deorecated("Use a Texture, its update function, and copy its contents into an Image instead.")
    Image capture()
    {
        return new Image(sfRenderWindow_capture(sfPtr));
    }

    /**
     * Display on screen what has been rendered to the window so far.
     *
     * This function is typically called after all OpenGL rendering has been
     * done for the current frame, in order to show it on screen.
     */
    override void display()
    {
        sfRenderWindow_display(sfPtr);
    }

    /**
     * Draw a drawable object to the render target.
     *
     * Params:
     * 		drawable	= Object to draw
     * 		states		= Render states to use for drawing
     */
    void draw(Drawable drawable, RenderStates states = RenderStates.init)
    {
        drawable.draw(this,states);
    }

    /**
     * Draw primitives defined by an array of vertices.
     *
     * Params:
     * 		vertices	= Array of vertices to draw
     * 		type		= Type of primitives to draw
     * 		states		= Render states to use for drawing
     */
    void draw(const(Vertex)[] vertices, PrimitiveType type, RenderStates states = RenderStates.init)
    {
        import std.algorithm;

        sfRenderStates sfStates;
        sfStates.blendMode = cast(sfBlendMode)states.blendMode;
        sfStates.transform = getFromTransform(states.transform);
        sfStates.texture = states.texture !is null ? states.texture.sfPtr : null;
        sfStates.shader = states.shader !is null ? states.shader.sfPtr : null;

        sfRenderWindow_drawPrimitives(sfPtr, cast(sfVertex*)vertices.ptr, cast(uint)min(uint.max, vertices.length),cast(sfPrimitiveType)type, &sfStates);
    }

    /**
     * Tell whether or not the window is open.
     *
     * This function returns whether or not the window exists. Note that a
     * hidden window (`setVisible(false)`) is open (therefore this function would
     * return true).
     *
     * Returns: true if the window is open, false if it has been closed
     */
    override bool isOpen() const
    {
        return (sfRenderWindow_isOpen(sfPtr)) > 0;
    }

    /**
     * Restore the previously saved OpenGL render states and matrices.
     *
     * See the description of pushGLStates to get a detailed description of
     * these functions.
     */
    void popGLStates()
    {
        sfRenderWindow_popGLStates(sfPtr);
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
        sfRenderWindow_pushGLStates(sfPtr);
    }

    /**
     * Reset the internal OpenGL states so that the target is ready for drawing.
     *
     * This function can be used when you mix SFML drawing and direct OpenGL
     * rendering, if you choose not to use `pushGLStates`/`popGLStates`. It
     * makes sure that all OpenGL states needed by DSFML are set, so that
     * subsequent `draw()` calls will work as expected.
     */
    void resetGLStates()
    {
        sfRenderWindow_resetGLStates(sfPtr);
    }

    /**
     * Pop the event on top of the event queue, if any, and return it.
     *
     * This function is not blocking: if there's no pending event then it will
     * return false and leave event unmodified. Note that more than one event
     * may be present in the event queue, thus you should always call this
     * function in a loop to make sure that you process every pending event.
     *
     * Params:
     * 		event	= Event to be returned
     *
     * Returns: true if an event was returned, or false if the event queue was
     * empty.
     */
    override bool pollEvent(ref Event event)
    {
        sfEvent sfevent;
		bool retval = (sfRenderWindow_pollEvent(sfPtr, &sfevent)) > 0;
		event = fromSfEvent(sfevent);
		return retval;
    }

    /**
     * Wait for an event and return it.
     *
     * This function is blocking: if there's no pending event then it will wait
     * until an event is received. After this function returns (and no error
     * occured), the event object is always valid and filled properly. This
     * function is typically used when you have a thread that is dedicated to
     * events handling: you want to make this thread sleep as long as no new
     * event is received.
     *
     * Params:
     * 		event	= Event to be returned
     *
     * Returns: false if any error occurred.
     */
    override bool waitEvent(ref Event event)
    {
        sfEvent sfevent;
		bool retval = (sfRenderWindow_waitEvent(sfPtr, &sfevent)) > 0;
		event = fromSfEvent(sfevent);
		return retval;
    }

    //TODO: Consider adding these methods.
    //void onCreate
    //void onResize

    override protected Vector2i getMousePosition()const
    {
        Vector2i temp = cast(Vector2i)sfMouse_getPositionRenderWindow(sfPtr);
        return temp;
    }

    //TODO: Fix these names or something.
    override protected void setMousePosition(Vector2i pos) const
    {
        sfVector2i position = cast(sfVector2i)pos;
        sfMouse_setPositionRenderWindow(position, sfPtr);
    }

    //let's Texture have a way to get the sfPtr of a regular window.
    package static void* windowPointer(const(Window) window)
    {
        return getWindowPointer(window);
    }
}

unittest
{
    version(DSFML_Unittest_Graphics)
    {
        import std.stdio;
        import nudsfml.graphics.image;
        import nudsfml.system.clock;
        import nudsfml.graphics.sprite;

        writeln("Unit test for RenderWindow");

        //constructor
        auto window = new RenderWindow(VideoMode(800,600),"Test Window");

        //perform each window call
        Vector2u windowSize = window.size;

        windowSize.x = 1000;
        windowSize.y = 1000;

        window.size = windowSize;

        Vector2i windowPosition = window.position;

        windowPosition.x = 100;
        windowPosition.y = 100;

        window.position = windowPosition;

        window.setTitle("thing");//uses the first set title

        window.setTitle("素晴らしい ！"d);//forces the dstring override and uses utf-32

        window.setActive(true);

        window.setJoystickThreshhold(1);

        window.setVisible(true);

        window.setFramerateLimit(60);

        window.setMouseCursorVisible(true);

        window.setVerticalSyncEnabled(true);

        auto settings = window.getSettings();

        auto image = new Image();
        image.loadFromFile("data/lain.png");

        window.setIcon(image.getSize().x,image.getSize().x,image.getPixelArray()); //validate

        auto texture = new Texture();

        texture.loadFromImage(image);

        auto sprite = new Sprite(texture);

        auto clock = new Clock();

        while(window.isOpen())
        {
            Event event;
            if(window.pollEvent(event))
            {
                //no events
            }

            if(clock.getElapsedTime().asSeconds() > 1)
            {
                window.close();
            }

            window.clear();

            window.draw(sprite);

            window.display();
        }

        writeln();
    }
}

