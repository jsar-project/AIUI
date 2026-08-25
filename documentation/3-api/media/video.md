# 视频播放

`wx.createVideoContext()` 用于从页面脚本控制已经渲染的 `<video>` 组件。组件负责展示媒体，`VideoContext` 负责播放、暂停、跳转和重新加载。

## 控制页面中的视频

先为组件设置稳定的 `id`：

```xml
<video
  id="briefing"
  src="https://example.com/briefing.mp4"
  controls
></video>
```

组件挂载后，再在当前页面创建 context：

```javascript
export default {
  onReady() {
    this.video = wx.createVideoContext('briefing');
    this.video?.play();
  },

  onUnload() {
    this.video = null;
  },
};
```

## 跳转或重新加载

```javascript
this.video?.pause();
this.video?.seek(12.5);
this.video?.play();

// 即使 src 未变化，也重新加载当前资源。
this.video?.load();
```

## 当前限制

- 查找范围是当前页面，使用 context 期间应保持对应 `<video>` 组件处于挂载状态。
- 当前支持 progressive MP4、H.264/AVC 视频以及可选 AAC 音频。
- 当前不支持 HLS、DASH、MSE、EME、DRM、字幕或多轨选择。
- 播放进度与异步错误由 `<video>` 组件事件上报，而不是由 `VideoContext` 返回 Promise。

## API Reference

### wx APIs

#### `wx.createVideoContext(videoId)`

| 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `videoId` | `string` | 是 | 当前页面中目标 `<video>` 组件的 `id`。 |

返回 `VideoContext | null`；没有匹配的已挂载组件时返回 `null`。

#### `VideoContext`

| 方法 | 返回值 | 说明 |
| --- | --- | --- |
| `load()` | `void` | 重新加载当前 `src`。 |
| `play()` | `void` | 开始或恢复播放。 |
| `pause()` | `void` | 暂停并保留当前位置。 |
| `stop()` | `void` | 停止播放并把位置重置为零。 |
| `seek(seconds)` | `void` | 跳转到指定的非负秒数。 |
