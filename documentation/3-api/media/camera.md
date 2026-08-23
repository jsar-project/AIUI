# 相机

相机 API 用于在用户交互中拍摄照片，并以二进制数据返回拍摄结果。

## 拍摄照片

先获取相机上下文，再在点击等有效用户交互中调用 `takePhoto()`：

```javascript
const cameraContext = wx.media.createCameraContext();
if (!cameraContext) {
  throw new Error('当前环境不支持相机');
}

const image = await cameraContext.takePhoto({
  quality: 'high',
  enableSystemPreview: true,
});

console.log(image.mimeType, image.data.byteLength);
```

## 使用建议

- 在使用前检查 `cameraContext` 是否为 `undefined`。
- 仅在用户点击等交互回调内调用 `takePhoto()`。
- 使用 `data` 和 `mimeType` 自行处理、保存或上传图像数据。

相关能力可继续查看[录音](/AIUI/api/media-recorder)和[微信小程序兼容 API](/AIUI/api/weixin-compatible-apis)。

## API Reference

### `wx.media.createCameraContext()`

获取当前应用的相机上下文。应用配置 `lifetime: 'cut'` 或应用上下文不存在时返回 `undefined`。

**返回值：** `CameraContext | undefined`。

### `CameraContext.takePhoto(options)`

在有效用户交互中拍照。

| 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `options` | `object` | 是 | 拍照配置对象。 |
| `options.quality` | `'high' \| 'normal' \| 'low'` | 是 | 图像质量。 |
| `options.enableSystemPreview` | `boolean` | 否 | 是否先显示系统相机预览界面，默认为 `true`。 |

**返回值：** `Promise<{ data: ArrayBuffer, mimeType: string }>`。

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `data` | `ArrayBuffer` | 图像的完整二进制内容。 |
| `mimeType` | `string` | 图像 MIME 类型，例如 `image/jpeg`。 |

拍照失败时 Promise 拒绝；未传入 `options`、缺少 `quality` 或调用不在用户交互中时会抛出异常。
