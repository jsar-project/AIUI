# Open Agent Format

Open Agent Format，简称 OAF，是一套用目录结构和文件约定来描述智能体的开放工程格式。它不把智能体理解成一个孤立的提示词文件，而是把“智能体是谁、怎么启动、如何与用户交互、哪些能力可以复用”拆分成清晰的工程层次。

在 AIUI 中，Open Agent Format 不只是“描述规范”，也是把智能体落成可运行应用的骨架。你可以把它理解成：AIUI 基于 OAF，把智能体从静态说明扩展成了具备页面、组件、模块和可分发包的 AI-Native User Interface。

## 它到底是什么

如果只用一段文本描述智能体，通常很难回答这些工程问题：

- 智能体的身份、职责和行为边界写在哪里
- 应用从哪个入口启动
- 页面如何组织，用户最终会看到什么界面
- 可复用的组件、模块和资源如何拆分
- 这些能力如何在不同项目之间迁移和复用

Open Agent Format 解决的，就是这些信息的组织问题。它把智能体重新落回“文件系统”本身，让工程结构天然成为智能体定义的一部分。

换句话说，OAF 不是单个配置文件，而是一套面向工程的组织方式：

- 用 `AGENTS.md` 表达智能体描述层
- 用 `app.json` 和应用入口表达运行层
- 用 `pages/` 表达页面和交互层
- 用 `widgets/` 表达小尺寸独立界面
- 用 `workers/` 表达跨页面共享的后台任务
- 用组件、模块与 Package 表达复用层

## AIUI 扩展了什么

标准 OAF 更强调“如何描述一个 Agent”，而 AIUI 更进一步，补上了“如何把 Agent 运行成界面应用”这一层。

在 AIUI 里，一个完整的 OAF 工程通常至少包含以下几部分：

- `AGENTS.md`：定义智能体身份、系统指令、能力边界和协作约束
- `app.json`：定义应用入口、页面列表和全局窗口配置
- `pages/`：定义具体页面、页面生命周期、事件以及交互逻辑
- `widgets/`：定义 Widget 入口、显示内容和状态变化回调
- `workers/`：定义 Agent Worker 后台任务
- `components/`：封装可复用 UI 与局部交互单元
- `modules/` 或其他普通模块文件：拆分业务逻辑、工具函数和资源导入
- `package.json` 与 Package 导出：把可复用能力分发给其他 AIUI 应用

因此，在 AIUI 语境下，Open Agent Format 可以理解成两层：

- 描述层：说明这个智能体是什么
- 应用层：说明这个智能体如何被运行、展示和复用

这也是 AIUI 和“只有提示词或只有配置”的 Agent 工程之间最大的差别。

## 典型结构怎么理解

下面是一个经过抽象后的 OAF / AIUI 工程示意：

```text
agent-app/
  AGENTS.md
  app.json
  app.js
  pages/
    home/
      index.ink
  widgets/
    weather/
      index.ink
  workers/
    sync.js
  components/
    agent-card.ink
  modules/
    format-message.ts
  package.json
```

这里每一层分别回答不同问题：

- `AGENTS.md`：这个智能体是谁，应该如何思考和回应
- `app.json` / `app.js`：这个智能体应用如何启动，以及有哪些全局行为
- `pages/`：用户实际看到和操作的界面是什么
- `widgets/`：用户可以快速查看或操作的小尺寸界面是什么
- `workers/`：哪些任务需要在多个 Page 或 Widget 之间保持运行
- `components/`：界面里哪些片段需要复用和封装
- `modules/`：哪些逻辑、资源或能力需要被拆分复用
- `package.json`：哪些能力要作为 Package 暴露给别的项目使用

如果你把 AIUI 看成“让 Agent 具备真实 UI”的框架，那么 OAF 就是这套 UI 工程的基础文件格式。

## 为什么它重要

Open Agent Format 的价值，不在于引入新的术语，而在于让智能体工程具备更好的可读性、可维护性和可迁移性：

- 目录本身就是文档，降低接手和协作成本
- 描述层与界面层边界更清晰，方便拆分职责
- 页面、组件、模块和 Package 之间职责明确，便于长期演进
- 不同平台之间更容易建立映射关系，而不是被私有配置锁死

对于 AIUI 来说，这一点尤其重要，因为 AIUI 面向的不是“只能回答文本的 Agent”，而是“能够运行页面、承载交互、管理状态”的智能体应用。

## 继续阅读

- [AGENTS.md](/AIUI/framework/config-agents)：了解智能体描述文件如何定义身份、说明和指令
- [app.json](/AIUI/framework/open-agent-format-app-json)：了解应用入口、页面集合和全局配置
- [页面](/AIUI/framework/open-agent-format-page)：了解页面如何承载具体 UI、生命周期和交互
- [Widget](/AIUI/framework/open-agent-format-widget)：了解如何开发小尺寸独立界面
- [Agent Worker](/AIUI/framework/open-agent-format-agent-worker)：了解如何开发共享后台任务
- [组件](./custom-components)：了解可复用 UI 单元如何注册、组合和通信
- [模块](./module)：了解逻辑、资源和 WebAssembly 如何通过模块组织
- [Package](./package)：了解如何把模块与组件封装成可分发能力
