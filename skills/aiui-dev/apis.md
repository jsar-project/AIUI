# AIUI API Reference

This file only documents APIs that have been checked against the current implementation.

- The current detailed scope covers the currently verified Canvas, Bluetooth, sensor, media, AI, Web speech, `wx`, barcode, crypto, and selected browser-style networking and encoding APIs available to AIUI app code.
- Do not infer standard Web API behavior unless it is explicitly listed below or in the linked reference files.
- Do not add browser-compatible overloads or semantics that are not present in the source.

## Confirmed API Scope

The currently verified APIs are:

### Canvas runtime

- `Canvas`
- `CanvasRenderingContext2D`
- `ImageData`
- `CanvasGradient`
- `CanvasPattern`
- `Path2D`

### Barcode runtime

- `BarcodeDetector`

### Bluetooth runtime

- `navigator.bluetooth`
- `BluetoothScan`
- `DeviceFoundEvent`
- `BluetoothDevice`
- `BluetoothRemoteGATTServer`
- `BluetoothRemoteGATTService`
- `BluetoothRemoteGATTCharacteristic`
- `BluetoothCharacteristicProperties`

### Sensor runtime

- `Accelerometer`
- `AbsoluteOrientationSensor`
- `Gyroscope`

### wx module

- `default` export from `'wx'`
- `wx.arrayBufferToBase64(buffer)`
- `wx.exitMiniProgram(options?)`
- `wx.setBackgroundColor(options)`
- `wx.navigateTo(options)`
- `wx.redirectTo(options)`
- `wx.navigateBack(options?)`
- `wx.setStorage(options)`
- `wx.getStorage(options)`
- `wx.removeStorage(options)`
- `wx.clearStorage(options)`
- `wx.setStorageSync(key, data)`
- `wx.getStorageSync(key)`
- `wx.removeStorageSync(key)`
- `wx.clearStorageSync()`
- `wx.request(options)`
- `wx.createSocket(options)`
- `wx.connectSocket(options)`
- `wx.createEventSource(options)`

### wx speech runtime

- `wx.speech.playTTS(text)`
- `wx.speech.startRecognition()`

### wx media runtime

- `wx.media.getRecorderManager()`
- `wx.media.createCameraContext()`
- `RecorderManager`
- `CameraContext`

### Media runtime

- `AudioPlayer`
- `Sound`

### wx networking task runtime

- `RequestTask`
- `SocketTask`
- `EventSourceTask`

### Global Web networking and encoding runtime

- `fetch(url, options?)`
- `Headers`
- `Response`
- `ReadableStream`
- `TextDecoder`

### AI runtime

- `LanguageModel`
- `LanguageModelSession`
- `LanguageModelTextStream`

### Web speech runtime

- `speechSynthesis`
- `SpeechSynthesisUtterance`
- `SpeechAudioPlayer`
- `SpeechRecognition`

### Crypto runtime

- `crypto.randomUUID()`
- `crypto.subtle.digest(algorithm, data)`
- `crypto.subtle.importKey(format, keyData, algorithm, extractable, keyUsages)`
- `crypto.subtle.sign(algorithm, key, data)`
- `CryptoKey`

### wx canvas entry point

- `wx.createCanvasContext(canvasId)`

## Entry Points

### `wx` module

```javascript
import wx from 'wx';
```

### Script-owned canvas

```javascript
const canvas = new Canvas(300, 150);
const ctx = canvas.getContext('2d');
```

### Page `<canvas>` node

```javascript
import wx from 'wx';

const ctx = wx.createCanvasContext('chartCanvas');
```

### Barcode detector

Global constructor:

```javascript
const detector = new BarcodeDetector();
```

Module import:

```javascript
import BarcodeDetector, { BarcodeDetector as NamedBarcodeDetector } from 'barcode';

const detector = new BarcodeDetector();
const namedDetector = new NamedBarcodeDetector();
```

### Bluetooth

```javascript
const bluetooth = navigator.bluetooth;
```

### Sensors

```javascript
const accelerometer = new Accelerometer({ frequency: 60 });
const orientation = new AbsoluteOrientationSensor({ frequency: 60 });
const gyroscope = new Gyroscope({ frequency: 60 });
```

### AudioPlayer

```javascript
import { AudioPlayer } from 'audio';

const player = new AudioPlayer();
player.src = '/assets/intro.ogg';
```

### Sound

Global constructor:

```javascript
const click = new Sound('./click.wav');
```

Module import:

```javascript
import { Sound } from 'audio';
```

### Web networking and encoding

```javascript
const headers = new Headers([
  ['X-Test', 'one'],
  ['x-test', 'two'],
]);

const response = await fetch('https://example.com/stream', {
  headers,
});
const reader = response.body.getReader();
const decoder = new TextDecoder('utf-8');
```

### Language model

Global object:

```javascript
const status = await LanguageModel.availability();
const session = await LanguageModel.create({ model: 'gpt-4o-mini' });
```

Module import:

```javascript
import { LanguageModel } from 'language-model';
```

### Web speech

Global objects:

```javascript
const utterance = new SpeechSynthesisUtterance('Hello Ink');
speechSynthesis.speak(utterance, 'enqueue');

const generatedUtterance = new SpeechSynthesisUtterance('Generate this separately');
const task = await speechSynthesis.synthesize(generatedUtterance);
const player = new SpeechAudioPlayer(task);
player.play();

const recognition = new SpeechRecognition();
recognition.start();
```

Module import:

```javascript
import {
  speechSynthesis,
  SpeechSynthesisUtterance,
  SpeechAudioPlayer,
  SpeechRecognition,
} from 'speech';
```

Behavior notes:

- The `wx` module currently exports only `default`.
- `wx.createCanvasContext(canvasId)` looks up a `<canvas id="...">` node on the current page.
- If the page, node, or backing canvas cannot be found, it returns `null`.
- `canvas.getContext(type)` only accepts `'2d'`. Any other value returns `null`.
- The `barcode` module exports `BarcodeDetector` as both the default export and a named export.
- `navigator.bluetooth` is mounted by the runtime.
- `Accelerometer`, `AbsoluteOrientationSensor`, and `Gyroscope` are registered globally on `globalThis` and `window`.
- `AudioPlayer` and `Sound` are exported by `'audio'`.
- `Sound` is available globally and as a named export from `'audio'`.
- `Response.body` is exposed as a `ReadableStream` and supports `getReader()` for incremental consumption.
- For streamed text, prefer `TextDecoder.decode(value, { stream: true })` while reading chunks, followed by a final `decode()` flush.
- Current compatibility checks explicitly cover `Headers` case-insensitive lookup and duplicate value merging through `get()`.
- `LanguageModel` is mounted on `globalThis` and `window`, and is exported by `'language-model'`.
- `speechSynthesis`, `SpeechSynthesisUtterance`, `SpeechAudioPlayer`, and `SpeechRecognition` are registered globally and are exported by `'speech'`.
- Imported `CryptoKey` objects report `extractable` as `false`.

## Detailed References

- [Canvas and barcode APIs](./apis-canvas.md)
- [wx module and task APIs](./apis-wx.md)
- [Device and sensor APIs](./apis-device.md)
- [Media APIs](./apis-media.md)
- [Web networking and encoding APIs](./apis-web.md)
- [AI and speech APIs](./apis-ai.md)

## Authoring Rules For Agents

- Only generate API usage that is explicitly listed in this file or in the linked domain reference files.
- Treat these files as implementation truth, not Web platform truth.
- Do not assume browser overloads, browser objects, or browser return shapes unless they are explicitly documented in these files.
- Prefer `wx.createCanvasContext(id)` for page `<canvas>` drawing.
- Prefer `new Canvas(width, height)` only when you need a script-owned canvas instance.
- Prefer `fetch` when you need promise-based networking or streamed `response.body` consumption.
- Prefer `wx.request` when you need task-style callbacks, `RequestTask`, or compatibility with existing Mini Program request code.
