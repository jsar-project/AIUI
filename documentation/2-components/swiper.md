# Swiper 轮播容器

`swiper` 与 `swiper-item` 是用于组织分页内容的视图容器标签。它们目前提供内容分组和 CSS 布局能力，但不会自动完成轮播。

## 组织分页内容

```xml
<swiper class="swiper">
  <swiper-item class="page"><text>第一页</text></swiper-item>
  <swiper-item class="page"><text>第二页</text></swiper-item>
</swiper>
```

```css
.swiper {
  display: flex;
  flex-direction: row;
}

.page {
  width: 100%;
  flex-shrink: 0;
}
```

## 当前行为

`swiper` 和 `swiper-item` 当前使用与 `view` 相同的基础容器实现。它们支持子节点和 CSS 布局，但不内置分页状态、自动轮播、指示点或切换事件；这些行为需要由页面逻辑和样式实现。

如果只需要普通的横向布局，直接使用 `view` 通常更容易理解。只有当标签名称能帮助你表达“分页内容”结构时，才需要选择 `swiper`。
