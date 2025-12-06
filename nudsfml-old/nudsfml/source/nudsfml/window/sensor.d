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