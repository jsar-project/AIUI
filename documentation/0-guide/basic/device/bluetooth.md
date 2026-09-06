# 蓝牙

蓝牙能力既可以让智能体搜索、连接和读写附近的 BLE（低功耗蓝牙）设备，也可以让智能体作为 BLE 外设向附近设备提供数据。

如果你的智能体需要连接心率带、遥控器、外设传感器或其他 BLE 硬件，可以从这里开始。

## 适用场景

- 搜索附近的 BLE 设备
- 连接外设并读写 GATT 服务与特征值
- 订阅设备通知，持续接收状态更新
- 创建 GATT Server，让附近设备读取、写入或订阅智能体提供的数据

## 基本用法

通过 `navigator.bluetooth` 发起设备请求，连接到设备后读取服务：

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

## 扫描设备

如果需要持续发现附近设备，可以使用扫描模式：

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

## 作为 BLE 外设提供数据

需要让手机、控制器或其他 BLE 设备主动连接智能体时，可以在 `foreground` Agent Worker 中声明 `bluetooth-peripheral`。这个能力会提供 `navigator.bluetoothPeripheral`，用于创建本地 GATT Server。

先在 `app.json` 中声明后台任务：

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

然后在 `workers/bluetooth.js` 中创建可读取的 Characteristic 并开始广播：

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

Agent Worker 会避免蓝牙服务依赖某一个 Page。只要智能体仍有 Page 或 Widget 打开，`foreground` 任务就会继续提供服务。

## 使用建议

- 优先用服务 UUID 或设备名称过滤，减少无关扫描结果。
- 连接后先确认服务和特征值是否存在，再进入读写流程。
- 对持续更新的数据优先使用通知而非轮询。
- 页面离开或不再需要时及时断开连接。

## 注意事项

- 搜索、选择或首次连接附近设备时，当前界面需要允许用户交互。
- GATT Server 必须在声明了 `bluetooth-peripheral` 的 `foreground` Agent Worker 中创建。
- `connect()`、`requestDevice()` 等调用失败时，应当区分"不可用""无权限""连接失败"等不同状态。
- 通知事件触发后 `characteristic.value` 会更新为最新缓存值。

## 继续阅读

- **[IMU](/AIUI/guide/basic-device-imu)**：查看设备运动与姿态传感器能力。
- **[蓝牙 (API 参考)](/AIUI/api/device-bluetooth)**：查看蓝牙 API 的完整参考文档。
- **[Agent Worker](/AIUI/framework/open-agent-format-agent-worker)**：了解后台任务的配置和运行时长。
