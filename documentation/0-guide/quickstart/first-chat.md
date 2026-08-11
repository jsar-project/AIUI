# 对话式 AIUI

如果你想先理解 AIUI 最直观的一种形态，最适合从对话式 AIUI 开始。它的核心特点是：UI 直接出现在聊天流里，用户一边和 AI 对话，一边在消息中的卡片、表单或结果块里继续操作。

## 1. 先理解目标形态

对话式 AIUI 不是让 AI 回复一长段文字，而是让 AI 在对话上下文里插入一个可交互界面。例如：

- 查询天气后，直接返回一张天气卡片
- 确认行程后，直接返回一个可操作的行程确认面板
- 搜索商品后，直接返回一个可筛选、可点击的结果列表

它的重点是：**交互仍然留在当前对话里，不需要跳到另一个独立界面。**

## 2. 创建一个基础项目

你可以先使用脚手架创建一个 AIUI 项目：

```bash
npm create @yodaos-pkg/aiui-agent my-aiui-chat-agent
```

完成初始化后，你可以直接用 `.ink` 单文件组件来组织第一个页面。这样更适合快速理解 AIUI 页面是怎么写出来的：

```text
├── app.js
├── app.json
├── AGENTS.md
├── pages
│   └── weather
│       └── index.ink
```

## 3. 用 `.ink` 定义一个对话中的天气卡片

假设我们希望模型在用户询问天气时，渲染一张天气卡片。这里可以直接用一个 `.ink` 文件把页面配置、页面逻辑、页面结构和页面样式放在一起。

```html
<script def>
{
  "navigationBarTitleText": "Weather Card",
  "description": "天气相关问题优先返回此工具，支持查询中国大陆地区的实时天气、气温、湿度、风力。支持自动识别当前城市或查询指定城市（如问“北京天气怎么样”）。",
  "schema": {
    "data": {
      "type": "object",
      "properties": {
        "location": {
          "type": "string",
          "description": "目标城市名称（如“北京”、“上海”），仅支持城市名，不支持其他地区。若用户未明确指定，则默认为其当前所在城市。"
        },
        "date": {
          "type": "string",
          "description": "查询日期，格式为 yyyy-mm-dd（如“2023-10-01”）。"
        }
      },
      "required": ["location"]
    }
  }
}
</script>

<script setup>
export default {
  data: {
    city: '',
    loading: true,
    weather: null
  },

  async onLoad(query) {
    const city = query.location || '杭州';

    this.setData({
      city,
      loading: true
    });

    const weather = {
      condition: '多云',
      temperature: 26
    };

    this.setData({
      weather,
      loading: false
    });
  },

  refreshWeather() {
    this.setData({
      weather: {
        condition: '小雨转多云',
        temperature: 25
      },
      loading: false
    });
  }
};
</script>

<page>
  <view class="weather-card">
    <text class="title">{{ city }} 天气</text>

    <view ink:if="{{ loading }}">
      <text class="hint">天气加载中...</text>
    </view>

    <view ink:else>
      <text class="condition">{{ weather.condition }}</text>
      <text class="temperature">{{ weather.temperature }}°C</text>
      <button class="action" bindtap="refreshWeather">刷新天气</button>
    </view>
  </view>
</page>

<style>
.weather-card {
  display: flex;
  flex-direction: column;
  gap: 12px;
  padding: 20px;
  border-radius: 16px;
  background: linear-gradient(180deg, rgba(7, 193, 96, 0.18), rgba(7, 193, 96, 0.05));
}

.title {
  font-size: 20px;
  font-weight: 600;
}

.hint,
.condition,
.temperature {
  font-size: 16px;
}

.action {
  width: 120px;
}
</style>
```

这个 `.ink` 文件里包含了四部分：

- `<script def>`：页面级配置，以及页面的 `description` 和 `schema.data`
- `<script setup>`：页面逻辑和数据
- `<page>`：界面结构
- `<style>`：页面样式

对于入门场景来说，这种写法的优势很明显：你可以在一个文件里同时看到“这个页面要展示什么”和“这个页面如何响应交互”。

## 4. 这个天气卡片是如何工作的？

在这个例子里，页面通过 `onLoad(query)` 接收 `location` 参数。也就是说，当外部以“杭州”这样的上下文触发这个页面时，页面就能根据 `query.location` 去组织当前卡片内容。

随后，用户还可以继续点击卡片里的 `刷新天气` 按钮，这就是对话式 AIUI 的关键特征之一：**用户的下一步操作直接发生在聊天流中的这张卡片里。**

## 5. 它和普通聊天有什么区别？

普通聊天是：AI 返回一段天气描述文本。

对话式 AIUI 是：AI 在对话流中直接返回一张天气卡片，用户可以继续围绕这张卡片查看、刷新、确认或进入下一步。

这意味着：

- AI 的输出不再只是文本
- UI 和对话上下文保持连续
- 用户操作发生在消息内部，而不是跳出当前会话

## 6. 适合从哪些场景开始？

如果你第一次做对话式 AIUI，建议从下面这些场景开始：

- 天气卡片
- 行程确认卡片
- 搜索结果卡片
- 待办确认面板
- 表单补充输入

这些场景的共同点是：交互比较轻，结构清晰，并且很适合直接放在对话流中完成。
