# Geolocation

`Geolocation` 用于读取设备当前所在位置，或者在用户移动时持续接收位置变化。它通过 `navigator.geolocation` 使用，适合导航、运动记录和基于位置提供内容等场景。

## 获取当前位置

`getCurrentPosition()` 会请求一次位置。成功后，可以从 `position.coords` 读取经纬度和精度：

```javascript
navigator.geolocation.getCurrentPosition(
  (position) => {
    const { latitude, longitude, accuracy } = position.coords;
    console.log('当前位置：', latitude, longitude);
    console.log('精度：', accuracy, '米');
  },
  (error) => {
    console.error('定位失败：', error.message);
  },
  {
    enableHighAccuracy: true,
    timeout: 5000,
    maximumAge: 0,
  }
);
```

## 持续获取位置变化

`watchPosition()` 会返回一个监听编号。页面不再需要位置更新时，使用这个编号停止监听：

```javascript
const watchId = navigator.geolocation.watchPosition(
  (position) => {
    console.log(position.coords.latitude, position.coords.longitude);
  },
  (error) => {
    console.error(error.code, error.message);
  }
);

// 不再需要位置更新时调用。
navigator.geolocation.clearWatch(watchId);
```

及时停止监听可以减少不必要的定位和电量消耗。

## 声明定位权限

使用定位前，需要在 `app.json` 中声明 `GEOLOCATION` 权限：

```json
{
  "permissions": ["GEOLOCATION"]
}
```

用户还需要允许设备的定位权限。定位被拒绝、暂时不可用或超时时，失败回调会收到对应错误。

## API Reference

### `navigator.geolocation`

返回当前应用的 `Geolocation` 对象。该对象由运行时提供，不需要自行构造。

### `getCurrentPosition(success, error?, options?)`

获取一次当前位置。方法没有返回值，结果通过回调传递。

| 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `success` | `(position) => void` | 是 | 成功获得位置时调用。 |
| `error` | `(error) => void` | 否 | 定位失败时调用。 |
| `options` | `PositionOptions` | 否 | 精度、超时和缓存设置。 |

### `watchPosition(success, error?, options?)`

持续监听位置变化，返回数字类型的 `watchId`。应在不再需要更新时把它传给 `clearWatch()`。

### `clearWatch(watchId)`

停止 `watchId` 对应的位置监听。

### `PositionOptions`

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `enableHighAccuracy` | `boolean` | 是否优先获取更精确的位置。默认值为 `false`；高精度定位可能消耗更多电量。 |
| `timeout` | `number` | 等待结果的最长时间，单位为毫秒；省略时由设备决定。 |
| `maximumAge` | `number` | 可以接受的缓存位置最长时间，单位为毫秒；省略时由设备决定。 |

### `GeolocationPosition`

| 属性 | 类型 | 说明 |
| --- | --- | --- |
| `coords.latitude` | `number` | 纬度。 |
| `coords.longitude` | `number` | 经度。 |
| `coords.accuracy` | `number` | 经纬度精度，单位为米。 |
| `coords.altitude` | `number \| null` | 海拔，不可用时为 `null`。 |
| `coords.altitudeAccuracy` | `number \| null` | 海拔精度，不可用时为 `null`。 |
| `coords.heading` | `number \| null` | 移动方向，不可用时为 `null`。 |
| `coords.speed` | `number \| null` | 移动速度，不可用时为 `null`。 |
| `timestamp` | `number` | 获取该位置时的时间戳。 |

### `GeolocationPositionError`

| `code` | 常量 | 说明 |
| --- | --- | --- |
| `1` | `PERMISSION_DENIED` | 用户或应用未允许定位。 |
| `2` | `POSITION_UNAVAILABLE` | 当前无法获得位置。 |
| `3` | `TIMEOUT` | 在设定时间内没有获得位置。 |

`message` 包含便于阅读的错误说明。
