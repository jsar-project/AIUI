# Camera

The camera API captures a photo during a user interaction and returns the result as binary data.

## Take a Photo

Get the camera context, then call `takePhoto()` from a valid interaction such as a click:

```javascript
const cameraContext = wx.media.createCameraContext();
if (!cameraContext) {
  throw new Error('Camera is unavailable in this environment');
}

const image = await cameraContext.takePhoto({
  quality: 'high',
  enableSystemPreview: true,
});

console.log(image.mimeType, image.data.byteLength);
```

## Recommendations

- Check whether `cameraContext` is `undefined` before using it.
- Call `takePhoto()` only from a user interaction callback such as a click handler.
- Use `data` and `mimeType` to process, store, or upload the image.

See [Recorder](/AIUI/api/media-recorder) and [WeChat Mini Program Compatible APIs](/AIUI/api/weixin-compatible-apis) for related capabilities.

## API Reference

### `wx.media.createCameraContext()`

Gets the camera context for the current app. It returns `undefined` when the app uses `lifetime: 'cut'` or no app context exists.

**Returns:** `CameraContext | undefined`.

### `CameraContext.takePhoto(options)`

Takes a photo during a valid user interaction.

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| `options` | `object` | Yes | Photo capture options. |
| `options.quality` | `'high' \| 'normal' \| 'low'` | Yes | Image quality. |
| `options.enableSystemPreview` | `boolean` | No | Whether to show the system camera preview before capture. Defaults to `true`. |

**Returns:** `Promise<{ data: ArrayBuffer, mimeType: string }>`.

| Field | Type | Description |
| --- | --- | --- |
| `data` | `ArrayBuffer` | Complete binary image data. |
| `mimeType` | `string` | Image MIME type, for example `image/jpeg`. |

The Promise rejects when capture fails. Missing `options`, a missing `quality`, or calling outside a user interaction throws an exception.
