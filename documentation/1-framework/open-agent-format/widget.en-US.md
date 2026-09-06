# Widget

A Widget is a small, independent interface provided by an agent. It works well for weather, playback status, device data, and quick actions that should be understood at a glance. Widgets use the same `.ink` syntax, data binding, components, and styles as Pages, but have their own entry and a smaller set of lifecycle callbacks.

## Declare a Widget

Declare each Widget in the `widgets` array in `app.json`. The `path` omits the extension, and `family` currently supports `1x1` and `1x2`.

```json
{
  "pages": ["pages/index/index"],
  "widgets": [
    { "path": "widgets/clock/index", "family": "1x1" },
    { "path": "widgets/weather/index", "family": "1x2" }
  ]
}
```

Each path maps to an `.ink` file. For example, `widgets/weather/index` maps to `widgets/weather/index.ink`.

## Create the Widget Interface

Use `<widget>` as the interface root. The `family` in `<script def>` must match the value in `app.json`.

```html
<script def>
{
  "widget": { "family": "1x2" },
  "usingComponents": {
    "weather-icon": "/components/weather-icon/index"
  }
}
</script>

<script setup>
export default {
  data: {
    city: 'Hangzhou',
    temperature: 24,
  },
  refresh() {
    this.setData({ temperature: this.data.temperature + 1 });
  },
};
</script>

<widget>
  <view class="weather" bindtap="refresh">
    <weather-icon />
    <text>{{city}}</text>
    <text>{{temperature}}°C</text>
  </view>
</widget>

<style>
.weather {
  display: flex;
  flex-direction: column;
  padding: 12px;
}
</style>
```

An `.ink` file cannot contain both `<page>` and `<widget>`. A Widget also fails to load when its `family` does not match the declaration in `app.json`.

## Update Displayed Content

Widgets store interface data in `data` and update it with `setData()`. You can update top-level values or use dotted paths for nested values.

```javascript
export default {
  data: {
    status: { label: 'Idle' },
    count: 0,
  },
  activate() {
    this.setData({
      count: this.data.count + 1,
      'status.label': 'Active',
    });
  },
};
```

## Respond to Widget State Changes

Widgets provide four optional callbacks:

| Callback | Typical use |
| :--- | :--- |
| `onCreate()` | Initialize Widget data and resources that are created once |
| `onAttach()` | Refresh data about to be shown and resume visible work |
| `onDetach()` | Pause work that is only needed while the Widget is shown |
| `onDestroy()` | Cancel requests, remove listeners, and release resources |

```javascript
export default {
  data: { updatedAt: 0 },
  refresh() {
    this.setData({ updatedAt: Date.now() });
  },
  onCreate() {
    console.log('Widget created');
  },
  onAttach() {
    this.refreshTimer = setInterval(() => this.refresh(), 60_000);
  },
  onDetach() {
    clearInterval(this.refreshTimer);
  },
  onDestroy() {
    clearInterval(this.refreshTimer);
  },
};
```

`onAttach()` and `onDetach()` may run more than once, so resume and pause logic should be safe to repeat.

## Widget and Page Differences

- Widgets do not enter the Page navigation stack.
- Widgets use `onCreate()`, `onAttach()`, `onDetach()`, and `onDestroy()` instead of the Page callbacks `onLoad()`, `onShow()`, `onReady()`, `onHide()`, and `onUnload()`.
- Widgets do not provide Page-only features such as `enableWorldAwareness()` and `finish()`.
- Widgets can use data binding, custom components, event handlers, images, and Canvas.
- `family` describes the Widget size category; layouts should still adapt to the available width and height.

## Continue Reading

- [Widget API](/AIUI/api/framework-widget): inspect `data`, `setData()`, size, and state properties
- [app.json](/AIUI/framework/open-agent-format-app-json): configure application entries
- [Components](/AIUI/framework/open-agent-format-custom-components): reuse interface components in a Widget
- [Canvas](/AIUI/api/canvas): draw graphics in a Widget
