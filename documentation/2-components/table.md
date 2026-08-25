# Table 表格

`table` 根据列定义和行数据绘制结构化表格。

## 展示数据表格

```xml
<table
  caption="成绩"
  columns='[{"key":"name","title":"姓名"},{"key":"score","title":"分数","align":"right"}]'
  rows='[{"name":"Alice","score":98},{"name":"Bob","score":87}]'
  empty-text="暂无数据"
></table>
```

## 属性

| 属性 | 类型 | 默认值 | 说明 |
| --- | --- | --- | --- |
| `columns` | JSON Array | `[]` | 列定义；每项包含 `key`，并可设置 `title` 和 `align`。 |
| `rows` | JSON Array | `[]` | 行对象数组，按列的 `key` 读取单元格。 |
| `caption` | String | - | 表格标题。 |
| `empty-text` | String | - | 没有数据行时显示的文本；别名为 `emptyText`。 |

`align` 支持 `left`、`center` 和 `right`。数组或对象单元格会序列化为 JSON 文本，非对象行会被忽略。
