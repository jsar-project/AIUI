# 设备

除了网络通道本身，AIUI 也提供了一组和设备连接、运动感知、姿态感知相关的能力。你可以把这部分理解为“设备侧输入与连接能力”，适合连接 BLE 外设，或读取设备的加速度、方向和旋转状态。

如果你的应用需要和传感器或外部设备协同工作，通常可以从这一组文档开始：

- **蓝牙**：适合发现、连接和读写 BLE 外设。
- **加速度计**：适合检测移动、震动、位移趋势等运动信息。
- **绝对方向传感器**：适合感知设备朝向和空间姿态。
- **陀螺仪**：适合感知旋转速度和头动变化。
- **电池状态**：适合读取电量、充电状态并监听变化。

## 如何选择

- 想连接外部硬件或读取 GATT 服务：使用 `蓝牙`
- 想判断设备是否在移动、晃动或加速：使用 `加速度计`
- 想获取设备当前朝向或姿态：使用 `绝对方向传感器`
- 想检测旋转速度变化：使用 `陀螺仪`
- 想读取或监听电池状态：使用 `BatteryManager`

## 简单示例

例如，创建一个加速度计实例并开始监听：

```javascript
const sensor = new Accelerometer({ frequency: 60 });

sensor.addEventListener('reading', () => {
  console.log(sensor.x, sensor.y, sensor.z);
});

sensor.start();
```

## 继续阅读

- **[蓝牙](/AIUI/api/device-bluetooth)**：查看如何发现设备、连接外设并读写特征值。
- **[加速度计](/AIUI/api/device-accelerometer)**：查看如何读取设备运动数据。
- **[绝对方向传感器](/AIUI/api/device-absolute-orientation-sensor)**：查看如何获取设备朝向与姿态。
- **[陀螺仪](/AIUI/api/device-gyroscope)**：查看如何读取设备旋转速度。
- **[BatteryManager](/AIUI/api/device-battery-manager)**：查看如何读取和监听电池状态。
