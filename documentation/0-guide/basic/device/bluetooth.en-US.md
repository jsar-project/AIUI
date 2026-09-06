# Bluetooth

Bluetooth capabilities allow your agent to discover, connect to, and read from or write to nearby BLE (Bluetooth Low Energy) devices. They can also let the agent act as a BLE peripheral that provides data to nearby devices.

If your app needs to connect to heart-rate straps, controllers, peripheral sensors, or other BLE hardware, this is a good place to start.

## Use Cases

- Discover nearby BLE devices
- Connect to peripherals and read from or write to GATT services and characteristics
- Subscribe to device notifications and continuously receive status updates
- Create a GATT Server that nearby devices can read, write, or subscribe to

## Basic Usage

Use `navigator.bluetooth` to request a device, then connect to the device and read its services:

```javascript
const device = await navigator.bluetooth.requestDevice({
  filters: [{ services: ['0000180d-0000-1000-8000-00805f9b34fb'] }],
  optionalServices: ['0000180f-0000-1000-8000-00805f9b34fb'],
});

const server = await device.gatt.connect();
const service = await server.getPrimaryService('0000180d-0000-1000-8000-00805f9b34fb');
const characteristic = await service.getCharacteristic('00002a37-0000-1000-8000-00805f9b34fb');

await characteristic.startNotifications();
characteristic.addEventListener('characteristicvaluechanged', () => {
  console.log(characteristic.value);
});
```

## Scan for Devices

If you need to keep discovering nearby devices, you can use scan mode:

```javascript
const scan = await navigator.bluetooth.scanDevices({
  filters: [{ services: ['heart_rate'] }],
});

scan.onDeviceFound((event) => {
  console.log('Device found:', event.device.id, event.device.name);
});

// Stop when scanning is no longer needed.
scan.stop();
```

## Provide Data as a BLE Peripheral

When a phone, controller, or another BLE device needs to connect to the agent, declare `bluetooth-peripheral` in a `foreground` Agent Worker. This capability provides `navigator.bluetoothPeripheral` for creating a local GATT Server.

First declare the background task in `app.json`:

```json
{
  "agentWorkers": [
    {
      "name": "bluetooth",
      "script": "workers/bluetooth.js",
      "trigger": { "type": "open" },
      "lifetime": "foreground",
      "capabilities": ["bluetooth-peripheral"]
    }
  ]
}
```

Then create a readable characteristic and start advertising in `workers/bluetooth.js`:

```javascript
const serviceUuid = '12345678-1234-5678-1234-56789abcdef0';
const valueUuid = '12345678-1234-5678-1234-56789abcdef1';

export default {
  onOpen(event) {
    event.waitUntil(this.startServer());
  },

  async startServer() {
    if (this.server?.state === 'open') return;

    this.server = await navigator.bluetoothPeripheral.openGattServer({
      services: [{
        uuid: serviceUuid,
        characteristics: [{
          uuid: valueUuid,
          properties: { read: true, notify: true },
        }],
      }],
    });

    const value = this.server
      .getService(serviceUuid)
      .getCharacteristic(valueUuid);

    value.addEventListener('readrequest', (event) => {
      event.respondWith(new Uint8Array([1]));
    });

    await this.server.startAdvertising({
      name: 'AIUI Sensor',
      serviceUUIDs: [serviceUuid],
    });
  },
};
```

The Agent Worker keeps the Bluetooth service independent of any one Page. The `foreground` task continues providing the service while the agent still has an open Page or Widget.

## Best Practices

- Prefer filtering by service UUID or device name to reduce irrelevant scan results.
- After connecting, confirm that the required services and characteristics exist before starting the read/write flow.
- Prefer notifications over polling for continuously updated data.
- Disconnect promptly when leaving the page or when the connection is no longer needed.

## Notes

- The current interface must allow user interaction when searching for, selecting, or initially connecting to a nearby device.
- A GATT Server must be created in a `foreground` Agent Worker that declares `bluetooth-peripheral`.
- When calls such as `connect()` or `requestDevice()` fail, distinguish between states such as "unavailable", "no permission", and "connection failed".
- After a notification event fires, `characteristic.value` is updated to the latest cached value.

## Continue Reading

- **[IMU](/AIUI/guide/basic-device-imu)**: See motion and posture sensor capabilities on the device.
- **[Bluetooth (API Reference)](/AIUI/api/device-bluetooth)**: See the complete Bluetooth API reference.
- **[Agent Worker](/AIUI/framework/open-agent-format-agent-worker)**: Learn how to configure a background task and choose its lifetime.
