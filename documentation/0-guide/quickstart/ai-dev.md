# 使用 AI 开发

在 Rokid AIUI 智能体开发中，利用 AI 辅助开发已经成为提升效率的标准方式。通过引入 **AIUI Agent 开发 Skill**，你可以让 AI 助手深度理解 AIUI 框架规范、组件 API 及最佳实践。

## 安装 Skill

你可以利用 [vercel-labs/skills](https://github.com/vercel-labs/skills) 生态，通过一行命令将 AIUI 的开发能力集成到你的项目中：

```bash
# 将 AIUI 相关 Skill 安装到当前项目
npx skills add https://github.com/jsar-project/AIUI/tree/main/skills/aiui-dev
```

## 功能介绍与使用

`aiui-dev` 是一套面向 AIUI 智能体开发的专业 Skill。它为 Coding Agent 提供了完整的 AIUI 开发上下文，让 AI 不只是生成通用前端代码，而是能够按照 AIUI 的项目结构、页面规范、组件体系和设计约束来协助开发。

### 核心功能
- **理解 AIUI 项目结构**：识别 `AGENTS.md`、`app.json`、`app.js`、`pages/`、`widgets/`、`workers/` 和 `assets/` 等核心目录与配置，帮助你搭建或整理 AIUI 工程。
- **生成符合规范的页面代码**：理解 AIUI 推荐的 `.ink` 单文件组件结构，包括 `<script def>`、`<script setup>`、`<page>` 和 `<style>`，适合直接产出页面原型和业务页面。
- **掌握页面配置与数据描述**：能基于 `page.json` 或页面定义中的 `description`、`schema`、`data` 等字段，帮助你设计页面输入数据结构和 UI 组件契约。
- **编写 AIUI 模板与样式**：熟悉 WXML 数据绑定、条件渲染、内置组件，以及 WXSS/Flexbox 布局规则，能更准确地生成 AIUI 页面结构与样式代码。
- **使用 AIUI 内置组件与 API**：覆盖常见组件能力，以及 Web API 和 `wx.*` 兼容 API，例如网络请求、语音、相机、Canvas、存储、路由等场景。
- **遵循 AIUI 设计规范**：理解 AIUI 在尺寸、卡片式布局、主色、圆角、边框和可穿戴场景视觉限制上的约束，帮助你生成更贴合设备体验的界面。
- **辅助调试与迁移**：在排查 AIUI 页面问题、补全接口调用、或将微信小程序风格代码迁移到 AIUI 时，能提供更贴近实际运行环境的建议。

### 安装到 Coding Agent
你可以通过 `skills` 命令将这个 Skill 安装到你正在使用的 Coding Agent 中。`skills` 支持项目级或全局安装，也支持安装到不同的 Agent。

- 使用上面的 `npx skills add ...` 命令即可将 `aiui-dev` 安装到当前项目。
- 如果你希望了解 `skills` 的适用 Agent、安装方式、参数选项和更多用法，请参考 [skills - npm](https://www.npmjs.com/package/skills)。

安装后，AI 助手就能基于 AIUI 的专有上下文来协助你完成页面生成、接口调用、样式编写、问题排查和设计对齐等开发工作。
