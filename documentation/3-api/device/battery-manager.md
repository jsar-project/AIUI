# BatteryManager

`navigator.getBattery()` 用于读取宿主提供的电池状态，并通过 `BatteryManager` 监听充电状态、电量与预计时长变化。

## 读取电池状态

```javascript
const battery = await navigator.getBattery();

console.log('level:', battery.level);
console.log('charging:', battery.charging);
```

`level` 的范围为 `0.0` 到 `1.0`。宿主无法给出可靠时长时，`chargingTime` 或 `dischargingTime` 返回 `Infinity`。

## 监听电池变化

```javascript
const battery = await navigator.getBattery();

battery.addEventListener('levelchange', () => {
  console.log('level:', battery.level);
});

battery.onchargingchange = () => {
  console.log('charging:', battery.charging);
};
```

只有底层值实际变化时，对应事件才会触发。

## 可用性与当前行为

- `BatteryManager` 只能通过 `navigator.getBattery()` 获取，不能直接构造。
- 电池能力由宿主提供；宿主未注册该能力时，`navigator.getBattery()` 会拒绝。
- 事件对象使用标准 `Event` 形态，不附带自定义电池数据；请从 `battery` 属性读取最新值。

## API Reference

### `navigator.getBattery()`

返回 `Promise<BatteryManager>`。同一个 `navigator` 会复用已经创建的电池管理器。

### `BatteryManager` 属性

| 属性 | 类型 | 说明 |
| --- | --- | --- |
| `charging` | `boolean` | 当前是否正在充电或已经充满。 |
| `chargingTime` | `number` | 距离充满的秒数；无法估计时为 `Infinity`。 |
| `dischargingTime` | `number` | 距离完全放电的秒数；无法估计时为 `Infinity`。 |
| `level` | `number` | 归一化电量，范围为 `0.0` 到 `1.0`。 |

### `BatteryManager` 事件

| 事件 | Handler 属性 | 触发条件 |
| --- | --- | --- |
| `chargingchange` | `onchargingchange` | `charging` 变化。 |
| `chargingtimechange` | `onchargingtimechange` | `chargingTime` 变化。 |
| `dischargingtimechange` | `ondischargingtimechange` | `dischargingTime` 变化。 |
| `levelchange` | `onlevelchange` | `level` 变化。 |
