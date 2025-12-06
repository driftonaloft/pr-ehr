module nudsfml.window.mouse;

import bindbc.sfml.window;
import bindbc.sfml.system;

import nudsfml.system.vector2;
import nudsfml.window.window;

/**
* Give access to the real-time state of the mouse.
*/
final abstract class Mouse {
    /// Mouse buttons.
    enum Button {
        /// The left mouse button
        Left,
        /// The right mouse button
        Right,
        /// The middle (wheel) mouse button
        Middle,
        /// The first extra mouse button
        XButton1,
        /// The second extra mouse button
        XButton2,

        ///Keep last -- the total number of mouse buttons
        Count

    }

    /// Mouse wheels.
    enum Wheel {
        /// Vertically oriented mouse wheel
        VerticalWheel,
        /// Horizontally oriented mouse wheel
        HorizontalWheel
    }

    /**
     * Set the current position of the mouse in desktop coordinates.
     *
     * This function sets the global position of the mouse cursor on the
     * desktop.
     *
     * Params:
     * 		position = New position of the mouse
     */
    static void setPosition(Vector2i position) {
        sfVector2i pos = cast(sfVector2i) position;
        sfMouse_setPosition(pos,null);
    }

    /**
     * Set the current position of the mouse in window coordinates.
     *
     * This function sets the current position of the mouse cursor, relative to the given window.
     *
     * Params:
     * 		position   = New position of the mouse
     * 		relativeTo = Reference window
     */
    static void setPosition(Vector2i position, const(Window) relativeTo) {
        relativeTo.mouse_SetPosition(position);
    }

    /**
     * Get the current position of the mouse in desktop coordinates.
     *
     * This function returns the global position of the mouse cursor on the
     * desktop.
     *
     * Returns: Current position of the mouse.
     */
    static Vector2i getPosition() {
        Vector2i temp = cast(Vector2i) sfMouse_getPosition(null);

        return temp;
    }

    /**
     * Get the current position of the mouse in window coordinates.
     *
     * This function returns the current position of the mouse cursor, relative
     * to the given window.
     *
     * Params:
     *     relativeTo = Reference window
     *
     * Returns: Current position of the mouse.
     */
    static Vector2i getPosition(const(Window) relativeTo) {
        return relativeTo.mouse_getPosition();
    }

    /**
     * Check if a mouse button is pressed.
     *
     * Params:
     * 		button = Button to check
     *
     * Returns: true if the button is pressed, false otherwise.
     */
    static bool isButtonPressed(Button button) {
        return (sfMouse_isButtonPressed(cast(sfMouseButton)button)) > 0;
    }
}