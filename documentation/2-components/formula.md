# Formula 公式

`formula` 使用 TeX 风格源码显示行内或块级数学公式。

## 在文本中插入公式

```xml
<p>能量关系为 <formula>E = mc^2</formula>。</p>
```

## 独立显示公式

```xml
<formula style="display: block;">\frac{a + b}{2}</formula>
```

位于 `p`、`header`、`blockquote` 或 `list-item` 中时按行内公式处理；其他位置按块级公式处理。无法生成公式图像时会显示源码文本。
