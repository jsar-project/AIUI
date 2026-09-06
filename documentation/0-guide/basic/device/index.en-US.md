# Device

AIUI provides capabilities for connecting peripherals and reading device sensors, allowing your agent to interact directly with hardware.

At present, device capabilities mainly fall into two categories:

- **Bluetooth**: Connect to and read from or write to BLE peripherals, or create a GATT Server that provides data to nearby devices.
- **IMU**: Read motion and posture data such as from the accelerometer, gyroscope, and absolute orientation sensor.

## How To Choose

- If you want to connect to heart-rate straps, controllers, or other BLE peripherals: use **Bluetooth**
- If you want a phone or another device to connect to the agent and read its data: use a **Bluetooth GATT Server**
- If you want to detect device movement, shaking, or rotation: use **IMU**
- If you want to combine multiple sensors for posture estimation or motion analysis: use Bluetooth + IMU

## Continue Reading

- **[Bluetooth](/AIUI/guide/basic-device-bluetooth)**: Learn how to connect to peripherals or provide data to nearby devices through a GATT Server.
- **[IMU](/AIUI/guide/basic-device-imu)**: Learn how to read acceleration, rotational velocity, and spatial orientation data.
