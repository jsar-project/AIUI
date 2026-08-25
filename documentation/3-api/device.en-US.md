# Device

In addition to the network channel itself, AIUI also provides a set of capabilities related to device connectivity, motion sensing, and orientation sensing. You can think of this area as device-side input and connectivity capabilities. It is suitable for connecting BLE peripherals or reading the device's acceleration, direction, and rotation state.

If your application needs to work with sensors or external devices, this group of documents is usually the right place to start:

- **Bluetooth**: Suitable for discovering, connecting to, and reading or writing BLE peripherals.
- **Accelerometer**: Suitable for detecting motion, vibration, and displacement trends.
- **Absolute Orientation Sensor**: Suitable for sensing device direction and spatial pose.
- **Gyroscope**: Suitable for sensing rotational velocity and head movement changes.
- **Battery Status**: Suitable for reading battery level and charging state and observing changes.

## How To Choose

- Want to connect external hardware or read GATT services: use `Bluetooth`
- Want to tell whether the device is moving, shaking, or accelerating: use `Accelerometer`
- Want to get the device's current direction or pose: use `Absolute Orientation Sensor`
- Want to detect changes in rotational velocity: use `Gyroscope`
- Want to read or observe battery status: use `BatteryManager`

## Simple Example

For example, create an accelerometer instance and start listening:

```javascript
const sensor = new Accelerometer({ frequency: 60 });

sensor.addEventListener('reading', () => {
  console.log(sensor.x, sensor.y, sensor.z);
});

sensor.start();
```

## Continue Reading

- **[Bluetooth](/AIUI/api/device-bluetooth)**: See how to discover devices, connect peripherals, and read or write characteristics.
- **[Accelerometer](/AIUI/api/device-accelerometer)**: See how to read device motion data.
- **[Absolute Orientation Sensor](/AIUI/api/device-absolute-orientation-sensor)**: See how to get device direction and pose.
- **[Gyroscope](/AIUI/api/device-gyroscope)**: See how to read device rotational velocity.
- **[BatteryManager](/AIUI/api/device-battery-manager)**: See how to read and observe battery status.
