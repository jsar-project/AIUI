# app.json

In AIUI's extension of Open Agent Format, `app.json` defines application-level entries and global configuration. It determines where an agent application starts and how its Pages, Widgets, Agent Workers, and global window behavior are organized.

However, a complete application-level definition usually includes more than `app.json`. It is typically used together with an application-level logic entry. You can think of it as:

- `app.json`: Defines Pages, Widgets, Agent Workers, and global configuration
- `app.js`: Defines application-level logic and the global lifecycle

## What `app.json` Is Responsible For

`app.json` is mainly used to declare:

- Which pages the application contains
- Which Widgets the application contains
- Which background tasks run with the agent
- Which page the application starts from
- Global window styles
- Shared base configuration across pages

A typical example looks like this:

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

The most important parts here are:

- `pages`: Declares the list of page paths
- `window`: Declares the global window configuration

## Declare Widgets and Background Tasks

In addition to Pages, `app.json` can declare Widgets and Agent Workers:

```json
{
  "pages": ["pages/index/index"],
  "widgets": [
    { "path": "widgets/weather/index", "family": "1x2" }
  ],
  "agentWorkers": [
    {
      "name": "sync",
      "script": "workers/sync.js",
      "trigger": { "type": "open" },
      "lifetime": "instant"
    }
  ]
}
```

- `widgets` declares independent Widget entries and their `1x1` or `1x2` size category.
- `agentWorkers` declares the name, entry file, start condition, and lifetime of a background script.

For complete configuration and examples, see [Widget](/AIUI/framework/open-agent-format-widget) and [Agent Worker](/AIUI/framework/open-agent-format-agent-worker).

## Its Relationship With `AGENTS.md`

If `AGENTS.md` defines "who this agent is and what capabilities it has," then `app.json` defines "where this agent application starts and how its UI is organized."

They focus on different concerns:

- `AGENTS.md`: Agent identity, description, system instructions, and capability boundaries
- `app.json`: Application entry, page set, and global UI configuration

## Application-level Logic: `app.js`

In addition to `app.json`, AIUI applications usually have an `app.js` file as the application-level logic entry. It is used to register the application itself and carries the global lifecycle and global data.

Example:

```javascript
export default {
  onLaunch(options) {
    // Agent initialization
  },
  onShow(options) {
    // Agent becomes visible
  },
  onHide() {
    // Agent is hidden
  },
  globalData: {
    // Global data
  }
}
```

You can think of `app.js` as the "application-level logic layer." It focuses more on the behavior of the entire application during startup, display, and hiding, rather than the behavior of a specific page.

## Application-level Lifecycle

Common global lifecycle callbacks in `app.js` include:

| Callback | Description | Trigger Timing |
| :--- | :--- | :--- |
| `onLaunch` | Listens for agent initialization | Triggered once globally when agent initialization is complete |
| `onShow` | Listens for the agent becoming visible | Triggered when the agent starts or returns to the foreground |
| `onHide` | Listens for the agent being hidden | Triggered when the agent moves from the foreground to the background |
| `onError` | Error listener | Triggered when a script error occurs or an API call fails |

These callbacks are different from page-level lifecycles. They describe the entire application rather than a single page.

## Its Place In Open Agent Format

From the perspective of Open Agent Format, `app.json` and `app.js` together complete the "application-level definition" layer:

- `AGENTS.md`: Describes the agent
- `app.json`: Defines Pages, Widgets, Agent Workers, and global configuration
- `app.js`: Defines application-level logic and the global lifecycle
- `pages/`: Defines concrete pages and interactive UI

This is also where AIUI goes beyond a purely descriptive Agent Format: it not only describes the agent, but also defines how the agent exists as a runnable application.

## Recommended Reading

- [AGENTS.md](/AIUI/framework/config-agents)
- [Page Overview](/AIUI/framework/open-agent-format-page)
- [Page Definition](/AIUI/framework/open-agent-format-page-definition)
- [Widget](/AIUI/framework/open-agent-format-widget)
- [Agent Worker](/AIUI/framework/open-agent-format-agent-worker)
