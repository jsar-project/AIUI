---

name: "aiui-dev"
description: "Specialized agent for developing AIUI applications. Invoke when writing AIUI code, needing API references for jsui/wx, debugging AIUI applications, or aligning AIUI visual design with this Skill's design guidelines."
---

# AIUI Agent Developer Guide

This guide provides independent and comprehensive context for AI agents developing AIUI applications. It includes project structure, SFC `.ink` support specifications, and standard API references, designed to help Large Language Models (LLMs) generate accurate AIUI pages and logic code.

## 1. Project Structure

A standard AIUI application project typically contains the following core files:

- `AGENTS.md`: The agent manifest, defining the agent's identity and capabilities.
- `app.json`: Global configuration, including page routes, window settings, etc.
- `app.js`: Application lifecycle and global logic.
- `pages/`: Page directory containing the application's pages, primarily using the Single File Component (SFC) `.ink` format.
- `assets/`: Directory for storing static resources like images and audio.

### 1.1 Agent Manifest (AGENTS.md)

The manifest file defines the agent's basic information and required permissions/skills:

```markdown
# Agent Manifest

## Identity
- **Name**: My AIUI Agent
- **Version**: 1.0.0
- **Description**: A brief application description.
- **Author**: Developer Name

## Capabilities
- **Permissions**:
  - camera
  - microphone
  - network
  - audio
- **Skills**:
  - weather-lookup
```

### 1.2 Global Configuration (app.json)

Defines application page paths and global UI styles:

```json
{
  "pages": [
    "pages/index/index"
  ],
  "window": {
    "navigationBarTitleText": "My AIUI Agent",
    "viewport": {
      "width": "device-width"
    }
  }
}
```

### 1.3 Application Registration (app.js)

AIUI uses an ES module-based registration system, registering the application by exporting a default configuration object:

```javascript
export default {
  onLaunch() {
    console.log('App Launch');
  },
  globalData: {
    userInfo: null
  }
};
```

### 1.4 Page Configuration (page.json)

In AIUI, each page acts as a Model Context Protocol (MCP) UI component. The configuration for each page is defined in its respective `page.json` (or within the `<script def>` block of an `.ink` file). This configuration declares the page's capabilities and the expected input parameters for rendering.

Key fields in page configuration:

- `description`: A clear, natural language description of what the page UI represents or what task it accomplishes. This helps the AI or system understand the page's purpose.
- `schema`: Defines the expected input data structure for rendering the UI.
  - `data`: A JSON Schema object specifying the properties, types, and required fields needed to populate the page's initial state.

**Example Page Configuration:**

```json
{
  "navigationBarTitleText": "Weather Card",
  "description": "A UI component that displays the current weather conditions for a specific city.",
  "schema": {
    "data": {
      "type": "object",
      "properties": {
        "city": {
          "type": "string",
          "description": "The name of the city"
        },
        "temperature": {
          "type": "number",
          "description": "Current temperature in Celsius"
        },
        "condition": {
          "type": "string",
          "enum": ["sunny", "rainy", "cloudy", "snowy"]
        }
      },
      "required": ["city", "temperature", "condition"]
    }
  }
}
```

## 2. Single File Component (SFC) `.ink` Specification

In AIUI, page development is recommended to use the Single File Component (SFC) format, which is the `.ink` file. This format centralizes the page's configuration, logic, structure, and style in a single file.

A standard `.ink` file structure contains four main tag blocks:

1. `<script def>`: Used to define page-level JSON configuration, such as the navigation bar title.
2. `<script setup>`: Contains the page's JavaScript logic code, exporting the page configuration object (including `data`, lifecycle hooks, custom methods, etc.) via `export default`.
3. `<page>`: The page's template structure (WXML-like syntax).
4. `<style>`: The page's stylesheet (CSS).

### 2.1 `.ink` Example Code:

```html
<script def>
{
  "navigationBarTitleText": "Home"
}
</script>

<script setup>
import wx from 'wx';

export default {
  data: {
    greeting: 'Hello AIUI!'
  },
  onLoad() {
    console.log('Page loaded');
  },
  handleTap() {
    this.setData({
      greeting: 'Hello, World!'
    });
  }
}
</script>

<page>
  <view class="container">
    <text class="title">{{ greeting }}</text>
    <button bindtap="handleTap">Click Me</button>
  </view>
</page>

<style>
.container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100vh;
}

.title {
  font-size: 24px;
  margin-bottom: 20px;
}
</style>
```

## 3. WXML (WeiXin Markup Language) & Components

In AIUI, the structure of a page is described using WXML (WeiXin Markup Language), which is used within the `<page>` tag of an `.ink` file (or a standalone `.wxml` file). It allows you to build user interfaces using components, data binding, and conditional rendering.

### 3.1 Basic Syntax and Data Binding

WXML uses double curly braces `{{ }}` for data binding. You can bind properties from your page's `data` object directly to the UI.

```html
<!-- Text binding -->
<view>{{ message }}</view>

<!-- Attribute binding -->
<view class="{{ dynamicClass }}"></view>

<!-- Expression binding -->
<view>{{ count + 1 }}</view>
```

### 3.2 Directives (Conditional Rendering and Lists)

AIUI supports conditional rendering using the `ink:if`, `ink:elif`, and `ink:else` directives to control whether a component is rendered based on a condition.

```html
<view ink:if="{{condition === 1}}"> Rendered if condition is 1 </view>
<view ink:elif="{{condition === 2}}"> Rendered if condition is 2 </view>
<view ink:else> Rendered otherwise </view>
```

AIUI supports basic list rendering with `ink:for`, allowing you to repeat a component structure for each item in an array.

```html
<view ink:for="{{cities}}" ink:key="name">
  <text>{{item.name}}</text>
  <text>{{item.temperature}}</text>
</view>
```

Use `item` to access the current element and `index` to access its position in the array. Prefer providing a stable `ink:key` when rendering dynamic collections.

> **Current Limitation:** Nested `ink:for` is not supported yet. Keep list rendering to a single level, and flatten data in JavaScript first when you need to present hierarchical content.

### 3.3 Built-in Components

AIUI provides a set of built-in components that you can use within your WXML templates. These components are mapped to native implementations for optimal performance.

For parameter-by-parameter documentation, event behavior, content model notes, and examples, see [components.md](./components.md). The reference there is intentionally aligned with the current component registry and implementation details in `ink-builtin-components`.

For runtime API details, constructor behavior, supported overloads, and current implementation limits, see [apis.md](./apis.md).

- **`<view>`**: The fundamental layout container, similar to `<div>` in HTML.
- **`<text>`**: Displays text content. Similar to `<span>` in HTML.
- **`<icon>`**: An icon-like text element currently rendered through the text component implementation.
- **`<image>`**: Displays local or remote images.
- **`<button>`**: A standard clickable button component.
- **`<canvas>`**: A component for custom 2D drawing.
- **`<scroll-view>`**: A scrollable container for content that exceeds the visible area.
- **`<chart>`**: A chart component supporting Line, Area, Pie, and Radar charts.
- **`<lottie-view>`**: Renders Lottie animations from inline JSON, local files, or remote URLs.
- **`<a2ui>`**: A specialized component for rendering agent-generated UI commands dynamically.
- **`<error-state>`**: A compact status component that displays an optional icon with a message.

## 4. Events

AIUI supports event handling at different levels. Component interaction events are declared in WXML attributes such as `bindtap`, `catchtap`, `bindinput`, and `bindchange`. Page-level events are defined as methods on the exported page object.

### 4.1 Page-Level Events

If a page needs to react to framework-delivered hardware key input, define `onKeyDown(event)` and `onKeyUp(event)` on the exported page object.

These handlers are page methods, not WXML binding attributes. Put the logic on the page instance and update page state with `this.setData(...)` when needed.

```html
<script setup>
export default {
  data: {
    lastKeyAction: 'None'
  },
  onKeyDown(event) {
    console.log('Key down:', event);
    this.setData({
      lastKeyAction: 'Key pressed'
    });
  },
  onKeyUp(event) {
    console.log('Key up:', event);
    this.setData({
      lastKeyAction: 'Key released'
    });
  }
}
</script>

<page>
  <view class="container">
    <text>Last key action: {{ lastKeyAction }}</text>
  </view>
</page>
```

Use this pattern when keyboard input should be handled by the page itself, such as shortcuts, directional navigation, or confirming actions from a hardware key.

## 5. WXSS (WeiXin Style Sheets)

WXSS is a style language used to describe the visual presentation of components. It is highly compatible with standard CSS and is used within the `<style>` block of an `.ink` file (or a standalone `.wxss` file).

### 5.1 Features

WXSS extends standard CSS with features tailored for mobile and wearable devices:

- **`@import`**: You can use the `@import` statement to import external style sheets.

```css
@import "./common.wxss";

.box {
  width: 240px;
  height: 100px;
  background-color: #40FF5E;
}
```

### 5.2 Selectors

AIUI supports most standard CSS selectors:

- **Class Selector (`.class`)**: The recommended way to style components.
- **ID Selector (`#id`)**.
- **Type Selector (`element`)**: e.g., `view`, `text`.
- **Combinators**: Grouping (`A, B`), Descendant (`A B`), Child (`A > B`).

*Recommendation: Prioritize using Class Selectors to ensure optimal rendering performance.*

### 5.3 Flexbox Layout

AIUI's view engine provides robust support for Flexbox. It is the primary and recommended method for building responsive layouts in AIUI.

```css
.container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
}
```

## 6. Design Guidelines

When developing AIUI applications, especially for wearable devices, it is crucial to follow these design guidelines to ensure a consistent and user-friendly experience.

### 6.1 Dimensions and Layout

- **Width**: The application width is strictly **480px**.
- **Height**: The recommended application height is between **120px and 380px**. Avoid creating overly tall pages that require excessive scrolling.
- **Card Style**: It is highly recommended to use a **Card Style** layout for each page. This provides a clear boundary and better visual focus in the spatial environment.
- **Default Background**: Use **black** as the default background color.
- **Default Border**: Use a **2px** border as the default border width for cards and key interactive elements.
- **Border Radius**: The recommended border radius (e.g., for cards, buttons, and images) is **12px**.

### 6.2 Color Palette

- **Primary Color**: Use `#40FF5E` as the primary brand/action color.
  - 100% Opacity: `#40FF5E` (Main elements, active states)
  - 60% Opacity: `rgba(64, 255, 94, 0.6)` (Secondary elements, hover states)
  - 40% Opacity: `rgba(64, 255, 94, 0.4)` (Background highlights, disabled states)
- **Default Text Color**: Use the Primary Color `#40FF5E` as the default text color unless a more specific semantic color is required.

### 6.3 Prohibitions

- **DO NOT use emoji in generated UI copy, labels, status text, or decorative content by default.** Emoji may only be used when the developer explicitly requests them or the product requirements clearly require them.
- **DO NOT use large areas of solid color blocks.** This can be visually overwhelming and uncomfortable on wearable displays. Keep backgrounds subtle and use colors primarily for accents, text, and interactive elements.

## 7. AIUI API Reference

The detailed runtime API reference lives in [apis.md](./apis.md).

When generating code:

- Treat `apis.md` as the source of truth for currently supported API shapes and behaviors.
- Follow the implementation-aligned definitions there instead of assuming standard Web API compatibility.
- Do not infer unlisted overloads, return shapes, or browser semantics.

## 8. Usage Examples (WeChat APIs)

### Take a Photo with Camera

```javascript
import wx from 'wx';

const camera = wx.media.createCameraContext();
const photo = await camera.takePhoto({ quality: 'high' });
console.log('Image data size:', photo.data.byteLength);
```

### Crypto & UUID Generation

```javascript
const uuid = crypto.randomUUID();
const hash = await crypto.subtle.digest('SHA-256', new TextEncoder().encode('hello AIUI'));
```

