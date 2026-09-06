# Introduction

The core of the AIUI agent framework is not simply "rendering a page." AIUI is an intent-driven development framework: developers describe what kind of agent they are building, what user intent should be captured, how that intent should be processed, and what interaction form should be used to return feedback. The runtime then connects these parts into a complete loop.

The interactive explanation below helps you understand the AIUI framework from two angles:

- What parts participate in the intent-to-feedback loop
- How a Page or Widget update happens at runtime

<framework-runtime-explorer></framework-runtime-explorer>

## Core Concepts

AIUI separates the logic layer from the view layer, but these layers work together with the agent description, application entry, Pages, Widgets, and Agent Workers:

1. **Agent Description**: Defined by `AGENTS.md`, which specifies the agent's identity, description, capabilities, and system instructions, determining how the platform understands what kinds of intent this agent should handle.
2. **Agent Entry (Application Entry)**: Defined by `app.json`, which declares Pages, Widgets, Agent Workers, and global configuration.
3. **Logic Layer**: Interprets user actions, runs business logic, calls APIs, and manages data. Agent Workers can own shared tasks that do not belong to one interface.
4. **View Layer**: Pages carry complete interactions, while Widgets provide compact information and quick actions. Both can use data binding, components, and styles.

This architecture provides smooth interface updates while letting developers separately organize the intent, choose between a Page and a Widget, decide which tasks must be shared, and define how the interface responds.
