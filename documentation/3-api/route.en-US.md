# Routing

AIUI routing capabilities are used to navigate, go back, redirect, and manage the page stack across different pages. This page does not expand on every API detail. Its main purpose is to help you quickly find the specific documentation related to page navigation.

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

## API Reference

### `wx.navigateTo(options)`

Keeps the current page and navigates to a regular page within the app. It cannot navigate to a tabBar page.

### `wx.redirectTo(options)`

Closes the current page and navigates to a regular page within the app. It cannot navigate to a tabBar page.

### `wx.navigateBack(options?)`

Closes the current page and returns to the previous page or multiple previous pages.

### Route Parameters

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| `options.url` | `string` | Required for `navigateTo` and `redirectTo` | Target page path within the app. It may include query parameters. |
| `options.delta` | `number` | No | Number of pages to go back for `navigateBack`. Defaults to `1`. |
| `options.success` | `Function` | No | Success callback. |
| `options.fail` | `Function` | No | Failure callback. |
| `options.complete` | `Function` | No | Completion callback. |

All methods return `undefined`.
