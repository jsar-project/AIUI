# 多媒体

AIUI 的多媒体能力覆盖音效播放、音频播放与设备媒体交互等场景。对于按钮点击、提示音这类本地短音效，通常可以先从 `Sound` 开始；对于拍照、相机交互或语音采集，则可以继续查看相机与录音相关文档。这里不展开所有接口细节，主要帮助你快速找到和音效、音频、录音、相机相关的具体文档。

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
- **[相机](/AIUI/api/media-camera)**：查看相机上下文创建方式以及页面中的相机交互入口。
- **[录音](/AIUI/api/media-recorder)**：查看录音管理器入口与录音流程管理方式。
- **[音频 (Audio)](/AIUI/api/media-audio)**：查看 Web 标准的音频相关接口。
- **[微信小程序兼容 API](/AIUI/api/weixin-compatible-apis)**：查看摄像头、录音等设备媒体接口。
