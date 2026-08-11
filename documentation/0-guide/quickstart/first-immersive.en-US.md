# Immersive AIUI

If you want AIUI to carry a more complete interaction flow instead of just placing UI inside chat messages, the best place to start is with immersive AIUI. Its core characteristic is that the main interaction happens inside a standalone interface, where the AI and the user continuously collaborate around that interface.

## 1. First Understand How It Differs from Conversational AIUI

The biggest difference between immersive AIUI and conversational AIUI is not that one has a "larger page" or a "more complex interface," but that they differ in how they are invoked and how their context model works.

### Difference 1: It Is Not a Page Tool, but the Entire Agent Is Invoked Directly

Conversational AIUI usually declares a page as a callable tool through `description` and `schema.data` in the page's `script def`. The model decides when to call that card or piece of UI based on the current context.

Immersive AIUI is different. It does not need to define a page as an independent tool. Instead, it invokes the entire agent directly through the agent's own description. Once invoked, the runtime enters the first page configured in `app.json`, and that page becomes the starting point of the immersive interaction.

A minimal entry relationship can be understood like this:

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

In other words, in immersive AIUI, what actually gets invoked is the entire agent rather than a single page tool. The page is simply the entry point that carries the experience after the agent starts.

### Difference 2: It Has an Independent Context, and Voice Interaction Must Be Implemented by the Developer

Conversational AIUI usually takes place inside an existing chat context, where many conversation capabilities already come for free.

Immersive AIUI, by contrast, runs as an independent context. If developers still need capabilities such as ASR, LLM, and TTS, they must connect the entire voice interaction pipeline themselves through APIs like `SSE`, `WebSocket`, and `fetch`, including:

- Capturing user input
- Sending the input to the model or backend service
- Receiving streaming results
- Updating UI state
- Driving speech playback or follow-up actions

This increases implementation cost, but its biggest advantage is also its high degree of customization. You can organize voice, interface, state, and interaction entirely according to your own product rhythm, without being constrained by the chat container itself.

Common target forms for immersive AIUI include:

- A Landlord game interface
- A task panel
- A game or training interface
- A tool interface with a long operation flow

In these scenarios, what users focus on is no longer "what the AI said," but "what is currently happening on the interface."

## 2. Create a Basic Project

You can also start by creating an AIUI project with the scaffolding tool:

```bash
npm create @yodaos-pkg/aiui-agent my-aiui-immersive-agent
```

After initialization, you can still use a single-file `.ink` component to organize your first immersive page:

```text
├── app.js
├── app.json
├── AGENTS.md
├── pages
│   └── landlord
│       └── index.ink
```

## 3. Build a Minimal Interface with `.ink`

Using the Landlord game as an example, first create a basic interface that includes a desk area, a hand area, and an action area. Here, the `.ink` page is only responsible for carrying the immersive interface itself and no longer declares itself as an independent page tool:

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

This `.ink` file places the core skeleton of the entire immersive interface in one place. For beginners, this makes it easier to build the right intuition: the focus of immersive AIUI is not a single message, but organizing interaction around a persistent interface. The page here is only the entry of the interface and is not responsible for declaring itself as a page-level tool.

## 4. How Does This Interface Work?

In this example:

- `statusText` expresses the current interface state
- `handCards` renders the hand area
- `playCards`, `passTurn`, and `askAgentTip` simulate actions and AI collaboration

That means user actions, AI suggestions, and state changes on the interface all continue to happen around this single page.

## 5. Which Scenarios Should You Start With?

If this is your first immersive AIUI project, it is recommended to start with these scenarios:

- Landlord or other turn-based mini-games
- Task execution panels
- Device control panels
- Tool interfaces with longer workflows
- Interactive interfaces that need continuous state feedback

What these scenarios have in common is that they involve more interaction steps, more continuous state, and an interface that is itself the core of the experience.

