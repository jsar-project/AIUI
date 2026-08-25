# Navigator

Provides `navigator`-related capabilities in the runtime environment as the unified entry point for host identity, language preferences, runtime versions, and device-adjacent capabilities.

## Read Runtime and Locale Information

Read language, region, and runtime versions during startup to select localization settings and record diagnostics:

```javascript
const environment = {
  language: navigator.language,
  languages: navigator.languages,
  region: navigator.region,
  inkVersion: navigator.versions.ink,
  skiaVersion: navigator.versions.skia,
};

console.log(environment);
```

## Read Battery and Persistent Storage

```javascript
const battery = await navigator.getBattery();
const root = await navigator.storage.getDirectory();

console.log('battery:', battery.level);
console.log('storage root:', root.name);
```

## Notes

- `navigator.getDeviceSerialNumber()` returns the serial number provided by the host. If the host does not implement it, the return value is `''`. Be mindful of privacy and data security when using it.
- `navigator.userAgent` is suitable for identifying runtime and platform information. Avoid building tightly coupled logic that depends on string parsing.
- `navigator.language`, `navigator.languages`, and `navigator.region` are all derived from the host environment, so their exact values may vary across platforms.
- `navigator.bluetooth`, `navigator.geolocation`, `navigator.mediaDevices`, `navigator.storage`, and battery status depend on host capabilities and Agent permissions.

## API Reference

### Properties

#### `navigator.userAgent`

- **Description**: Returns the current runtime user-agent string. The host may also enrich it with platform-specific metadata.

```javascript
const userAgent = navigator.userAgent;
console.log('UA:', userAgent);
```

#### `navigator.id`

- **Description**: Returns the opaque content identifier for the current Agent on this device. It is an empty string when there is no current app instance.

#### `navigator.language`

- **Description**: Returns the primary language from the host. It is commonly used for default copy or localization strategy selection.

```javascript
const language = navigator.language;
console.log('Language:', language);
```

#### `navigator.languages`

- **Description**: Returns the ordered language preference list from the host, which is useful for finer-grained locale fallback logic.

```javascript
const languages = navigator.languages;
console.log('Languages:', languages);
```

#### `navigator.region`

- **Description**: Returns the region string provided by the host. It can be used for regional configuration or service routing.

```javascript
const region = navigator.region;
console.log('Region:', region);
```

#### `navigator.versions.ink`

- **Description**: Returns the current Ink runtime version. Useful for logging, troubleshooting, or compatibility checks.

```javascript
const inkVersion = navigator.versions.ink;
console.log('Ink:', inkVersion);
```

#### `navigator.versions.skia`

- **Description**: Returns the current Skia milestone string. Useful for runtime diagnostics related to graphics rendering.

```javascript
const skiaVersion = navigator.versions.skia;
console.log('Skia:', skiaVersion);
```

#### `navigator.bluetooth`

- **Description**: Bluetooth capability entry point. Availability depends on whether the host mounts this capability.

```javascript
const bluetooth = navigator.bluetooth;
console.log('Bluetooth mounted:', !!bluetooth);
```

#### `navigator.geolocation`

- **Description**: Geolocation capability entry point. Availability depends on whether the host mounts this capability.

```javascript
const geolocation = navigator.geolocation;
console.log('Geolocation mounted:', !!geolocation);
```

#### `navigator.mediaDevices`

- **Description**: Media-capture entry point with `getUserMedia()`, `enumerateDevices()`, and `getSupportedConstraints()`. See [Media Capture](/AIUI/api/media-media-capture).

#### `navigator.storage`

- **Description**: `StorageManager` entry point for the Agent-private OPFS. See [OPFS](/AIUI/api/storage-opfs).

### Methods

#### `navigator.getDeviceSerialNumber()`

- **Description**: Returns the serial number provided by the host for the current device, or an empty string `''` if unavailable.

```javascript
const serialNumber = navigator.getDeviceSerialNumber();
console.log('SN:', serialNumber);
```

#### `navigator.getBattery()`

- **Description**: Returns `Promise<BatteryManager>` for reading and observing host battery status. The Promise rejects when the host provides no battery capability.
- **Related documentation**: [BatteryManager](/AIUI/api/device-battery-manager).
