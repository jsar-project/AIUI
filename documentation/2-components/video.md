# Video 视频

`video` 用于播放视频资源，并根据页面和视口可见性自动暂停或恢复播放。

## 播放视频

```xml
<video
  id="preview"
  src="https://example.com/video.mp4"
  poster="assets/poster.jpg"
  autoplay="true"
  object-fit="contain"
  bindtimeupdate="handleTimeUpdate"
  bindended="handleEnded"
></video>
```

## 属性

| 属性 | 类型 | 默认值 | 说明 |
| --- | --- | --- | --- |
| `src` | String | `""` | 视频资源地址。 |
| `poster` | String | `""` | 视频画面可用前显示的图片。 |
| `autoplay` | Boolean | `false` | 是否自动播放。 |
| `loop` | Boolean | `false` | 是否循环播放。 |
| `muted` | Boolean | `false` | 是否静音。 |
| `volume` | Number | `1` | 音量，限制在 `0` 至 `1`。 |
| `playback-rate` | Number | `1` | 播放速率。 |
| `start-time` | Number | `0` | 初始播放位置，单位为秒。 |
| `preload` | String | `metadata` | 预加载策略：`none`、`metadata` 或 `auto`。 |
| `object-fit` | String | `contain` | 画面填充方式：`contain`、`cover` 或 `fill`。 |
| `render-mode` | String | `normal` | 设置为 `wireframe` 时启用线框预览。 |

线框模式还支持 `wireframe-threshold`、`wireframe-thickness`、`wireframe-invert` 和 `wireframe-quality`。

## 事件

通过 `bind<event>` 或 `catch<event>` 监听 `loadstart`、`loadedmetadata`、`canplay`、`play`、`playing`、`pause`、`waiting`、`stalled`、`seeking`、`seeked`、`timeupdate`、`ended`、`volumechange`、`ratechange` 和 `error`。`timeupdate` 返回 `{ currentTime }`，`error` 返回 `{ message }`。
