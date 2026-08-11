# 沉浸式 AIUI

如果你希望 AIUI 承载更完整的交互过程，而不是只把 UI 放进聊天消息里，那么最适合从沉浸式 AIUI 开始理解。它的核心特点是：主交互发生在一个独立界面中，AI 与用户围绕这个界面持续协作。

## 1. 先理解它和对话式 AIUI 的区别

沉浸式 AIUI 和对话式 AIUI 最大的区别，不在于“页面更大”或“界面更复杂”，而在于它们的调起方式和上下文模型不同。

### 区别 1：它不是页面 tool，而是直接调起整个 agent

对话式 AIUI 通常会在页面的 `script def` 中通过 `description` 和 `schema.data` 把页面声明成一个可调用工具，模型根据上下文决定何时调用这张卡片或这块 UI。

沉浸式 AIUI 则不同。它不需要把某个页面定义成一个独立的 tool，而是通过智能体本身的描述信息直接调起整个 agent。被调起后，运行时会进入 `app.json` 中配置的第一个页面，由这个页面作为沉浸式交互的起点。

一个最小的入口关系可以先理解成这样：

```md
# AGENTS.md

## Description
一个适合在斗地主场景中被直接调起的智能体，提供完整的牌桌界面、状态反馈和持续交互能力。
```

```json
{
  "pages": [
    "pages/landlord/index"
  ],
  "window": {
    "navigationBarTitleText": "斗地主"
  }
}
```

也就是说，在沉浸式 AIUI 里，真正被调起的是整个 agent，而不是某一个页面 tool；页面只是 agent 启动后承载体验的入口。

### 区别 2：它是独立上下文，语音交互需要开发者自己实现

对话式 AIUI 通常发生在现成的聊天上下文里，很多对话能力天然已经存在。

沉浸式 AIUI 则是一个独立运行的上下文。开发者如果还需要继续使用 ASR、LLM、TTS 等能力，就需要自己通过 `SSE`、`WebSocket`、`fetch` 等 API 把整套语音交互链路接起来，包括：

- 采集输入
- 把输入发送给模型或服务端
- 接收流式结果
- 更新界面状态
- 驱动语音播报或后续动作

这会增加实现成本，但它的最大好处也是高度自定义。你可以完全按照自己的产品节奏去组织语音、界面、状态和交互，而不受聊天容器本身的限制。

沉浸式 AIUI 常见的目标形态包括：

- 一个斗地主界面
- 一个任务面板
- 一个游戏或训练界面
- 一个操作流程较长的工具界面

在这些场景里，用户看到的重点不再是“AI 说了什么”，而是“当前界面正在发生什么”。

## 2. 创建一个基础项目

你同样可以先使用脚手架创建一个 AIUI 项目：

```bash
npm create @yodaos-pkg/aiui-agent my-aiui-immersive-agent
```

完成初始化后，你同样可以直接用 `.ink` 单文件组件来组织第一个沉浸式页面：

```text
├── app.js
├── app.json
├── AGENTS.md
├── pages
│   └── landlord
│       └── index.ink
```

## 3. 用 `.ink` 先搭一个最小界面

以斗地主场景为例，先做出一个包含桌面区、手牌区和操作区的基础界面。这里的 `.ink` 页面只负责承载沉浸式界面本身，不再把自己声明成一个单独的页面 tool：

```html
<script def>
{
  "navigationBarTitleText": "斗地主"
}
</script>

<script setup>
export default {
  data: {
    roomId: '',
    playerName: '你',
    statusText: '等待用户操作',
    selectedCards: ['7', '7'],
    handCards: ['3', '4', '5', '7', '7', '9', '10', 'J', 'Q']
  },

  onLoad(query) {
    this.setData({
      roomId: query.roomId || 'room-demo',
      playerName: query.playerName || '你'
    });
  },

  playCards() {
    this.setData({
      statusText: '已提交当前出牌：一对 7'
    });
  },

  passTurn() {
    this.setData({
      statusText: '本轮选择不要'
    });
  },

  askAgentTip() {
    this.setData({
      statusText: 'AI 正在分析当前牌面，建议先出一对 7'
    });
  }
};
</script>

<page>
  <view class="table">
    <view class="desk-area">
      <text class="section-title">牌桌区域</text>
      <text class="desk-cards">上家出牌：6 6</text>
    </view>

    <view class="status-area">
      <text class="status-text">{{ statusText }}</text>
    </view>

    <view class="hand-area">
      <text class="section-title">{{ playerName }}的手牌</text>
      <view class="cards">
        <text
          class="card"
          ink:for="{{ handCards }}"
          ink:key="*this"
        >
          {{ item }}
        </text>
      </view>
    </view>

    <view class="action-area">
      <button bindtap="playCards">出牌</button>
      <button bindtap="passTurn">不要</button>
      <button bindtap="askAgentTip">提示</button>
    </view>
  </view>
</page>

<style>
.table {
  display: flex;
  flex-direction: column;
  gap: 16px;
  padding: 20px;
}

.desk-area,
.status-area,
.hand-area,
.action-area {
  padding: 16px;
  border-radius: 16px;
  background: rgba(255, 255, 255, 0.05);
}

.section-title {
  font-size: 16px;
  font-weight: 600;
}

.desk-cards,
.status-text {
  display: block;
  margin-top: 8px;
  font-size: 14px;
}

.cards {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-top: 12px;
}

.card {
  width: 36px;
  height: 48px;
  text-align: center;
  line-height: 48px;
  border-radius: 8px;
  background: #ffffff;
  color: #111827;
}

.action-area {
  display: flex;
  gap: 12px;
}
</style>
```

这个 `.ink` 文件把整个沉浸式界面的核心骨架放在了一起。对于入门来说，这样能更快建立一个直觉：沉浸式 AIUI 的重点不是某条消息，而是围绕一个持续存在的界面去组织交互。这里的页面本身只是界面入口，不负责把自己声明成一个页面级 tool。

## 4. 这个界面是如何工作的？

在这个例子里：

- `statusText` 用来表达当前界面状态
- `handCards` 用来渲染手牌区域
- `playCards`、`passTurn`、`askAgentTip` 用来模拟操作和 AI 协作

也就是说，用户的操作、AI 的建议、界面上的状态变化，都会围绕这一个页面持续发生。

## 5. 适合从哪些场景开始？

如果你第一次做沉浸式 AIUI，建议从下面这些场景开始：

- 斗地主或其他回合制小游戏
- 任务执行面板
- 设备控制面板
- 流程较长的工具界面
- 需要持续状态反馈的交互界面

这些场景的共同点是：交互步骤更多、状态更连续、界面本身就是体验的核心。
