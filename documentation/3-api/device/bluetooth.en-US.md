# Bluetooth

AIUI provides Bluetooth capabilities based on `navigator.bluetooth`, suitable for discovering nearby BLE devices, establishing connections, reading services and characteristics, and receiving notification updates.

If your application needs to connect to heart rate belts, controllers, peripheral sensors, or other Bluetooth Low Energy devices, start here.

## Request and Connect to a Device

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

## Scan Example

```javascript
const scan = await navigator.bluetooth.scanDevices({
  filters: [{ services: ['heart_rate'] }],
});

scan.onDeviceFound((event) => {
  console.log('发现设备:', event.device.id, event.device.name);
});

// Stop scanning when it is no longer needed
scan.stop();
```

## Provide Data as a Bluetooth Peripheral

When another BLE device needs to read or write data provided by the agent, declare `bluetooth-peripheral` in a `foreground` Agent Worker and publish a local GATT Server.

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

```javascript
const serviceUuid = '12345678-1234-5678-1234-56789abcdef0';
const valueUuid = '12345678-1234-5678-1234-56789abcdef1';

export default {
  onOpen(event) {
    event.waitUntil(this.startBluetoothService());
  },
  async startBluetoothService() {
    if (this.server?.state === 'open') return;

    this.server = await navigator.bluetoothPeripheral.openGattServer({
      services: [{
        uuid: serviceUuid,
        characteristics: [{
          uuid: valueUuid,
          properties: { read: true, write: true, notify: true },
        }],
      }],
    });

    const value = this.server
      .getService(serviceUuid)
      .getCharacteristic(valueUuid);

    value.addEventListener('readrequest', (event) => {
      event.respondWith(new Uint8Array([1]));
    });
    value.addEventListener('writerequest', (event) => {
      console.log(new Uint8Array(
        event.value.buffer,
        event.value.byteOffset,
        event.value.byteLength,
      ));
      event.respondWith();
    });

    await this.server.startAdvertising({
      name: 'AIUI Sensor',
      serviceUUIDs: [serviceUuid],
    });
  },
};
```

Services and characteristics are created together when `openGattServer()` succeeds. To change their structure, close the current Server and create a new one. After `updateValue()` changes a characteristic value, subscribed devices can receive a notification.

## Use Cases

- Search for and connect to BLE peripherals
- Read device status or real-time data
- Send control commands to devices
- Subscribe to characteristic notifications and receive continuous updates
- Let nearby devices read, write, or subscribe to data while the agent acts as a BLE peripheral

## Recommendations

- Prefer filtering by service UUID or device name to reduce irrelevant scan results.
- After connecting, confirm that the target service and characteristic exist before entering the read/write flow.
- For characteristics that support notifications, prefer `startNotifications()` over frequent polling reads.
- Disconnect or stop scanning promptly when leaving the page or when the device is no longer needed.

## Notes

- Searching for or selecting nearby devices usually requires the current interface to allow user interaction.
- When calls such as `connect()`, `requestDevice()`, or `scanDevices()` fail, clearly distinguish between states such as unavailable, no permission, and connection failure.
- When a characteristic notification arrives, `characteristic.value` is updated with the latest cached value.

## Continue Reading

- **[Accelerometer](/AIUI/api/device-accelerometer)**: Learn about device motion sensor capabilities.
- **[Device](/AIUI/api/device)**: Return to the device capability overview.
- **[Agent Worker](/AIUI/framework/open-agent-format-agent-worker)**: Learn how to declare a Bluetooth service that stays active.

## API Reference

### Entry

```javascript
const bluetooth = navigator.bluetooth;
```

### Common Capabilities

#### `getAvailability()`
- Checks whether Bluetooth is available in the current runtime environment.

#### `getDevices()`
- Gets the list of devices already remembered by the current runtime.

#### `requestDevice(options?)`
- Prompts the user to select a device and returns the corresponding `BluetoothDevice`.

#### `scanDevices(options?)`
- Starts continuous scanning and returns `BluetoothScan`, which is suitable for scenarios that require long-running device discovery.

### `navigator.bluetoothPeripheral`

Available only inside an Agent Worker that declares `bluetooth-peripheral`.

#### `openGattServer(options)`

Creates and returns a `BluetoothLocalGATTServer`. `options.services` declares services, characteristics, supported read, write, or notification behavior, and optional security requirements.

#### `server.startAdvertising(options?)`

Starts advertising. `options.name` sets the advertised name, and `options.serviceUUIDs` sets the service UUIDs to advertise.

#### `server.stopAdvertising()`

Stops advertising while keeping the current GATT Server open.

#### `server.close()`

Stops advertising and closes the current GATT Server.

#### `server.getService(uuid)`

Returns the requested service. Throws `NotFoundError` when it does not exist.

#### `service.getCharacteristic(uuid)`

Returns the requested characteristic. Throws `NotFoundError` when it does not exist.

#### `characteristic.updateValue(value, options?)`

Updates the characteristic value. For a characteristic that supports `notify` or `indicate`, `options.centrals` can select subscribed devices that receive the update. Omitting it sends the update to all subscribers.

#### Characteristic Request Events

| Event | Description |
| --- | --- |
| `readrequest` | Fires when another device reads; call `event.respondWith(value)` with the response data |
| `writerequest` | Fires when another device writes; read `event.value` and call `event.respondWith()` to finish the request |
| `subscribe` | Fires when a device subscribes to updates |
| `unsubscribe` | Fires when a device unsubscribes |
