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
 * The audio listener defines the global properties of the audio environment, it
 * defines where and how sounds and musics are heard.
 *
 * If $(VIEW_LINK) is the eyes of the user, then
 * $(U Listener) is his ears (by the way, they are often linked together – same
 * position, orientation, etc.).
 *
 * $(U Listener) is a simple interface, which allows to setup the listener in
 * the 3D audio environment (position and direction), and to adjust the global
 * volume.
 *
 * Because the listener is unique in the scene, $(U Listener) only contains
 * static functions and doesn't have to be instanciated.
 *
 * Example:
 * ---
 * // Move the listener to the position (1, 0, -5)
 * Listener.position = Vector3f(1, 0, -5);
 *
 * // Make it face the right axis (1, 0, 0)
 * Listener.direction = Vector3f(1, 0, 0);
 *
 * // Reduce the global volume
 * Listener.globalVolume = 50;
 * ---
 */
module nudsfml.audio.listener;

import nudsfml.system.vector3;

import bindbc.sfml.audio;
import bindbc.sfml.system;

/**
 * The audio listener is the point in the scene from where all the sounds are
 * heard.
 */
final abstract class Listener
{
    @property
    {
        /**
         * The orientation of the listener in the scene.
         *
         * The orientation defines the 3D axes of the listener (left, up, front)
         * in the scene. The orientation vector doesn't have to be normalized.
         *
         * The default listener's orientation is (0, 0, -1).
         */
        static void direction(Vector3f orientation)
        {
            sfListener_setDirection(cast(sfVector3f)orientation);
        }

        /// ditto
        static Vector3f direction() {
            Vector3f temp = cast(Vector3f)sfListener_getDirection();
            return temp;
        }
    }

    @property
    {
        /**
         * The upward vector of the listener in the scene.
         *
         * The upward vector defines the 3D axes of the listener (left, up,
         * front) in the scene. The upward vector doesn't have to be normalized.
         *
         * The default listener's upward vector is (0, 1, 0).
         */
        static void upVector(Vector3f orientation)
        {
            sfListener_setUpVector(cast(sfVector3f)orientation);
        }

        /// ditto
        static Vector3f upVector()
        {
            Vector3f temp = cast(Vector3f)sfListener_getUpVector();
            return temp;
        }
    }

    @property
    {
        /**
         * The global volume of all the sounds and musics.
         *
         * The volume is a number between 0 and 100; it is combined with the
         * individual volume of each sound / music.
         *
         * The default value for the volume is 100 (maximum).
         */
        static void globalVolume(float volume)
        {
            sfListener_setGlobalVolume(volume);
        }

        /// ditto
        static float globalVolume()
        {
            return sfListener_getGlobalVolume();
        }
    }

    @property
    {
        /**
         * The position of the listener in the scene.
         *
         * The default listener's position is (0, 0, 0).
         */
        static void position(Vector3f pos)
        {
            sfListener_setPosition(cast(sfVector3f)pos);
        }

        /// ditto
        static Vector3f position()
        {
            Vector3f temp = cast(Vector3f)sfListener_getPosition();
            return temp;
        }
    }

    //deorecated("Use the 'direction' property instead.")
    @property
    {
        /**
         * The orientation of the listener in the scene.
         *
         * The orientation defines the 3D axes of the listener (left, up, front)
         * in the scene. The orientation vector doesn't have to be normalized.
         *
         * The default listener's orientation is (0, 0, -1).
         *
         * //deorecated: Use the 'direction' property instead.
         */
        static void Direction(Vector3f orientation)
        {
            sfListener_setDirection(cast(sfVector3f)orientation);
        }

        /// ditto
        static Vector3f Direction()
        {
            Vector3f temp = cast(Vector3f)sfListener_getDirection();
            return temp;
        }
    }

    //deorecated("Use the 'upVector' property instead.")
    @property
    {
        /**
         * The upward vector of the listener in the scene.
         *
         * The upward vector defines the 3D axes of the listener (left, up,
         * front) in the scene. The upward vector doesn't have to be normalized.
         *
         * The default listener's upward vector is (0, 1, 0).
         *
         * //deorecated: Use the 'upVector' property instead.
         */
        static void UpVector(Vector3f orientation)
        {
            sfListener_setUpVector(cast(sfVector3f)orientation);
        }

        /// ditto
        static Vector3f UpVector()
        {
            Vector3f temp = cast(Vector3f)sfListener_getUpVector();
            return temp;
        }
    }

    //deorecated("Use the 'globalVolume' property instead.")
    @property
    {
        /**
         * The global volume of all the sounds and musics. The volume is a
         * number between 0 and 100; it is combined with the individual volume
         * of each sound / music.
         *
         * The default value for the volume is 100 (maximum).
         *
         * //deorecated: Use the 'globalVolume' property instead.
         */
        static void GlobalVolume(float volume)
        {
            sfListener_setGlobalVolume(volume);
        }

        /// ditto
        static float GlobalVolume()
        {
            return sfListener_getGlobalVolume();
        }
    }

    //deorecated("Use the 'position' property instead.")
    @property
    {
        /**
         * The position of the listener in the scene.
         *
         * The default listener's position is (0, 0, 0).
         *
         * //deorecated: Use the 'position' property instead.
         */
        static void Position(Vector3f position)
        {

            sfListener_setPosition(cast(sfVector3f)position);
        }

        /// ditto
        static Vector3f Position()
        {
            Vector3f temp = cast(Vector3f) sfListener_getPosition();
            return temp;
        }
    }
}

unittest
{
    version (DSFML_Unittest_Audio)
    {
        import std.stdio;

        writeln("Unit test for Listener");

        float volume = Listener.GlobalVolume;
        volume -= 10;
        Listener.GlobalVolume = volume;

        Vector3f pos = Listener.Position;
        pos.x += 10;
        pos.y -= 10;
        pos.z *= 3;
        Listener.Position = pos;

        Vector3f dir = Listener.Direction;
        dir.x += 10;
        dir.y -= 10;
        dir.z *= 3;
        Listener.Direction = dir;
        writeln("Unit tests pass!");
        writeln();
    }
}


