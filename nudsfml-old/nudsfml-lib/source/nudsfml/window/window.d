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

module nudsfml.window.window;

import bindbc.sfml.window;
import bindbc.sfml.system;


import nudsfml.window.event;
import nudsfml.window.keyboard;
import nudsfml.window.mouse;
import nudsfml.window.videomode;
import nudsfml.window.contextsettings;
import nudsfml.window.windowhandle;
import nudsfml.system.vector2;
//import nudsfml.system.err;

/**
 * Window that serves as a target for OpenGL rendering.
 */
class Window {
	/// Choices for window style
	enum Style {
		None = 0,
		Titlebar = 1 << 0,
		Resize = 1 << 1,
		Close = 1 << 2,
		Fullscreen = 1 << 3,
		DefaultStyle = Titlebar | Resize | Close
	}

	package sfWindow* sfPtr;

	//let's RenderWindow inherit from Window without trying to delete the null
	//pointer
	private bool m_needsToDelete = true;

	/// Default constructor.
	this() {
		sfPtr = null; //sfWindow_construct();
	}

	//Construct a window without calling sfWindow_construct
	//This allows a RenderWindow to be created without creating a Window first
	protected this(int){
		m_needsToDelete = false;
	}

	//allows RenderWindow to delete the Window pointer when it is created
	//so that there are not both instances.
	protected void deleteWindowPtr() {
		sfWindow_destroy(sfPtr);
		m_needsToDelete = false;
	}

	/**
	 * Construct a new window.
	 *
	 * This constructor creates the window with the size and pixel depth defined
	 * in mode. An optional style can be passed to customize the look and
	 * behaviour of the window (borders, title bar, resizable, closable, ...).
	 * If style contains Style::Fullscreen, then mode must be a valid video
	 * mode.
	 *
	 * The fourth parameter is an optional structure specifying advanced OpenGL
	 * context settings such as antialiasing, depth-buffer bits, etc.
	 *
	 * Params:
	 *    	mode = Video mode to use (defines the width, height and depth of the
	 *			   rendering area of the window)
	 *   	title = Title of the window
	 *    	style = Window style
	 *     	settings = Additional settings for the underlying OpenGL context
	 */
	this(T)(VideoMode mode, immutable(T)[] title, Style style = Style.DefaultStyle, ContextSettings settings = ContextSettings.init)
		if (is(T == dchar)||is(T == wchar)||is(T == char))
	{
		this();
		create(mode, title, style, settings);
	}

	/**
	 * Construct the window from an existing control.
	 *
	 * Use this constructor if you want to create an OpenGL rendering area into
	 * an already existing control.
	 *
	 * The second parameter is an optional structure specifying advanced OpenGL
	 * context settings such as antialiasing, depth-buffer bits, etc.
	 *
	 * Params:
     * 		handle = Platform-specific handle of the control
     * 		settings = Additional settings for the underlying OpenGL context
	 */
	this(WindowHandle handle, ContextSettings settings = ContextSettings.init){
		this();
		create(handle, settings);
	}

	/// Destructor.
	~this() {
		import nudsfml.system.config;
		//this takes care of not freeing a null pointer due to inheritance
		//(RenderWindow does not create the inherited sfWindow)
		if(m_needsToDelete) {
			mixin(destructorOutput);
			if(sfPtr !is null)
				sfWindow_destroy(sfPtr);
		}
	}

	@property {
		/**
	 	 * Get's or set's the window's position.
	 	 *
	 	 * This function only works for top-level windows (i.e. it will be ignored
	 	 * for windows created from the handle of a child window/control).
	 	 */
		Vector2i position(Vector2i newPosition) {
			sfVector2i pos = cast(sfVector2i)(newPosition);
			sfWindow_setPosition(sfPtr,pos);
			return newPosition;
		}

		/// ditto
		Vector2i position() const{
			Vector2i temp = cast(Vector2i) sfWindow_getPosition(sfPtr);
			return temp;
		}
	}

	@property {
		/// Get's or set's the window's size.
		Vector2u size(Vector2u newSize) {
			sfVector2u temp = cast(sfVector2u)(newSize);
			sfWindow_setSize(sfPtr, temp);
			return newSize;
		}

		// ditto
		Vector2u size() const {
			Vector2u temp = cast(Vector2u) sfWindow_getSize(sfPtr);
			return temp;
		}
	}

	/**
	 * Activate or deactivate the window as the current target for OpenGL
	 * rendering.
	 *
	 * A window is active only on the current thread, if you want to make it
	 * active on another thread you have to deactivate it on the previous thread
	 * first if it was active. Only one window can be active on a thread at a
	 * time, thus the window previously active (if any) automatically gets
	 * deactivated.
	 *
	 * Params:
     * 		active = true to activate, false to deactivate
     *
	 * Returns: true if operation was successful, false otherwise.
	 */
	bool setActive(bool active) {
		int sfbool = active ? 1 : 0;
		return sfWindow_setActive(sfPtr, cast(sfBool) sfbool) > 0;
	}

	///Request the current window to be made the active foreground window.
	void requestFocus() {
		sfWindow_requestFocus(sfPtr);
	}

	/**
	 * Check whether the window has the input focus
	 *
	 * Returns: true if the window has focus, false otherwise
	 */
	bool hasFocus() const {
		return sfWindow_hasFocus(sfPtr) > 0;
	}

	/**
	 * Limit the framerate to a maximum fixed frequency.
	 *
	 * If a limit is set, the window will use a small delay after each call to
	 * display() to ensure that the current frame lasted long enough to match
	 * the framerate limit. SFML will try to match the given limit as much as it
	 * can, but since it internally usesnudsfml.system.sleep, whose precision
	 * depends on the underlying OS, the results may be a little unprecise as
	 * well (for example, you can get 65 FPS when requesting 60).
	 *
	 * Params:
     * 		limit = Framerate limit, in frames per seconds (use 0 to disable limit).
	 */
	void setFramerateLimit(uint limit) {
		sfWindow_setFramerateLimit(sfPtr, limit);
	}

	/**
	 * Change the window's icon.
	 *
	 * pixels must be an array of width x height pixels in 32-bits RGBA format.
	 *
	 * The OS default icon is used by default.
	 *
	 * Params:
	 *     width = Icon's width, in pixels
	 *     height = Icon's height, in pixels
	 *     pixels = Pointer to the array of pixels in memory
	 */
	void setIcon(uint width, uint height, const(ubyte[]) pixels) {
		sfWindow_setIcon(sfPtr,width, height, pixels.ptr);
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
	 *     threshold = New threshold, in the range [0, 100].
	 */
	void setJoystickThreshold(float threshold) {
		sfWindow_setJoystickThreshold(sfPtr, threshold);
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
	 *     threshhold = New threshold, in the range [0, 100].
	 *
	 * //deorecated: Use set `setJoystickThreshold` instead.
	 */
	//deorecated("Use setJoystickThreshold instead.")
	void setJoystickThreshhold(float threshhold) {
		sfWindow_setJoystickThreshold(sfPtr, threshhold);
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
	 *     enabled = true to enable, false to disable.
	 */
	void setKeyRepeatEnabled(bool enabled) {
		sfWindow_setKeyRepeatEnabled(sfPtr, enabled);
	}

	/**
	 * Show or hide the mouse cursor.
	 *
	 * The mouse cursor is visible by default.
	 *
	 * Params:
     * 		visible = true to show the mouse cursor, false to hide it.
	 */
	void setMouseCursorVisible(bool visible) {
		 sfWindow_setMouseCursorVisible(sfPtr, visible);
	}

	//Cannot use templates here as template member functions cannot be virtual.

	/**
	 * Change the title of the window.
	 *
	 * Params:
     * 		newTitle = New title
	 *
	 * //deorecated: Use the version of setTitle that takes a 'const(dchar)[]'.
	 */
	//deorecated("Use the version of setTitle that takes a 'const(dchar)[]'.")
	void setTitle(const(char)[] newTitle) {
		import std.string;
		sfWindow_setTitle(sfPtr, newTitle.toStringz);
	}

	/// ditto
	//deorecated("Use the version of setTitle that takes a 'const(dchar)[]'.")
	void setTitle(const(wchar)[] newTitle) {
		import std.utf;
		sfWindow_setUnicodeTitle(sfPtr, cast(uint*) newTitle.toUTFz!(dchar*));
	}

	/**
	 * Change the title of the window.
	 *
	 * Params:
     * 		newTitle = New title
	 */
	void setTitle(const(dchar)[] newTitle) {
		import std.utf;
		sfWindow_setUnicodeTitle(sfPtr, cast(uint*) newTitle.toUTFz!(dchar*));
	}

	/**
	 * Show or hide the window.
	 *
	 * The window is shown by default.
	 *
	 * Params:
	 *     visible = true to show the window, false to hide it
	 */
	void setVisible(bool visible)
	{
		sfWindow_setVisible(sfPtr, visible);
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
	 *     enabled = true to enable v-sync, false to deactivate it
	 */
	void setVerticalSyncEnabled(bool enabled)
	{
		sfWindow_setVerticalSyncEnabled(sfPtr, enabled);
	}

	/**
	 * Get the settings of the OpenGL context of the window.
	 *
	 * Note that these settings may be different from what was passed to the
	 * constructor or the create() function, if one or more settings were not
	 * supported. In this case, SFML chose the closest match.
	 *
	 * Returns: Structure containing the OpenGL context settings.
	 */
	ContextSettings getSettings() const
	{
		sfContextSettings settings;
		ContextSettings temp;
		//sfWindow_getSettings(sfPtr,&temp.depthBits, &temp.stencilBits, &temp.antialiasingLevel, &temp.majorVersion, &temp.minorVersion);
		settings =	sfWindow_getSettings(sfPtr);
		temp = cast(ContextSettings)settings;
		return temp;
	}

	/**
	 * Get the OS-specific handle of the window.
	 *
	 * The type of the returned handle is sf::WindowHandle, which is a typedef
	 * to the handle type defined by the OS. You shouldn't need to use this
	 * function, unless you have very specific stuff to implement that SFML
	 * doesn't support, or implement a temporary workaround until a bug is
	 * fixed.
	 *
	 * Returns: System handle of the window.
	 */
	WindowHandle getSystemHandle() const
	{
		return cast(WindowHandle)sfWindow_getSystemHandle(sfPtr);
	}

	//TODO: Consider adding these methods.
	//void onCreate
	//void onResize

	/**
	 * Close the window and destroy all the attached resources.
	 *
	 * After calling this function, the Window instance remains valid and you
	 * can call create() to recreate the window. All other functions such as
	 * pollEvent() or display() will still work (i.e. you don't have to test
	 * isOpen() every time), and will have no effect on closed windows.
	 */
	void close()
	{
		sfWindow_close(sfPtr);
	}

	//Cannot use templates here as template member functions cannot be virtual.

	/**
	 * Create (or recreate) the window.
	 *
	 * If the window was already created, it closes it first. If style contains
	 * Style.Fullscreen, then mode must be a valid video mode.
	 *
	 * The fourth parameter is an optional structure specifying advanced OpenGL
	 * context settings such as antialiasing, depth-buffer bits, etc.
	 *
	 * //deorecated: Use the version of create that takes a 'const(dchar)[]'.
	 */
	//deorecated("Use the version of create that takes a 'const(dchar)[]'.")
	void create(VideoMode mode, const(char)[] title, Style style = Style.DefaultStyle, ContextSettings settings = ContextSettings.init)
	{
		import std.utf: toUTF32;
		import std.string;
		//auto convertedTitle = toUTF32(title);
		//sfWindow_createFromSettings(sfPtr, mode.width, mode.height, mode.bitsPerPixel, convertedTitle.ptr, convertedTitle.length, style, settings.depthBits, settings.stencilBits, settings.antialiasingLevel, settings.majorVersion, settings.minorVersion);
		sfContextSettings sfSettings = cast(sfContextSettings)settings;
		sfPtr = sfWindow_create(cast(sfVideoMode)mode, title.toStringz, cast(sfUint32)style, cast(sfContextSettings*)&sfSettings);
	}

	/// ditto
	//deorecated("Use the version of create that takes a 'const(dchar)[]'.")
	void create(VideoMode mode, const(wchar)[] title, Style style = Style.DefaultStyle, ContextSettings settings = ContextSettings.init)
	{
		import std.utf: toUTF32;
		auto convertedTitle = toUTF32(title);
		//sfWindow_createFromSettings(sfPtr, mode.width, mode.height, mode.bitsPerPixel, convertedTitle.ptr, convertedTitle.length, style, settings.depthBits, settings.stencilBits, settings.antialiasingLevel, settings.majorVersion, settings.minorVersion);
	}

	/**
	 * Create (or recreate) the window.
	 *
	 * If the window was already created, it closes it first. If style contains
	 * Style.Fullscreen, then mode must be a valid video mode.
	 *
	 * The fourth parameter is an optional structure specifying advanced OpenGL
	 * context settings such as antialiasing, depth-buffer bits, etc.
	 */
	void create(VideoMode mode, const(dchar)[] title, Style style = Style.DefaultStyle, ContextSettings settings = ContextSettings.init)
	{
		//sfWindow_createFromSettings(sfPtr, mode.width, mode.height, mode.bitsPerPixel, title.ptr, title.length, style, settings.depthBits, settings.stencilBits, settings.antialiasingLevel, settings.majorVersion, settings.minorVersion);
	}

	/// ditto
	void create(WindowHandle handle, ContextSettings settings = ContextSettings.init)
	{
		sfWindowHandle sfHandle = cast(sfWindowHandle)handle;
		sfContextSettings sfSettings = cast(sfContextSettings)settings;
		sfPtr = sfWindow_createFromHandle(sfHandle, &sfSettings);
	}

	/**
	 * Display on screen what has been rendered to the window so far.
	 *
	 * This function is typically called after all OpenGL rendering has been
	 * done for the current frame, in order to show it on screen.
	 */
	void display()
	{
		sfWindow_display(sfPtr);
	}

	/**
	 * Tell whether or not the window is open.
	 *
	 * This function returns whether or not the window exists. Note that a
	 * hidden window (setVisible(false)) is open (therefore this function would
	 * return true).
	 *
	 * Returns: true if the window is open, false if it has been closed.
	 */
	bool isOpen() const
	{
		return (sfWindow_isOpen(sfPtr)) > 0;
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
     * 		event = Event to be returned.
     *
	 * Returns: true if an event was returned, or false if the event queue was
	 * 			empty.
	 */
	bool pollEvent(ref Event event)
	{
		sfEvent sfevent;
		bool retval = (sfWindow_pollEvent(sfPtr, &sfevent)) > 0;
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
     * 		event = Event to be returned
     *
	 * Returns: False if any error occured.
	 */
	bool waitEvent(ref Event event)
	{
		sfEvent sfevent;
		bool retval = (sfWindow_waitEvent(sfPtr, &sfevent)) > 0;
		event = fromSfEvent(sfevent);
		return retval;
	}

	//TODO: Clean this up. The names are so bad. :(

	//Gives a way for RenderWindow to send its mouse position
	protected Vector2i getMousePosition() const
	{
		Vector2i temp = cast(Vector2i)sfMouse_getPosition(sfPtr);
		return temp;
	}

	//A method for the Mouse class to use in order to get the mouse position
	//relative to the window
	package Vector2i mouse_getPosition() const
	{
		return getMousePosition();
	}

	//Gives a way for Render Window to set its mouse position
	protected void setMousePosition(Vector2i pos) const
	{
		sfVector2i sfPos = cast(sfVector2i)pos;
		sfMouse_setPosition(sfPos, sfPtr);
	}

	//A method for the mouse class to use
	package void mouse_SetPosition(Vector2i pos) const
	{
		setMousePosition(pos);
	}

	//Circumvents the package restriction allowing Texture to get the internal
	//pointer of a regular window (for texture.update)
	protected static void* getWindowPointer(const(Window) window)
	{
		return cast(void*)window.sfPtr;
	}
}

Event fromSfEvent(const(sfEvent) sfEvent) {
	Event event;
	event.type = cast(Event.Type)sfEvent.type;
	switch(event.type){
		/// The window requested to be closed (no data)
        case Event.Type.Closed:
			break;
        /// The window was resized (data in event.size)
        case Event.Type.Resized:
			event.size.width = sfEvent.size.width;
			event.size.height = sfEvent.size.height;
			break;
        /// The window lost the focus (no data)
        case Event.Type.LostFocus:
			break;
        /// The window gained the focus (no data)
        case Event.Type.GainedFocus:
			break;
        /// A character was entered (data in event.text)
        case Event.Type.TextEntered:
			event.text.unicode = sfEvent.text.unicode;
			break;
        /// A key was pressed (data in event.key)
        case Event.Type.KeyPressed:
			event.key.code = cast(Keyboard.Key)sfEvent.key.code;
			event.key.alt = sfEvent.key.alt > 0;
			event.key.control = sfEvent.key.control > 0;
			event.key.shift = sfEvent.key.shift > 0;
			event.key.system = sfEvent.key.system > 0;
			break;
        /// A key was released (data in event.key)
        case Event.Type.KeyReleased:
			event.key.code = cast(Keyboard.Key)sfEvent.key.code;
			event.key.alt = sfEvent.key.alt > 0;
			event.key.control = sfEvent.key.control > 0;
			event.key.shift = sfEvent.key.shift > 0;
			event.key.system = sfEvent.key.system > 0;
			break;
        /// The mouse wheel was scrolled (data in event.mouseWheel)
        case Event.Type.MouseWheelMoved:
			event.mouseWheel.delta = sfEvent.mouseWheel.delta;
			event.mouseWheel.x = sfEvent.mouseWheel.x;
			event.mouseWheel.y = sfEvent.mouseWheel.y;
			break;
		/// The mouse cursor moved (data in event.mouseMove)
		case Event.Type.MouseMoved:
			event.mouseMove.x = sfEvent.mouseMove.x;
			event.mouseMove.y = sfEvent.mouseMove.y;
			break;
        /// The mouse wheel was scrolled (data in event.mouseWheelScroll)
        case Event.Type.MouseWheelScrolled:
			event.mouseWheel.delta = sfEvent.mouseWheel.delta;
			event.mouseWheel.x = sfEvent.mouseWheel.x;
			event.mouseWheel.y = sfEvent.mouseWheel.y;
			break;
        /// A mouse button was pressed (data in event.mouseButton)
        case Event.Type.MouseButtonPressed:
			event.mouseButton.button = cast(Mouse.Button)sfEvent.mouseButton.button;
			event.mouseButton.x = sfEvent.mouseButton.x;
			event.mouseButton.y = sfEvent.mouseButton.y;
			break;
        /// A mouse button was released (data in event.mouseButton)
        case Event.Type.MouseButtonReleased:
			event.mouseButton.button = cast(Mouse.Button)sfEvent.mouseButton.button;
			event.mouseButton.x = sfEvent.mouseButton.x;
			event.mouseButton.y = sfEvent.mouseButton.y;
			break;
        /// The mouse cursor entered the area of the window (no data)
        case Event.Type.MouseEntered:
			break;
        /// The mouse cursor left the area of the window (no data)
        case Event.Type.MouseLeft:
			break;
        /// A joystick button was pressed (data in event.joystickButton)
        case Event.Type.JoystickButtonPressed:
			event.joystickButton.button = sfEvent.joystickButton.button;
			event.joystickButton.joystickId = sfEvent.joystickButton.joystickId;
			break;
        /// A joystick button was released (data in event.joystickButton)
        case Event.Type.JoystickButtonReleased:
			event.joystickButton.button = sfEvent.joystickButton.button;
			event.joystickButton.joystickId = sfEvent.joystickButton.joystickId;
			break;
        /// The joystick moved along an axis (data in event.joystickMove)
        case Event.Type.JoystickMoved:
			event.joystickMove.axis = sfEvent.joystickMove.axis;
			event.joystickMove.joystickId = sfEvent.joystickMove.joystickId;
			event.joystickMove.position = sfEvent.joystickMove.position;
			break;
        /// A joystick was connected (data in event.joystickConnect)
        case Event.Type.JoystickConnected:
			event.joystickConnect.joystickId = sfEvent.joystickConnect.joystickId;
			break;
        /// A joystick was disconnected (data in event.joystickConnect)
        case Event.Type.JoystickDisconnected:
			event.joystickConnect.joystickId = sfEvent.joystickConnect.joystickId;
			break;
        /// A touch event began (data in event.touch)
        /*case Event.Type.TouchBegan:
			event.touch.finger = sfEvent.touch.finger;
			event.touch.x = sfEvent.touch.x;
			event.touch.y = sfEvent.touch.y;

			break;
        /// A touch moved (data in event.touch)
        case Event.Type.TouchMoved:
			event.touch.finger = sfEvent.touch.finger;
			event.touch.x = sfEvent.touch.x;
			event.touch.y = sfEvent.touch.y;

			break;
        /// A touch ended (data in event.touch)
        case Event.Type.TouchEnded:
			event.touch.finger = sfEvent.touch.finger;
			event.touch.x = sfEvent.touch.x;
			event.touch.y = sfEvent.touch.y;
			break;
        /// A sensor value changed (data in event.sensor)
        case Event.Type.SensorChanged:
			event.sensor.type = sfEvent.sensor.type;
			event.sensor.x = sfEvent.sensor.x;
			event.sensor.y = sfEvent.sensor.y;
			event.sensor.z = sfEvent.sensor.z;
			break;
		*/
		default:
			break;
	}



	return event;
}