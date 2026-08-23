# Navigator

提供运行环境中的 `navigator` 相关能力，作为宿主标识、语言偏好、运行时版本与设备邻接能力的统一入口。

## 读取运行环境与语言信息

在启动时读取语言、区域和运行时版本，用于选择本地化配置并记录诊断信息：

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

## 适用场景

- 上报设备标识信息，便于设备管理和问题排查。
- 读取运行环境版本信息，用于日志记录或兼容性判断。
- 根据宿主语言与区域偏好选择默认文案、格式化策略或服务配置。
- 通过 `navigator.bluetooth`、`navigator.geolocation` 访问挂载到宿主上的设备能力。

## 注意事项

- `navigator.getDeviceSerialNumber()` 返回的是宿主提供的设备序列号，若宿主未实现则返回空字符串；使用时应注意隐私与数据安全。
- `navigator.userAgent` 适合用于识别运行时与平台信息，不建议依赖字符串解析实现强耦合逻辑。
- `navigator.language`、`navigator.languages` 与 `navigator.region` 都来自宿主环境，不同平台的具体值格式可能不同。
- `navigator.bluetooth` 与 `navigator.geolocation` 是否可用，取决于宿主是否挂载了对应能力。

## API Reference

### 属性

#### `navigator.userAgent`

- **说明**：返回当前运行时的 user-agent 字符串，宿主也可能在其中附加平台相关信息。

```javascript
const userAgent = navigator.userAgent;
console.log('UA:', userAgent);
```

#### `navigator.language`

- **说明**：返回宿主当前首选语言，通常用于选择默认文案或本地化策略。

```javascript
const language = navigator.language;
console.log('Language:', language);
```

#### `navigator.languages`

- **说明**：返回宿主语言偏好列表，按优先级排序，可用于更细粒度的多语言兜底。

```javascript
const languages = navigator.languages;
console.log('Languages:', languages);
```

#### `navigator.region`

- **说明**：返回宿主提供的区域信息，可用于地区化配置或服务分流。

```javascript
const region = navigator.region;
console.log('Region:', region);
```

#### `navigator.versions.ink`

- **说明**：返回当前 Ink 运行时版本，适合用于日志记录、问题排查或兼容性判断。

```javascript
const inkVersion = navigator.versions.ink;
console.log('Ink:', inkVersion);
```

#### `navigator.versions.skia`

- **说明**：返回当前 Skia milestone 版本字符串，可用于图形渲染相关的运行时排查。

```javascript
const skiaVersion = navigator.versions.skia;
console.log('Skia:', skiaVersion);
```

#### `navigator.bluetooth`

- **说明**：蓝牙能力入口。是否可用取决于宿主是否挂载了对应能力。

```javascript
const bluetooth = navigator.bluetooth;
console.log('Bluetooth mounted:', !!bluetooth);
```

#### `navigator.geolocation`

- **说明**：地理位置能力入口。是否可用取决于宿主是否挂载了对应能力。

```javascript
const geolocation = navigator.geolocation;
console.log('Geolocation mounted:', !!geolocation);
```

### 方法

#### `navigator.getDeviceSerialNumber()`

- **说明**：返回宿主提供的当前设备 SN 号；如果宿主未提供，则返回空字符串 `''`。

```javascript
const serialNumber = navigator.getDeviceSerialNumber();
console.log('SN:', serialNumber);
```
