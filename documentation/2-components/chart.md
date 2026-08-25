# Chart 数据可视化

`chart` 组件用于渲染折线图、面积图、柱状图、散点图、饼图、雷达图和漏斗图，并支持通过模板动态绑定数据。

## 使用方法

```xml
<chart
  type="line"
  series="value"
  data="{{chartData}}"
  width="350"
  height="150"
  animate="true"
  color="#007AFF"
  smooth="true"
  show-average="true"
></chart>
```

```javascript
Page({
  data: {
    chartData: [
      { label: '周一', value: 120 },
      { label: '周二', value: 168 },
      { label: '周三', value: 142 },
      { label: '周四', value: 196 },
      { label: '周五', value: 210 }
    ]
  }
});
```

## 数据格式

`data` 属性接收一个数组，每一项表示一个数据点。通常建议每个数据项至少包含：

- 一个用于描述类别或维度的字段，例如 `label`。
- 一个用于表示数值的字段，并通过 `series` 指定该字段名称，例如 `value`。

例如：

```javascript
const chartData = [
  { label: '语音', value: 72 },
  { label: '视觉', value: 86 },
  { label: '交互', value: 64 }
];
```

当组件设置为 `series="value"` 时，图表会读取每个数据项中的 `value` 字段作为绘制数值。

## 属性

| 属性 | 类型 | 描述 | 默认值 |
| :--- | :--- | :--- | :--- |
| `type` | String | 图表类型：`line`、`area`、`bar`、`scatter`、`pie`、`radar` 或 `funnel`。 | `line` |
| `series` | String | 数据对象中用于表示数值的键名。 | `value` |
| `data` | Array | 要渲染的数据点数组。 | `[]` |
| `width` | Number | 图表的像素宽度。 | `300` |
| `height` | Number | 图表的像素高度。 | `150` |
| `animate` | Boolean | 是否在首次渲染和数据更新时启用动画。 | `false` |
| `color` | String | 图表的主题色（Hex, RGB 或颜色名称）。 | `#00FF7F` |
| `show-average` | Boolean | 是否显示代表平均值的虚线（仅适用于折线图/面积图）。 | `false` |
| `smooth` | Boolean | 是否使用平滑曲线代替直线（仅适用于折线图/面积图）。 | `true` |

## 图表类型

### line

折线图适合展示一段时间内或一组连续维度上的变化趋势，例如日活、响应时长或任务完成量。

### area

面积图适合在趋势基础上进一步强调数值规模，常用于展示累计效果或整体波动范围。

### bar

柱状图适合比较不同类别，也支持水平和垂直方向。

### scatter

散点图适合观察两个连续变量之间的分布关系。

### pie

饼图适合展示各部分在整体中的占比关系，例如流量来源分布或功能使用占比。

### radar

雷达图适合展示多维指标的横向对比，例如多个能力维度的评估结果。

### funnel

漏斗图适合展示流程中各阶段的数量与转化关系。

## 功能特性

- 支持通过模板绑定数据源和数值字段。
- 支持在首次渲染或数据更新时启用动画效果。
- 支持使用 `color` 自定义图表主题色。
- 支持在折线图和面积图中启用平滑曲线与平均值辅助线。
- 支持通过 `width` 和 `height` 控制图表尺寸。

## 使用建议

- 如果你要展示趋势变化，优先选择 `line` 或 `area`。
- 如果你要突出各项占比，优先选择 `pie`。
- 如果你要比较多个能力维度，优先选择 `radar`。
- 在尺寸较小的图表区域中，建议控制数据点数量，避免视觉过于拥挤。
- 建议让 `width`、`height` 与页面布局保持一致，避免图表内容被压缩或留白过多。
