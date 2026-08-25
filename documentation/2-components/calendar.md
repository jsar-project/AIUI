# Calendar 日历

`calendar` 用于展示月历或周历，并可将 iCalendar 数据解析为日期标注。当前组件只负责展示，不提供日期选择事件。

## 展示月历

```xml
<calendar value="2026-05-02" today="2026-05-01" locale="zh-CN" weekStart="monday"></calendar>
```

## 展示指定日期所在周

```xml
<calendar mode="week" displayDate="2026-05-02" locale="zh-CN"></calendar>
```

## 标注日程

```xml
<calendar value="2026-05-02" eventSource="{{calendarData}}"></calendar>
```

`eventSource` 接收原始 iCalendar 文本，用于生成节日、工作日和日程标注。

## 属性

| 属性 | 类型 | 默认值 | 说明 |
| --- | --- | --- | --- |
| `mode` | String | `month` | 显示模式：`month` 或 `week`。 |
| `value` | String | - | ISO 日期格式的选中日期。 |
| `displayDate` | String | - | ISO 日期格式的可见区域锚点；未设置时使用 `value`。 |
| `today` | String | 当前日期 | 指定被视为“今天”的 ISO 日期。 |
| `locale` | String | `en` | 支持 `zh`、`zh-CN`、`en`、`en-US`。 |
| `weekStart` | String | `monday` | 一周起始日；支持 `0`/`sun`/`sunday` 与 `1`/`mon`/`monday`。 |
| `eventSource` | String | - | 原始 iCalendar 文本。 |
