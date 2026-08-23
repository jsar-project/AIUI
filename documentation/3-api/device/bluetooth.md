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

## 适用场景

- 搜索并连接 BLE 外设
- 读取设备状态或实时数据
- 向设备发送控制命令
- 订阅特征值通知并接收持续更新

## 使用建议

- 优先根据服务 UUID 或设备名称过滤，减少无关扫描结果。
- 连接后先确认服务和特征值是否存在，再进入读写流程。
- 对通知型特征值优先使用 `startNotifications()`，不要频繁轮询读取。
- 在页面离开或设备不再使用时及时断开连接或停止扫描。

## 注意事项

- 蓝牙相关的新能力启动通常要求当前 `InkView` 保持可交互。
- `connect()`、`requestDevice()`、`scanDevices()` 等调用失败时，应明确区分“不可用”“无权限”“连接失败”几类状态。
- 特征值通知到来时，`characteristic.value` 会更新为最新缓存值。

## 继续阅读

- **[加速度计](/AIUI/api/device-accelerometer)**：查看设备运动传感器能力。
- **[设备](/AIUI/api/device)**：返回设备能力总览。

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
