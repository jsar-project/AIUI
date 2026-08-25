# Snippet 代码片段

`snippet` 用于显示行内代码或块级代码。

## 显示行内代码

```xml
<p>调用 <snippet>start()</snippet> 开始任务。</p>
```

## 显示代码块

```xml
<snippet style="display: block; white-space: pre;">const ready = true;
console.log(ready);</snippet>
```

设置 `display: block` 时使用代码块渲染；可编排行内子树时使用行内代码渲染，否则退回普通容器布局。
