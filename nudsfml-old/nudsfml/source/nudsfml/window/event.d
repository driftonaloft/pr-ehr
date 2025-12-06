module nudsfml.window.event;

import bindbc.sfml.window;

import nudsfml.window.keyboard;
import nudsfml.window.mouse;
import nudsfml.window.sensor;

/**
 * Defines a system event and its parameters.
 */
struct Event
{
    /**
    * Joystick buttons events parameters
    * (JoystickButtonPressed, JoystickButtonReleased)
    */
    struct JoystickButtonEvent
    {
        /// Index of the joystick (in range [0 .. Joystick::Count - 1])
        uint joystickId;

        /**
         * Index of the button that has been pressed
         * (in range [0 .. Joystick::ButtonCount - 1])
         */
        uint button;
    }

    /**
    * Joystick connection events parameters
    * (JoystickConnected, JoystickDisconnected)
    */
    struct JoystickConnectEvent
    {
        /// Index of the joystick (in range [0 .. Joystick::Count - 1])
        uint joystickId;
    }

    /**
     * Joystick connection events parameters
     * (JoystickConnected, JoystickDisconnected)
     */
    struct JoystickMoveEvent
    {
        /// Index of the joystick (in range [0 .. Joystick::Count - 1])
        uint joystickId;

        /// Axis on which the joystick moved
        int axis;

        /// New position on the axis (in range [-100 .. 100])
        float position;
    }

    /**
     * Keyboard event parameters (KeyPressed, KeyReleased)
     */
    struct KeyEvent
    {
        /// Code of the key that has been pressed.
        Keyboard.Key code;

        /// Is the Alt key pressed?
        bool alt;

        /// Is the Control key pressed?
        bool control;

        /// Is the Shift key pressed?
        bool shift;

        /// Is the System key pressed?
        bool system;
    }

    /**
     * Mouse buttons events parameters (MouseButtonPressed, MouseButtonReleased)
     */
    struct MouseButtonEvent
    {
        /// Code of the button that has been pressed.
        Mouse.Button button;

        /**
         * X position of the mouse pointer, relative to the left of the owner
         * window.
         */
        int x;

        /**
         * Y position of the mouse pointer, relative to the top of the owner
         * window.
         */
        int y;
    }

    /**
     * Mouse move event parameters (MouseMoved)
     */
    struct MouseMoveEvent
    {
        /**
         * X position of the mouse pointer, relative to the left of the owner
         * window.
         */
        int x;

        /**
         * Y position of the mouse pointer, relative to the top of the owner
         * window.
         */
        int y;
    }

    /**
     * Mouse wheel events parameters (MouseWheelMoved)
     */
    //deprecated("This event is //deprecated and potentially inaccurate. Use MouseWheelScrollEvent instead.")
    struct MouseWheelEvent
    {
        /**
         * Number of ticks the wheel has moved
         * (positive is up, negative is down)
         */
        int delta;

        /**
         * X position of the mouse pointer, relative to the left of the owner
         * window.
         */
        int x;

        /**
         * Y position of the mouse pointer, relative to the top of the owner
         * window.
         */
        int y;
    }

    /**
     * Mouse wheel scroll events parameters (MouseWheelScrolled)
     */
    struct MouseWheelScrollEvent
    {
        /// Which wheel (for mice with multiple ones).
        Mouse.Wheel wheel;

        /// Wheel offset. High precision mice may use non-integral offsets.
        float delta;

        /**
         * X position of the mouse pointer, relative to the left of the owner
         * window.
         */
        int x;

        /**
         * Y position of the mouse pointer, relative to the top of the owner
         * window.
         */
        int y;
    }

    /**
     * Size events parameters (Resized)
     */
    struct SizeEvent
    {
        ///New width, in pixels
        uint width;

        ///New height, in pixels
        uint height;
    }

    /**
     * Text event parameters (TextEntered)
     */
    struct TextEvent
    {
        /// UTF-32 unicode value of the character
        dchar unicode;
    }

    /**
     * Sensor event parameters
     */
    struct SensorEvent
    {
        ///Type of the sensor
        Sensor.Type type;

        /// Current value of the sensor on X axis
        float x;

        /// Current value of the sensor on Y axis
        float y;

        /// Current value of the sensor on Z axis
        float z;
    }

    /**
     * Touch Event parameters
     */
    struct TouchEvent
    {
        ///Index of the finger in case of multi-touch events.
        uint finger;

        /// X position of the touch, relative to the left of the owner window.
        int x;

        /// Y position of the touch, relative to the top of the owner window.
        int y;
    }

    /// Type of the event.
    enum Type {
        /// The window requested to be closed (no data)
        Closed,
        /// The window was resized (data in event.size)
        Resized,
        /// The window lost the focus (no data)
        LostFocus,
        /// The window gained the focus (no data)
        GainedFocus,
        /// A character was entered (data in event.text)
        TextEntered,
        /// A key was pressed (data in event.key)
        KeyPressed,
        /// A key was released (data in event.key)
        KeyReleased,
        /// The mouse wheel was scrolled (data in event.mouseWheel)
        MouseWheelMoved,
        /// The mouse wheel was scrolled (data in event.mouseWheelScroll)
        MouseWheelScrolled,
        /// A mouse button was pressed (data in event.mouseButton)
        MouseButtonPressed,
        /// A mouse button was released (data in event.mouseButton)
        MouseButtonReleased,
        /// The mouse cursor moved (data in event.mouseMove)
        MouseMoved,
        /// The mouse cursor entered the area of the window (no data)
        MouseEntered,
        /// The mouse cursor left the area of the window (no data)
        MouseLeft,
        /// A joystick button was pressed (data in event.joystickButton)
        JoystickButtonPressed,
        /// A joystick button was released (data in event.joystickButton)
        JoystickButtonReleased,
        /// The joystick moved along an axis (data in event.joystickMove)
        JoystickMoved,
        /// A joystick was connected (data in event.joystickConnect)
        JoystickConnected,
        /// A joystick was disconnected (data in event.joystickConnect)
        JoystickDisconnected,
        /// A touch event began (data in event.touch)
        TouchBegan,
        /// A touch moved (data in event.touch)
        TouchMoved,
        /// A touch ended (data in event.touch)
        TouchEnded,
        /// A sensor value changed (data in event.sensor)
        SensorChanged,

        ///Keep last -- the total number of event types
        Count
    }

    ///Type of the event
    Type type;

    union
    {
        /// Size event parameters (Event::Resized)
        SizeEvent size;

        /// Key event parameters (Event::KeyPressed, Event::KeyReleased)
        KeyEvent key;

        /// Text event parameters (Event::TextEntered)
        TextEvent text;

        /// Mouse move event parameters (Event::MouseMoved)
        MouseMoveEvent mouseMove;

        /// Mouse button event parameters (Event::MouseButtonPressed, Event::MouseButtonReleased)
        MouseButtonEvent mouseButton;

        /// Mouse wheel event parameters (Event::MouseWheelMoved)
        MouseWheelEvent mouseWheel;

        /// Mouse wheel scroll event parameters
        //MouseWheelScrollEvent mouseWheelScroll;

        /// Joystick move event parameters (Event::JoystickMoved)
        JoystickMoveEvent joystickMove;

        /// Joystick button event parameters (Event::JoystickButtonPressed, Event::JoystickButtonReleased)
        JoystickButtonEvent joystickButton;

        /// Joystick (dis)connect event parameters (Event::JoystickConnected, Event::JoystickDisconnected)
        JoystickConnectEvent joystickConnect;

        /// Touch event parameters
        TouchEvent touch;

        /// Sensor event Parameters
        SensorEvent sensor;
    }
}