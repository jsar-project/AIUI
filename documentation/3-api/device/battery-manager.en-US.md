# BatteryManager

Use `navigator.getBattery()` to read host-provided battery status and a `BatteryManager` to observe charging state, level, and estimated-time changes.

## Read Battery Status

```javascript
const battery = await navigator.getBattery();

console.log('level:', battery.level);
console.log('charging:', battery.charging);
```

`level` ranges from `0.0` to `1.0`. When the host cannot provide a meaningful estimate, `chargingTime` or `dischargingTime` is `Infinity`.

## Observe Battery Changes

```javascript
const battery = await navigator.getBattery();

battery.addEventListener('levelchange', () => {
  console.log('level:', battery.level);
});

battery.onchargingchange = () => {
  console.log('charging:', battery.charging);
};
```

An event is dispatched only when its backing value actually changes.

## Availability and Current Behavior

- A `BatteryManager` is obtained only through `navigator.getBattery()` and cannot be constructed directly.
- Battery support is host-provided. `navigator.getBattery()` rejects when the host has not registered this capability.
- Events use the standard `Event` shape and carry no custom battery payload; read the latest value from the `battery` object.

## API Reference

### `navigator.getBattery()`

Returns `Promise<BatteryManager>`. A created battery manager is reused by the same `navigator` instance.

### `BatteryManager` Properties

| Property | Type | Description |
| --- | --- | --- |
| `charging` | `boolean` | Whether the battery is charging or already full. |
| `chargingTime` | `number` | Seconds until fully charged, or `Infinity` when unavailable. |
| `dischargingTime` | `number` | Seconds until fully discharged, or `Infinity` when unavailable. |
| `level` | `number` | Normalized battery level from `0.0` to `1.0`. |

### `BatteryManager` Events

| Event | Handler Property | Trigger |
| --- | --- | --- |
| `chargingchange` | `onchargingchange` | `charging` changes. |
| `chargingtimechange` | `onchargingtimechange` | `chargingTime` changes. |
| `dischargingtimechange` | `ondischargingtimechange` | `dischargingTime` changes. |
| `levelchange` | `onlevelchange` | `level` changes. |
