# TimedText 定时文本

`timed-text` 在完整文本中突出一个活动片段，适合显示与音频进度同步的字幕。

## 突出当前字幕片段

```xml
<timed-text text="欢迎使用 AIUI" active-start="2" active-length="2"></timed-text>
```

## 属性

| 属性 | 类型 | 默认值 | 说明 |
| --- | --- | --- | --- |
| `text` | String | `""` | 完整文本。 |
| `active-start` | Number | `0` | 活动片段的 UTF-16 起始偏移。 |
| `active-length` | Number | `0` | 活动片段的 UTF-16 长度。 |

普通文本颜色使用 `--timed-text-color`，默认是当前文字颜色的 45% 透明度；活动片段使用 `--timed-text-active-color`，默认继承文字颜色。
