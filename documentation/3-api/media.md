# 多媒体

AIUI 的多媒体能力覆盖音效播放、音频播放、媒体采集与视频播放等场景。对于按钮点击、提示音这类本地短音效，通常可以先从 `Sound` 开始；对于拍照、录音或录像，则查看统一的媒体采集文档。

## 简单示例

例如，播放一个按钮点击音效：

```javascript
const click = new Sound('./click.wav');
click.volume = 0.8;
click.play();
```

## 继续阅读

- **[音效 (Sound)](/AIUI/api/media-sound)**：查看面向本地短音效的轻量播放接口，适合按钮点击、提示音等高频重播场景。
- **[音频播放器 (AudioPlayer)](/AIUI/api/media-audio-player)**：查看 AIUI 推荐的音频播放能力，适合本地音频与流式音频场景。
- **[媒体采集](/AIUI/api/media-media-capture)**：查看 `navigator.mediaDevices`、`ImageCapture`、`MediaRecorder` 以及 wx 风格的相机和录音接口。
- **[视频播放](/AIUI/api/media-video)**：查看 `<video>` 组件与 `VideoContext` 播放控制接口。
- **[音频 (Audio)](/AIUI/api/media-audio)**：查看 Web 标准的音频相关接口。
- **[微信小程序兼容 API](/AIUI/api/weixin-compatible-apis)**：查看摄像头、录音等设备媒体接口。
