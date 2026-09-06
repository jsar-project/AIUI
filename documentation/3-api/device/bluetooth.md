# 蓝牙

AIUI 提供基于 `navigator.bluetooth` 的蓝牙能力，适合发现附近 BLE 设备、建立连接、读取服务和特征值，以及接收通知更新。

如果你的应用需要连接心率带、控制器、外设传感器或其他低功耗蓝牙设备，可以从这里开始。

## 请求并连接设备

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

## 扫描示例

```javascript
const scan = await navigator.bluetooth.scanDevices({
  filters: [{ services: ['heart_rate'] }],
});

scan.onDeviceFound((event) => {
  console.log('发现设备:', event.device.id, event.device.name);
});

// 不再需要时停止扫描
scan.stop();
```

## 将智能体作为蓝牙外设

当其他 BLE 设备需要读取或写入智能体提供的数据时，可以在 `foreground` Agent Worker 中声明 `bluetooth-peripheral`，并发布本地 GATT Server。

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

Service 和 Characteristic 会在 `openGattServer()` 成功时一次性创建。需要改变结构时，应先关闭当前 Server，再创建新的 Server。通过 `updateValue()` 更新 Characteristic 数据后，已订阅的设备可以收到变化通知。

## 适用场景

- 搜索并连接 BLE 外设
- 读取设备状态或实时数据
- 向设备发送控制命令
- 订阅特征值通知并接收持续更新
- 将智能体作为 BLE 外设，向附近设备提供可读写或可订阅的数据

## 使用建议

- 优先根据服务 UUID 或设备名称过滤，减少无关扫描结果。
- 连接后先确认服务和特征值是否存在，再进入读写流程。
- 对通知型特征值优先使用 `startNotifications()`，不要频繁轮询读取。
- 在页面离开或设备不再使用时及时断开连接或停止扫描。

## 注意事项

- 搜索或选择附近设备通常需要当前界面允许用户交互。
- `connect()`、`requestDevice()`、`scanDevices()` 等调用失败时，应明确区分“不可用”“无权限”“连接失败”几类状态。
- 特征值通知到来时，`characteristic.value` 会更新为最新缓存值。

## 继续阅读

- **[加速度计](/AIUI/api/device-accelerometer)**：查看设备运动传感器能力。
- **[设备](/AIUI/api/device)**：返回设备能力总览。
- **[Agent Worker](/AIUI/framework/open-agent-format-agent-worker)**：了解如何声明持续运行的蓝牙服务。

## API Reference

### 入口

```javascript
const bluetooth = navigator.bluetooth;
```

### 常用能力

#### `getAvailability()`
- 检查当前运行环境是否可用蓝牙能力。

#### `getDevices()`
- 获取当前运行时已经记住的设备列表。

#### `requestDevice(options?)`
- 请求用户选择一个设备，并返回对应 `BluetoothDevice`。

#### `scanDevices(options?)`
- 启动持续扫描并返回 `BluetoothScan`，适合长时间发现设备的场景。

### `navigator.bluetoothPeripheral`

仅在声明了 `bluetooth-peripheral` 的 Agent Worker 中可用。

#### `openGattServer(options)`

创建并返回一个 `BluetoothLocalGATTServer`。`options.services` 用于声明 Service、Characteristic、支持的读写或通知方式，以及可选的安全要求。

#### `server.startAdvertising(options?)`

开始广播。`options.name` 设置广播名称，`options.serviceUUIDs` 设置要广播的 Service UUID。

#### `server.stopAdvertising()`

停止广播，但保留当前 GATT Server。

#### `server.close()`

停止广播并关闭当前 GATT Server。

#### `server.getService(uuid)`

返回指定 Service。找不到时会抛出 `NotFoundError`。

#### `service.getCharacteristic(uuid)`

返回指定 Characteristic。找不到时会抛出 `NotFoundError`。

#### `characteristic.updateValue(value, options?)`

更新 Characteristic 的值。对支持 `notify` 或 `indicate` 的 Characteristic，可通过 `options.centrals` 选择接收通知的已订阅设备；省略时发送给全部订阅者。

#### Characteristic 请求事件

| 事件 | 说明 |
| --- | --- |
| `readrequest` | 其他设备请求读取时触发；调用 `event.respondWith(value)` 返回数据 |
| `writerequest` | 其他设备请求写入时触发；通过 `event.value` 读取数据，并调用 `event.respondWith()` 完成请求 |
| `subscribe` | 设备开始订阅通知时触发 |
| `unsubscribe` | 设备取消订阅时触发 |
