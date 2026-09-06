# Geolocation

`Geolocation` reads the device's current position or reports updates as the user moves. Access it through `navigator.geolocation` for navigation, activity tracking, and location-aware content.

## Get the Current Position

`getCurrentPosition()` requests one position. Read the coordinates and accuracy from `position.coords` after it succeeds:

```javascript
navigator.geolocation.getCurrentPosition(
  (position) => {
    const { latitude, longitude, accuracy } = position.coords;
    console.log('Current position:', latitude, longitude);
    console.log('Accuracy:', accuracy, 'metres');
  },
  (error) => {
    console.error('Location failed:', error.message);
  },
  {
    enableHighAccuracy: true,
    timeout: 5000,
    maximumAge: 0,
  }
);
```

## Watch Position Changes

`watchPosition()` returns a watch ID. Stop the watch with that ID when the page no longer needs updates:

```javascript
const watchId = navigator.geolocation.watchPosition(
  (position) => {
    console.log(position.coords.latitude, position.coords.longitude);
  },
  (error) => {
    console.error(error.code, error.message);
  }
);

// Call this when location updates are no longer needed.
navigator.geolocation.clearWatch(watchId);
```

Stopping unused watches avoids unnecessary positioning work and battery use.

## Declare Location Permission

Declare the `GEOLOCATION` permission in `app.json` before using location:

```json
{
  "permissions": ["GEOLOCATION"]
}
```

The user must also allow the device's location permission. The error callback reports permission denial, an unavailable position, or a timeout.

## API Reference

### `navigator.geolocation`

Returns the application's `Geolocation` object. The runtime provides this object; applications do not construct it.

### `getCurrentPosition(success, error?, options?)`

Requests one current position. It has no return value and delivers the result through callbacks.

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| `success` | `(position) => void` | Yes | Called when a position is available. |
| `error` | `(error) => void` | No | Called when positioning fails. |
| `options` | `PositionOptions` | No | Accuracy, timeout, and cache settings. |

### `watchPosition(success, error?, options?)`

Watches for position changes and returns a numeric `watchId`. Pass it to `clearWatch()` when updates are no longer needed.

### `clearWatch(watchId)`

Stops the location watch identified by `watchId`.

### `PositionOptions`

| Field | Type | Description |
| --- | --- | --- |
| `enableHighAccuracy` | `boolean` | Prefer a more accurate position. Defaults to `false`; high-accuracy positioning may use more power. |
| `timeout` | `number` | Maximum time to wait, in milliseconds; the device decides when omitted. |
| `maximumAge` | `number` | Maximum acceptable age of a cached position, in milliseconds; the device decides when omitted. |

### `GeolocationPosition`

| Property | Type | Description |
| --- | --- | --- |
| `coords.latitude` | `number` | Latitude. |
| `coords.longitude` | `number` | Longitude. |
| `coords.accuracy` | `number` | Coordinate accuracy in metres. |
| `coords.altitude` | `number \| null` | Altitude, or `null` when unavailable. |
| `coords.altitudeAccuracy` | `number \| null` | Altitude accuracy, or `null` when unavailable. |
| `coords.heading` | `number \| null` | Direction of travel, or `null` when unavailable. |
| `coords.speed` | `number \| null` | Travel speed, or `null` when unavailable. |
| `timestamp` | `number` | Timestamp when the position was obtained. |

### `GeolocationPositionError`

| `code` | Constant | Description |
| --- | --- | --- |
| `1` | `PERMISSION_DENIED` | The user or application did not allow location access. |
| `2` | `POSITION_UNAVAILABLE` | A position is currently unavailable. |
| `3` | `TIMEOUT` | No position was available before the timeout. |

`message` contains a human-readable description of the error.
