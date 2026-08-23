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

## Use Cases

- Search for and connect to BLE peripherals
- Read device status or real-time data
- Send control commands to devices
- Subscribe to characteristic notifications and receive continuous updates

## Recommendations

- Prefer filtering by service UUID or device name to reduce irrelevant scan results.
- After connecting, confirm that the target service and characteristic exist before entering the read/write flow.
- For characteristics that support notifications, prefer `startNotifications()` over frequent polling reads.
- Disconnect or stop scanning promptly when leaving the page or when the device is no longer needed.

## Notes

- Starting newer Bluetooth capabilities usually requires the current `InkView` to remain interactive.
- When calls such as `connect()`, `requestDevice()`, or `scanDevices()` fail, clearly distinguish between states such as unavailable, no permission, and connection failure.
- When a characteristic notification arrives, `characteristic.value` is updated with the latest cached value.

## Continue Reading

- **[Accelerometer](/AIUI/api/device-accelerometer)**: Learn about device motion sensor capabilities.
- **[Device](/AIUI/api/device)**: Return to the device capability overview.

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
