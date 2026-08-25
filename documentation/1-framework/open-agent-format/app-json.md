# app.json

在 AIUI 对 Open Agent Format 的扩展中，`app.json` 用来定义应用级入口和全局配置。它决定一个智能体应用从哪里开始运行，也决定页面集合和全局窗口行为如何组织。

不过，一个完整的应用级定义通常不只有 `app.json`，还会同时配合应用级逻辑入口一起使用。你可以把它理解成：

- `app.json`：定义应用入口、页面集合和全局配置
- `app.js`：定义应用级逻辑和全局生命周期

## `app.json` 负责什么

`app.json` 主要用于声明：

- 应用包含哪些页面
- 应用从哪个页面开始启动
- 全局窗口样式
- 跨页面共享的基础配置

一个典型示例如下：

```json
{
  "pages": [
    "pages/index/index",
    "pages/logs/logs"
  ],
  "window": {
    "backgroundTextStyle": "light",
    "navigationBarBackgroundColor": "#fff",
    "navigationBarTitleText": "AIUI Agent",
    "navigationBarTextStyle": "black"
  }
}
```

这里最重要的部分是：

- `pages`：声明页面路径列表
- `window`：声明全局窗口配置

## 它和 `AGENTS.md` 的关系

如果说 `AGENTS.md` 定义的是“这个智能体是谁、具备什么能力”，那么 `app.json` 定义的就是“这个智能体应用从哪里开始，以及界面如何组织”。

两者关注点不同：

- `AGENTS.md`：智能体身份、说明、系统指令、能力边界
- `app.json`：应用入口、页面集合、全局界面配置

## 应用级逻辑：`app.js`

除了 `app.json`，AIUI 应用通常还会有一个 `app.js` 作为应用级逻辑入口。它用于注册应用本身，并承载全局生命周期和全局数据。

示例：

```javascript
export default {
  onLaunch(options) {
    // 智能体初始化
  },
  onShow(options) {
    // 智能体显示
  },
  onHide() {
    // 智能体隐藏
  },
  globalData: {
    // 全局数据
  }
}
```

你可以把 `app.js` 理解成“应用级逻辑层”，它更关注整个应用在启动、显示、隐藏过程中的行为，而不是某个具体页面的行为。

## 应用级生命周期

`app.js` 中常见的全局生命周期包括：

| 回调函数 | 说明 | 触发时机 |
| :--- | :--- | :--- |
| `onLaunch` | 监听智能体初始化 | 智能体初始化完成时，全局只触发一次 |
| `onShow` | 监听智能体显示 | 智能体启动，或从后台进入前台时 |
| `onHide` | 监听智能体隐藏 | 智能体从前台进入后台时 |
| `onError` | 错误监听函数 | 智能体发生脚本错误或 API 调用失败时 |

这些回调和页面级生命周期不同，它们描述的是整个应用，而不是单个页面。

## 在 Open Agent Format 里的位置

从 Open Agent Format 视角看，`app.json` 和 `app.js` 共同补上了“应用级定义”这一层：

- `AGENTS.md`：描述智能体
- `app.json`：定义应用入口和全局配置
- `app.js`：定义应用级逻辑和全局生命周期
- `pages/`：定义具体页面与交互界面

这也是 AIUI 相比纯描述型 Agent Format 更进一步的地方：它不仅描述智能体，还定义智能体如何以可运行的应用形态存在。

## 推荐阅读

- [AGENTS.md](/AIUI/framework/config-agents)
- [页面概览](/AIUI/framework/open-agent-format-page)
- [页面定义](/AIUI/framework/open-agent-format-page-definition)
