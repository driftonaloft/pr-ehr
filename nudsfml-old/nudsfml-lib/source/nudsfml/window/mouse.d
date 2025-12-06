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