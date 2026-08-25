# Swiper

`swiper` and `swiper-item` are registered view-container tags in AIUI 0.16 for organizing carousel-like content structures.

## Organize Paged Content

```xml
<swiper class="swiper">
  <swiper-item class="page"><text>Page one</text></swiper-item>
  <swiper-item class="page"><text>Page two</text></swiper-item>
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

## Current Behavior

AIUI 0.16 registers `swiper` and `swiper-item` with the same basic container implementation as `view`. They support child nodes and CSS layout, but do not provide built-in pagination state, autoplay, indicators, or change events. Implement those behaviors in page logic and styles.
