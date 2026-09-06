# Routing

AIUI routing APIs open Widgets and support navigation, back navigation, redirects, and page-stack management within an application.

## Open a Widget

Use `window.open()` to open a Widget declared in `app.json`. Omit the `.ink` extension from the path. Query parameters can follow the path:

```javascript
window.open('widgets/weather?city=hangzhou', '_widget');
```

The `target` argument is optional and defaults to `_widget`:

```javascript
window.open('widgets/weather?city=hangzhou');
```

`window.open()` currently opens Widgets only. Opening another Page is not supported. The call returns immediately without returning a Widget instance or an opening result.

## Navigate to a Detail Page

For example, navigate from the home page to a detail page:

```javascript
wx.navigateTo({
  url: '/pages/detail/index?id=1'
});
```

Continue reading:

- **[WeChat Mini Program Compatible APIs](/AIUI/api/weixin-compatible-apis)**: See APIs such as `wx.navigateTo`, `wx.redirectTo`, and `wx.navigateBack`.
- **[App](/AIUI/api/framework-app)**: Learn about application-level configuration and lifecycle entry points.
- **[Page](/AIUI/api/framework-page)**: Learn how pages are defined and how page-level behavior works.
- **[Widget](/AIUI/api/framework-widget)**: Learn about Widget data, state, and dimension APIs.
- **[AgentWorker](/AIUI/api/framework-agent-worker)**: Learn about background-task events and instance APIs.

## API Reference

### `window.open(url, target?)`

Opens a declared Widget. The equivalent global function `open(url, target?)` is also available.

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| `url` | `string` | Yes | Widget path with optional query parameters, such as `widgets/weather?city=hangzhou` |
| `target` | `'_widget'` | No | Opening target; defaults to `'_widget'`, which is currently the only supported value |

Returns `undefined`. A `TypeError` is thrown synchronously when `url` is not a string or is empty after trimming.

### wx APIs

#### `wx.navigateTo(options)`

Keeps the current page and navigates to a regular page within the app. It cannot navigate to a tabBar page.

#### `wx.redirectTo(options)`

Closes the current page and navigates to a regular page within the app. It cannot navigate to a tabBar page.

#### `wx.navigateBack(options?)`

Closes the current page and returns to the previous page or multiple previous pages.

#### Route Parameters

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| `options.url` | `string` | Required for `navigateTo` and `redirectTo` | Target page path within the app. It may include query parameters. |
| `options.delta` | `number` | No | Number of pages to go back for `navigateBack`. Defaults to `1`. |
| `options.success` | `Function` | No | Success callback. |
| `options.fail` | `Function` | No | Failure callback. |
| `options.complete` | `Function` | No | Completion callback. |

All methods return `undefined`.
