# AIUI API Reference

This file only documents APIs that have been checked against the current implementation.

- The current detailed scope covers the currently verified Canvas, `wx`, and barcode APIs available to AIUI app code.
- Do not infer standard Web API behavior unless it is explicitly listed below.
- Do not add browser-compatible overloads or semantics that are not present in the source.

## 1. Confirmed API Scope

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

### wx networking task runtime

- `RequestTask`
- `SocketTask`
- `EventSourceTask`

### wx canvas entry point

- `wx.createCanvasContext(canvasId)`

## 2. Entry Points

### 2.1 `wx` module

```javascript
import wx from 'wx';
```

### 2.2 Script-owned canvas

```javascript
const canvas = new Canvas(300, 150);
const ctx = canvas.getContext('2d');
```

### 2.3 Page `<canvas>` node

```javascript
import wx from 'wx';

const ctx = wx.createCanvasContext('chartCanvas');
```

### 2.4 Barcode detector

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

Behavior notes:

- The `wx` module currently exports only `default`.
- `wx.createCanvasContext(canvasId)` looks up a `<canvas id="...">` node on the current page.
- If the page, node, or backing canvas cannot be found, it returns `null`.
- `canvas.getContext(type)` only accepts `'2d'`. Any other value returns `null`.
- The `barcode` module exports `BarcodeDetector` as both the default export and a named export.

## 3. `CanvasRenderingContext2D`

`CanvasRenderingContext2D` cannot be constructed directly. Its constructor panics if called directly. Always obtain it from `canvas.getContext('2d')` or `wx.createCanvasContext(id)`.

### Properties

#### Style properties

- `fillStyle`
- `strokeStyle`

Getter behavior:

- Returns either a color string, a `CanvasGradient`, or a `CanvasPattern`.

Setter behavior:

- Accepts a color string.
- Accepts a `CanvasGradient`.
- Accepts a `CanvasPattern`.
- Unsupported values are ignored.

Color strings are only parsed in these forms:

- `#rrggbb`
- `#rgb`
- `rgb(r, g, b)`
- `rgba(r, g, b, a)`
- `black`
- `white`
- `red`
- `green`
- `blue`
- `yellow`
- `transparent`

#### Line and shadow properties

- `lineWidth`
- `lineCap`
- `lineJoin`
- `lineDashOffset`
- `shadowBlur`
- `shadowColor`
- `shadowOffsetX`
- `shadowOffsetY`
- `globalAlpha`
- `globalCompositeOperation`

Value behavior:

- `lineCap` supports `butt`, `round`, `square`; unknown values fall back to `butt`.
- `lineJoin` supports `miter`, `round`, `bevel`; unknown values fall back to `miter`.
- `shadowColor` uses the same limited color parsing as `fillStyle`.
- `globalCompositeOperation` supports only the values mapped in the implementation:
  - `source-over`
  - `source-in`
  - `source-out`
  - `source-atop`
  - `copy`
  - `destination-over`
  - `destination-in`
  - `destination-out`
  - `destination-atop`
  - `xor`
  - `lighter`
  - `multiply`
  - `screen`
  - `overlay`
  - `darken`
  - `lighten`
  - `color-dodge`
  - `color-burn`
  - `hard-light`
  - `soft-light`
  - `difference`
  - `exclusion`
  - `hue`
  - `saturation`
  - `color`
  - `luminosity`
- Unknown `globalCompositeOperation` values fall back to `source-over`.

#### Text properties

- `font`
- `textAlign`
- `textBaseline`

Value behavior:

- `textAlign` supports `left`, `center`, `right`, `start`, `end`; unknown values fall back to `start`.
- `textBaseline` supports `top`, `hanging`, `middle`, `alphabetic`, `ideographic`, `bottom`; unknown values fall back to `alphabetic`.

### Methods

#### Rect and basic drawing

- `fillRect(x, y, width, height)`
- `strokeRect(x, y, width, height)`
- `clearRect(x, y, width, height)`

#### Path construction

- `beginPath()`
- `moveTo(x, y)`
- `lineTo(x, y)`
- `arc(x, y, radius, startAngle, endAngle, anticlockwise?)`
- `rect(x, y, width, height)`
- `ellipse(x, y, radiusX, radiusY, rotation, startAngle, endAngle, anticlockwise?)`
- `arcTo(x1, y1, x2, y2, radius)`
- `bezierCurveTo(cp1x, cp1y, cp2x, cp2y, x, y)`
- `quadraticCurveTo(cpx, cpy, x, y)`
- `closePath()`
- `roundRect(x, y, width, height, ...radii)`

Argument behavior:

- `arc()` and `ellipse()` use `false` when `anticlockwise` is omitted.
- `roundRect()` accepts a variadic radii list.

#### Path painting and clipping

- `clip(...args)`
- `fill(...args)`
- `stroke(...args)`

Argument behavior:

- `clip()` accepts either:
  - `clip()`
  - `clip(fillRule)`
  - `clip(path)`
  - `clip(path, fillRule)`
- `fill()` accepts either:
  - `fill()`
  - `fill(fillRule)`
  - `fill(path)`
  - `fill(path, fillRule)`
- `stroke()` accepts either:
  - `stroke()`
  - `stroke(path)`
- Supported `fillRule` strings are only `nonzero` and `evenodd`.

#### Text

- `measureText(text)`
- `fillText(text, x, y, maxWidth?)`
- `strokeText(text, x, y, maxWidth?)`

Return behavior:

- `measureText(text)` returns an object with only one confirmed field: `width`.

#### State and transform

- `save()`
- `restore()`
- `translate(dx, dy)`
- `rotate(angle)`
- `scale(sx, sy)`
- `transform(a, b, c, d, e, f)`
- `setTransform(...args)`
- `resetTransform()`
- `getTransform()`

Behavior notes:

- `rotate(angle)` expects radians.
- `transform(a, b, c, d, e, f)` always takes six numeric arguments.
- `setTransform(...args)` delegates to the DOM matrix argument parser used by the runtime. Do not assume browser-complete overload coverage beyond what the parser accepts.
- `getTransform()` returns a `DOMMatrixReadOnly` object.

#### Line dash

- `setLineDash(dashArray)`
- `getLineDash()`

#### Hit testing

- `isPointInPath(...args)`
- `isPointInStroke(...args)`

Argument behavior:

- `isPointInPath()` accepts either:
  - `isPointInPath(x, y)`
  - `isPointInPath(x, y, fillRule)`
  - `isPointInPath(path, x, y)`
  - `isPointInPath(path, x, y, fillRule)`
- `isPointInStroke()` accepts either:
  - `isPointInStroke(x, y)`
  - `isPointInStroke(path, x, y)`
- If fewer than the required coordinate arguments are provided, the runtime throws.

#### Image data

- `createImageData(width, height)`
- `getImageData(x, y, width, height)`
- `putImageData(imageData, x, y)`

#### Gradients and patterns

- `createLinearGradient(x0, y0, x1, y1)`
- `createRadialGradient(x0, y0, r0, x1, y1, r1)`
- `createPattern(image, repetition)`

Behavior notes:

- `createPattern(image, repetition)` currently ignores the incoming JavaScript image value and creates the pattern from an internal 1x1 surface.

#### Image drawing

- `drawImage(image, dx, dy)`
- `drawImage(image, dx, dy, dw, dh)`
- `drawImage(image, sx, sy, sw, sh, dx, dy, dw, dh)`

Behavior notes:

- `drawImage()` only recognizes another `Canvas` instance as the source image.
- If the first argument is not a `Canvas`, the call returns without drawing.
- Only the 3-argument, 5-argument, and 9-argument forms are implemented.

#### Flush

- `flush()`

### Dirty-mark behavior

When the context is bound to a page canvas node through `wx.createCanvasContext(id)`, these methods mark the page node dirty:

- `fillRect`
- `strokeRect`
- `clearRect`
- `arc`
- `rect`
- `ellipse`
- `arcTo`
- `bezierCurveTo`
- `quadraticCurveTo`
- `fill`
- `stroke`
- `fillText`
- `strokeText`
- `flush`
- `drawImage`
- `putImageData`

## 4. `CanvasGradient`

### Methods

- `addColorStop(offset, color)`

### Behavior

- `color` uses the same limited parser as `fillStyle`.
- If the color string cannot be parsed, the call does nothing.

## 5. `CanvasPattern`

### Methods

- `setTransform(matrix)`

### Behavior

- The runtime attempts to parse `matrix` as a DOM matrix object.
- If parsing fails, it falls back to the default transform.

## 6. `ImageData`

### Constructor

- `new ImageData(width, height)`

### Properties

- `width`
- `height`
- `data`

### Behavior

- `data` is exposed as a typed byte array.
- The buffer length is initialized to `width * height * 4`.

## 7. `Path2D`

### Constructor

- `new Path2D()`
- `new Path2D(path)`
- `new Path2D(svgPathString)`

### Methods

- `moveTo(x, y)`
- `lineTo(x, y)`
- `rect(x, y, width, height)`
- `roundRect(x, y, width, height, ...radii)`
- `closePath()`
- `arc(x, y, radius, startAngle, endAngle, anticlockwise?)`
- `arcTo(x1, y1, x2, y2, radius)`
- `bezierCurveTo(cp1x, cp1y, cp2x, cp2y, x, y)`
- `quadraticCurveTo(cpx, cpy, x, y)`
- `ellipse(x, y, radiusX, radiusY, rotation, startAngle, endAngle, anticlockwise?)`
- `addPath(path, transform?)`
- `toString()`

### Behavior

- `new Path2D(path)` clones another `Path2D`.
- `new Path2D(svgPathString)` parses SVG path data. Parse failure throws.
- Passing any other constructor value throws.
- `arc()` and `ellipse()` use `false` when `anticlockwise` is omitted.
- `addPath(path, transform?)` requires the first argument to be a `Path2D`.
- `addPath(path, transform?)` throws when `transform` is present but is not an accepted DOM matrix object.
- `toString()` returns SVG path data.

## 8. `wx`

### Module export

- `import wx from 'wx'`

Behavior notes:

- The `wx` module currently declares and exports only `default`.

### Base methods

- `wx.arrayBufferToBase64(buffer)`

Behavior notes:

- `arrayBufferToBase64(buffer)` returns a base64 string.

Error behavior:

- `arrayBufferToBase64(buffer)` throws if the `ArrayBuffer` is detached.

### System methods

- `wx.exitMiniProgram(options?)`

Behavior notes:

- `exitMiniProgram(options?)` calls `success()` and `complete()` when present, then sends the app exit event.

### UI methods

- `wx.setBackgroundColor(options)`

Behavior notes:

- `setBackgroundColor(options)` reads these option fields when present:
  - `backgroundColor`
  - `backgroundColorTop`
  - `backgroundColorBottom`
- `setBackgroundColor(options)` calls `success()` when present.
- `setBackgroundColor(options)` calls `complete()` when present.
- The current implementation does not expose a `fail()` path.

### Router methods

- `wx.navigateTo(options)`
- `wx.redirectTo(options)`
- `wx.navigateBack(options?)`

Argument behavior:

- `navigateTo(options)` requires `options.url`.
- `redirectTo(options)` requires `options.url`.
- `navigateBack(options?)` uses `delta = 1` when omitted.

Behavior notes:

- `navigateTo(options)` requests page navigation.
- `redirectTo(options)` requests page redirection.
- `navigateBack(options?)` requests backward navigation.
- These methods call `success()` and `complete()` when present.

### Storage methods

#### Async methods

- `wx.setStorage(options)`
- `wx.getStorage(options)`
- `wx.removeStorage(options)`
- `wx.clearStorage(options)`

Argument behavior:

- `setStorage(options)` requires `key` and `data`.
- `getStorage(options)` requires `key`.
- `removeStorage(options)` requires `key`.
- All async storage methods optionally accept `success`, `fail`, and `complete`.

Behavior notes:

- Async storage methods require storage support in the current context. If it is unavailable, the call throws.
- `setStorage(options)` serializes `data` through JSON before storing it.
- `getStorage(options)` calls `success({ data })` when the key exists.
- `getStorage(options)` calls `fail({ errMsg: 'Key not found' })` when the key does not exist.
- `removeStorage(options)` and `clearStorage(options)` call `success()` on success.
- On storage errors, async methods call `fail({ errMsg })` when `fail` is present.
- Async storage methods call `complete()` after the success or fail path when `complete` is present.

#### Sync methods

- `wx.setStorageSync(key, data)`
- `wx.getStorageSync(key)`
- `wx.removeStorageSync(key)`
- `wx.clearStorageSync()`

Behavior notes:

- `setStorageSync(key, data)` serializes `data` through JSON before storing it.
- `getStorageSync(key)` returns the parsed stored value when the key exists.
- `getStorageSync(key)` returns `undefined` when the key does not exist.

Error behavior:

- Sync storage methods throw when storage support is unavailable in the current context.
- `setStorageSync(key, data)` throws when JSON serialization or storage write fails.
- `getStorageSync(key)` throws when the stored JSON cannot be parsed.
- `removeStorageSync(key)` throws on storage removal failure.
- `clearStorageSync()` throws on storage clear failure.

### Networking factory methods

- `wx.request(options)`
- `wx.createSocket(options)`
- `wx.connectSocket(options)`
- `wx.createEventSource(options)`

Return behavior:

- `wx.request(options)` returns a `RequestTask`.
- `wx.createSocket(options)` returns a `SocketTask`.
- `wx.connectSocket(options)` returns a `SocketTask`.
- `wx.createEventSource(options)` returns an `EventSourceTask`.

Behavior notes:

- `request(options)` uses `GET` when `method` is omitted.
- `request(options)` uses `'arraybuffer'` when `responseType` is omitted.
- `request(options)` resolves timeout in this order: `options.timeout`, app config timeout, then `60000`.
- `request(options)` accepts request data from `data` or fallback `body`.
- When `data` is an object and `content-type` contains `application/x-www-form-urlencoded`, the body is URL-encoded.
- Otherwise object `data` is serialized with `JSON.stringify`.
- `createEventSource(options)` uses the same request body construction rules as `request(options)`.

Callback behavior:

- `request(options)` supports `success`, `fail`, and `complete`.
- `success(res)` receives an object with these confirmed fields:
  - `data`
  - `statusCode`
  - `header`
  - `cookies`
  - `errMsg`
- When `responseType` is `'arraybuffer'`, `res.data` is an `ArrayBuffer`.
- Otherwise `res.data` is decoded text, except when `dataType` is `'json'` and parsing succeeds, in which case `res.data` is the parsed value.
- `fail(err)` receives an object with `errMsg`.
- `complete(result)` receives the same success object shape on success, or an object with `errMsg` on failure.

## 9. `wx.speech`

### Methods

- `wx.speech.playTTS(text)`
- `wx.speech.startRecognition()`

Return behavior:

- `playTTS(text)` returns a string.
- `startRecognition()` returns a string.

Behavior notes:

- `playTTS(text)` forwards the request to the speech subsystem.
- If `playTTS(text)` cannot create the utterance request, it returns an empty string.

Error behavior:

- `startRecognition()` requires an interactive call site and throws when the interaction gate check fails.

## 10. `wx.media`

### Methods

- `wx.media.getRecorderManager()`
- `wx.media.createCameraContext()`

Return behavior:

- `getRecorderManager()` returns a `RecorderManager` instance or `undefined`.
- `createCameraContext()` returns a `CameraContext` instance or `undefined`.

Behavior notes:

- These methods return `undefined` when the current context does not provide the required media capability.
- These methods may return `undefined` in unsupported app lifecycle modes.
- `getRecorderManager()` also returns `undefined` when recording capability is unavailable.

## 11. `RequestTask`

### Methods

- `abort()`
- `onHeadersReceived(callback)`
- `offHeadersReceived(callback?)`
- `onChunkReceived(callback)`
- `offChunkReceived(callback?)`

Behavior notes:

- `onHeadersReceived(callback)` passes a plain object containing response headers.
- `offHeadersReceived(callback?)` clears this event type's callbacks. The callback argument is accepted but not used.
- `onChunkReceived(callback)` passes an `ArrayBuffer`.
- `offChunkReceived(callback?)` clears this event type's callbacks. The callback argument is accepted but not used.

## 12. `SocketTask`

### Methods

- `send(data)`
- `close()`
- `onOpen(callback)`
- `onClose(callback)`
- `onError(callback)`
- `onMessage(callback)`

Argument behavior:

- `send(data)` accepts:
  - a string
  - an `ArrayBuffer`
  - a `Uint8Array`

Behavior notes:

- `onOpen(callback)` and `onClose(callback)` call the callback with no payload.
- `onError(callback)` passes an exception object created from the underlying error message.
- `onMessage(callback)` passes either a string or an `ArrayBuffer`.

Error behavior:

- `send(data)` throws a `TypeError` when `data` is not a string, `ArrayBuffer`, or `Uint8Array`.

## 13. `EventSourceTask`

### Methods

- `close()`
- `onOpen(callback)`
- `onMessage(callback)`
- `onError(callback)`

Behavior notes:

- `onOpen(callback)` calls the callback with no payload.
- `onMessage(callback)` passes an object with these confirmed fields:
  - `data`
  - `event`
  - `id`
- `onError(callback)` passes an object with `errMsg`.

## 14. `RecorderManager`

### Constructor

`RecorderManager` cannot be constructed directly.

### Methods

- `start(options)`
- `pause()`
- `resume()`
- `stop()`
- `onStart(callback)`
- `onResume(callback)`
- `onPause(callback)`
- `onStop(callback)`
- `onHeader(callback)`
- `onFrameRecorded(callback)`
- `onError(callback)`
- `onInterruptionBegin(callback)`
- `onInterruptionEnd(callback)`

Return behavior:

- `start(options)` returns a `Promise`.
- `pause()` returns a `Promise`.
- `resume()` returns a `Promise`.
- `stop()` returns a `Promise`.

Behavior notes:

- `start(options)` requires an interactive call site.
- `onStart(callback)`, `onResume(callback)`, `onPause(callback)`, `onInterruptionBegin(callback)`, and `onInterruptionEnd(callback)` call the callback with no payload.
- `onStop(callback)` passes an object with `tempFilePath`.
- `onHeader(callback)` passes two positional arguments: `format` and `buffer`.
- `onFrameRecorded(callback)` passes an object with `frameBuffer`.
- `onError(callback)` passes an object with `errMsg`.

Error behavior:

- `start(options)` throws when the interaction gate check fails.
- `pause()`, `resume()`, and `stop()` reject with a generic error when the operation fails.

## 15. `CameraContext`

### Constructor

`CameraContext` cannot be constructed directly.

### Methods

- `takePhoto(options)`

Return behavior:

- `takePhoto(options)` returns a `Promise`.
- The promise resolves to an object with these confirmed fields:
  - `data`
  - `mimeType`
- `data` is returned as an `ArrayBuffer`.

Behavior notes:

- `takePhoto(options)` requires an interactive call site.
- Do not assume browser or WeChat-compatible option coverage beyond what is explicitly documented here.

Error behavior:

- `takePhoto(options)` throws when the interaction gate check fails.
- If the operation fails, the promise rejects with a generic exception.

## 16. `BarcodeDetector`

### Constructor

- `new BarcodeDetector()`
- `new BarcodeDetector(options)`

### Constructor options

- `formats`

Behavior notes:

- `options` is optional.
- If `options.formats` is present and is readable as `Vec<String>`, each string is parsed as a barcode format name.
- Unrecognized format strings are ignored.
- If `options` is omitted, or `formats` is missing or unreadable, the detector is created with an empty format list.

### Static methods

- `BarcodeDetector.getSupportedFormats()`

Return behavior:

- `getSupportedFormats()` returns a `Promise`.
- The promise resolves to an array of strings.

### Instance methods

- `detect(image)`

Argument behavior:

- `image` must be an object.
- `image.width` is required.
- `image.height` is required.
- `image.data` is required.
- `image.data` is accepted only when it can be read as an `ArrayBuffer` or a byte typed array.

Return behavior:

- `detect(image)` returns a `Promise`.
- When `image.data` is readable, the promise resolves to an array of result objects.
- Each result object currently has these confirmed fields:
  - `format`
  - `rawValue`
- When `image.data` cannot be read as supported binary data, the promise resolves to an empty array.

Error behavior:

- `detect(image)` throws if `image` is not an object.
- `detect(image)` throws if `data`, `width`, or `height` is missing.

## 17. Authoring Rules For Agents

- Only generate API usage that is explicitly listed in this file.
- Treat this file as implementation truth, not Web platform truth.
- Do not assume browser overloads, browser objects, or browser return shapes unless they are explicitly documented here.
- Prefer `wx.createCanvasContext(id)` for page `<canvas>` drawing.
- Prefer `new Canvas(width, height)` only when you need a script-owned canvas instance.
