# Storage

AIUI storage capabilities are used to save local state, user preferences, business caches, and contextual information generated during runtime. This page does not expand on every API detail. Its main purpose is to help you quickly find the corresponding detailed documentation.

## Simple Example

For example, save a user setting:

<!-- aiui-api-style default=web -->

**Web**

```javascript api-style=web
localStorage.setItem('theme', 'green');
const theme = localStorage.getItem('theme');
```

**wx**

```javascript api-style=wx
wx.setStorageSync('theme', 'green');
const theme = wx.getStorageSync('theme');
```

<!-- /aiui-api-style -->

Continue reading:

- **[Storage API](/AIUI/api/storage-api)**: See how to use `localStorage`.
- **[OPFS](/AIUI/api/storage-opfs)**: See Agent-private directories, files, Blobs, and writable streams.
- **[WeChat Mini Program Compatible APIs](/AIUI/api/weixin-compatible-apis)**: See `wx.setStorage`, `wx.getStorage`, and the synchronous variants.
