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

module nudsfml.window.sensor;

import bindbc.sfml.window;

import nudsfml.system.vector3;

/**
 * Give access to the real-time state of the sensors.
 */
final abstract class Sensor {
    /// Sensor type
    enum Type{
        /// Measures the raw acceleration (m/s²)
        Accelerometer,
        /// Measures the raw rotation rates (°/s)
        Gyroscope,
        /// Measures the ambient magnetic field (micro-teslas)
        Magnetometer,
        /**
         * Measures the direction and intensity of gravity, independent of
         * device acceleration (m/s²)
         */
        Gravity,
        /**
         * Measures the direction and intensity of device cceleration,
         * independent of the gravity (m/s²)
         */
        UserAcceleration,
        /// Measures the absolute 3D orientation (°)
        Orientation,
        /// Keep last - the total number of sensor types
        Count
    }

    /**
    * Check if a sensor is available on the underlying platform.
    *
    * Params:
    *	sensor = Sensor to check
    *
    * Returns: true if the sensor is available, false otherwise.
    */
    static bool isAvailable (Type sensor){
        return false; //sfSensor_isAvailable(cast(sfSensorType)sensor)>0;
    }

    /**
    * Enable or disable a sensor.
    *
    * All sensors are disabled by default, to avoid consuming too much battery
    * power. Once a sensor is enabled, it starts sending events of the
    * corresponding type.
    *
    * This function does nothing if the sensor is unavailable.
    *
    * Params:
    *   sensor = Sensor to enable
    *   enabled = true to enable, false to disable
    */
    static void setEnabled (Type sensor, bool enabled) {
        //sfSensor_setEnabled(cast(sfSensorType)sensor, enabled);
    }

    /**
    * Get the current sensor value.
    *
    * Params:
    *   sensor = Sensor to read
    *
    * Returns: The current sensor value.
    */
    static Vector3f getValue (Type sensor){
        Vector3f getValue ;//= cast(Vector3f)sfSensor_getValue(cast(sfSensorType)sensor);
        return getValue;
    }
}