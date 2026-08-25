# Swiper 轮播容器

`swiper` 与 `swiper-item` 在 AIUI 0.16 中是已注册的视图容器标签，可用于组织轮播样式的内容结构。

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

AIUI 0.16 将 `swiper` 和 `swiper-item` 注册为与 `view` 相同的基础容器实现。它们支持子节点和 CSS 布局，但不内置分页状态、自动轮播、指示点或切换事件；这些行为需要由页面逻辑和样式实现。
