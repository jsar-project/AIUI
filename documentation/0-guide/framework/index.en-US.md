# Agent Framework

AIUI is an intent-driven development framework for building intelligent agents. Its goal is not only to render interfaces or execute page logic, but to turn user intent into a complete product flow: the agent understands intent, selects the right interaction form, runs the required logic, and continuously maps the result back into UI feedback.

At the implementation level, AIUI is built around two core layers:

- **Logic Layer**: Interprets intent and handles application, Page, Widget, and Agent Worker state, API calls, and events.
- **View Layer**: Uses Pages or Widgets to present information, collect input, and reflect state changes.

But AIUI is not defined only by the split between logic and UI. In a real agent project, the framework also works together with:

- `AGENTS.md`, which defines the agent's identity, goals, capabilities, and behavioral boundaries
- `app.json`, which declares Pages, Widgets, Agent Workers, and global configuration
- Pages and Widgets, which carry full interactions and compact at-a-glance interfaces
- Agent Workers, which manage shared tasks that do not belong to one interface

Together, these parts form a full loop from **intent understanding** to **interaction orchestration** to **interface feedback**.

## What You Will Learn

This section explains the framework from four perspectives:

- **Introduction**: Learn how AIUI organizes intent, runtime, and UI into one coherent framework.
- **Categories**: Understand different intent-carrying interaction forms, such as conversational AIUI and immersive AIUI.
- **Logic Development**: Learn how to organize Page, Widget, and Agent Worker lifecycle callbacks, state, and business logic around user intent.
- **User Interface (UI) Development**: Learn how to build Pages and Widgets with WXML, WXSS, and `.ink`.

## Suggested Reading Path

- If you are new to AIUI, start with **Introduction** to understand why AIUI is framed around intent rather than pages alone.
- Then read **Categories** to decide what interaction form should carry your product's intent.
- Continue with **Logic Development** to understand how intent is translated into state, lifecycle, and business behavior.
- Finally, read **User Interface (UI) Development** to connect intent-driven logic with a concrete interface.

For complete configuration and examples, see [Widget Development](/AIUI/framework/open-agent-format-widget) and [Agent Worker Development](/AIUI/framework/open-agent-format-agent-worker).

Use the sub-sections in the left-side menu to continue reading.
