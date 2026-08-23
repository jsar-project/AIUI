# 音效 (Sound)

`Sound` 是面向本地短音效的专用播放入口，适合按钮点击、提示音、状态反馈音等需要频繁重播的场景。

相比通用的 `AudioPlayer`，`Sound` 的能力面更窄，但调用更直接，适合“拿来即播”的本地音效资源。

## 播放一段音效

```javascript
import { Sound } from 'audio';

const click = new Sound('/assets/click.wav');
click.volume = 0.8;
click.play();
```

## 行为说明

- `Sound` 仅用于本地音效文件。
- 本地音效路径支持相对路径和相对于项目根目录解析的绝对路径。
- `Sound` 不支持修改 `src`、跳转播放位置、流式追加数据或事件监听。
- 调用 `destroy()` 后，再次调用实例方法会抛出错误。

## 适用场景

- 需要一个更轻量的本地音效播放接口时，优先使用 `Sound`。
- 需要更完整的播放控制能力时，使用 [音频播放器 (AudioPlayer)](/AIUI/api/media-audio-player)。
- 录音、摄像头等设备媒体能力可继续参考[微信小程序兼容 API](/AIUI/api/weixin-compatible-apis)。

## API Reference

### 入口

`Sound` 可以直接全局使用，也可以从内置的 `audio` 模块中导入：

```javascript
const click = new Sound('./click.wav');
```

```javascript
import { Sound } from 'audio';
```

### 构造函数

```javascript
new Sound(src)
```

- `src`：音效文件的本地路径，必须是非空字符串。既支持相对路径，也支持相对于项目根目录解析的绝对路径，例如 `/assets/click.wav`。
- 仅支持本地文件，不支持 `http://` 或 `https://` 这类远程 URL。
- 音源会在构造时绑定，便于后续快速重播。

### 属性

#### `volume`
- **类型**：`number`
- **读写**：可读可写
- **说明**：控制当前音效实例的播放音量。

### 方法

#### `play()`
- **说明**：如果当前实例正在播放，会先停止当前播放，再从开头重新开始。

#### `stop()`
- **说明**：停止当前音效播放。

#### `destroy()`
- **说明**：释放底层播放器资源。调用后该实例不可继续使用。
