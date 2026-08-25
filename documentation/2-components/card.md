# Card 卡片

`card` 将封面、标题、正文和页脚组合成卡片内容。封面、标题与页脚均可省略，标签体中的子节点作为正文显示。

## 展示带封面的内容卡片

```xml
<card cover="assets/cover.jpg" title="今日推荐" footer="刚刚更新">
  <text>这里是卡片正文。</text>
</card>
```

## 展示简洁信息卡片

```xml
<card title="设备状态">
  <text>运行正常</text>
</card>
```

## 属性

| 属性 | 类型 | 默认值 | 说明 |
| --- | --- | --- | --- |
| `cover` | String | - | 顶部封面图片的路径或 URL。 |
| `title` | String | - | 标题文字。 |
| `footer` | String | - | 底部辅助文字。 |

属性支持 WXML 数据绑定。可通过 `--card-cover-height`、`--card-padding`、`--card-title-*`、`--card-footer-*` 和 `--card-divider-*` 等 CSS 自定义属性调整内部样式。
