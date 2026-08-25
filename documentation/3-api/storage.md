# 数据存储

AIUI 的数据存储能力用于保存本地状态、用户偏好、业务缓存以及运行过程中的上下文信息。这里不展开接口细节，主要帮助你快速找到对应的详细文档。

## 简单示例

例如，保存一个用户设置项：

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

继续阅读：

- **[Storage API](/AIUI/api/storage-api)**：查看 `localStorage` 的使用方式。
- **[OPFS](/AIUI/api/storage-opfs)**：查看 Agent 私有目录、文件、Blob 与可写流。
- **[微信小程序兼容 API](/AIUI/api/weixin-compatible-apis)**：查看 `wx.setStorage`、`wx.getStorage` 及同步版本接口。
