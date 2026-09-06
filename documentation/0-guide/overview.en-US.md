# Overview

If this is your first time seeing AIUI, you can think of it as a framework for building agents that are intelligent, interactive, and designed for new kinds of devices.

It is not just a chatbot, and it is not only a traditional UI framework. AIUI is a way to organize **AI capabilities**, **user interfaces**, **device capabilities**, and **agent logic** into one product, so developers can build intelligent agents that people can actually use.

![AIUI connects AI, interactive interfaces, and capabilities across devices](../image/overview/aiui-ecosystem.png)

From lightweight prompts on glasses to persistent task interfaces and access to cameras, voice, and sensors, AIUI lets the same agent combine the right interaction and device capabilities for each context.

## What Is AIUI Mainly Used For?

In one sentence:

**AIUI is used to build interactive AI agents where AI does not just answer, but also understands, acts, and returns feedback.**

In a normal AI chat product, the interaction often stays in text: the user asks something, and the model replies.

In AIUI, after the user gives a request, the system can:

- understand what the user wants to do
- choose the right interaction form for that request
- call pages, components, network APIs, device features, or AI capabilities to complete the task
- return the result through UI, cards, state changes, voice, or other forms of feedback

That makes AIUI more suitable for products like these:

- intelligent agents that can both chat and operate through UI
- agents running on AI glasses, AR devices, or other smart terminals
- products that need both AI understanding and real interaction flows
- agents that need not only "answers", but also execution and feedback

## How Is AIUI Different from a Traditional App?

A traditional app framework mostly focuses on questions like:

- How should a page be written?
- How should data be updated?
- How should a button respond?

AIUI also cares about those things, but it goes further:

- What is the user's real intent right now?
- What is the right way to carry that intent?
- When should the system show UI, and when is a plain answer enough?
- When should it call AI, and when should it call device capabilities?
- Does the user need continuous feedback instead of a one-time result?

So AIUI is not only a "page development framework". It is better understood as an **intent-driven development framework**.

## What Is the Overall Architecture of AIUI?

At a high level, you can understand AIUI as four parts:

1. **Agent Definition**
2. **Interaction Interface**
3. **Runtime Logic**
4. **Underlying Capabilities**

These parts work together in one loop:

**The user makes a request -> the system understands the intent -> the agent decides how to handle it -> UI and capabilities complete the task together -> the result is returned to the user**

![The AIUI interaction loop from user request to feedback](../image/overview/interaction-loop.png)

This is not a pipeline that runs only once. The user can act on the feedback or clarify their intent, and the agent begins another cycle of understanding, execution, and feedback.

Here is what each part means.

### 1. Agent Definition

This part defines who the agent is, what it can do, what it is good at, and where its boundaries are.

For example:

- Is it a weather assistant or a navigation assistant?
- Is it good at searching information or controlling devices?
- What tone should it use when talking to users?
- When should it show UI, and when is a text response enough?

This is often described in files such as `AGENTS.md`.

You can think of it as: **setting the identity and working style of the agent**.

### 2. Interaction Interface

This part defines what the user sees, what they can tap, and how they continue the interaction.

In AIUI, the interface is not just decoration. It is part of the interaction itself. It can be:

- a card inside a chat
- a standalone page
- an at-a-glance Widget
- a panel of buttons
- a set of status hints
- a continuously updating task interface

In other words, UI in AIUI is not only for displaying content. It is used to carry user intent, collect user actions, and return system feedback.

### 3. Runtime Logic

This part defines how the system handles things internally.

For example:

- when a Page or Widget is shown
- which shared tasks an Agent Worker manages
- what should happen after the user taps a button
- how network data is requested
- how state is updated
- how new results are synced back to the interface

You can think of this as the brain and flow-control layer of the agent.

### 4. Underlying Capabilities

This part defines what real capabilities the system can use.

Examples include:

- AI capabilities: speech recognition, speech synthesis, large language models
- network capabilities: requesting remote APIs and getting real-time data
- device capabilities: connecting BLE peripherals, providing a Bluetooth GATT Server, reading sensors, and using cameras
- rendering capabilities: showing the interface efficiently on the device

If the interface is what users can see, and logic is what makes things work, then underlying capabilities are what make things actually possible.

## What Parts Does AIUI Include?

If you look at AIUI itself rather than the documentation structure, you can first understand it as six parts:

![The six core AIUI modules and how they relate](../image/overview/architecture.en-US.svg)

The diagram shows how these modules work together: the **Agent Framework** organizes the application, **Built-in Components** and **APIs** provide the interface and capabilities, and the **Ink Runtime** executes them. **Design Guidelines** and **Developer Tools** support the entire development process.

### 1. Agent Framework

This is the upper-level organization model of AIUI. It defines how an agent is described, how user intent is handled, and how pages, logic, and interaction flows are organized.

This layer answers questions like:

- What is an agent?
- How is user intent carried?
- What is the difference between conversational and immersive interaction?
- How are Pages, Widgets, Agent Workers, logic, and state organized together?

You can think of it as: **the structural model and interaction organization of AIUI**.

### 2. Agent Runtime (Ink)

This is the underlying runtime foundation of AIUI. It runs code, drives Pages and Widgets, and executes Agent Worker background tasks.

This layer answers questions like:

- Where does the code actually run?
- How are Page or Widget updates executed?
- How does the runtime connect UI, logic, and underlying capabilities?
- Why can AIUI run on AI glasses, AR devices, and similar terminals?

You can think of it as: **the execution engine of AIUI**.

### 3. Built-in Components

These are the ready-to-use UI components provided by AIUI to help developers build agent interfaces quickly.

Examples include:

- basic display components
- interactive components
- media components
- AI-related components

This part solves the problem of "how the interface is built". You do not need to build every interface from scratch each time.

### 4. API

These are the capability interfaces provided by AIUI for developers to call.

Examples include:

- networking
- storage
- device capabilities
- AI capabilities
- canvas and media capabilities

This part solves the problem of "what the agent can do". Components handle how the interface is shown, while APIs connect real capabilities into the system.

### 5. Design Guidelines

These are the basic visual, interaction, and device-experience rules of AIUI.

They help developers understand:

- how an interface should better fit AI interaction
- how information should be presented on AI glasses, AR devices, and similar scenarios
- what kinds of layout, hierarchy, and feedback work better for continuous interaction

This part solves the problem of "how to design a better and more usable agent".

### 6. Developer Tools

These are the supporting tools around the full AIUI development workflow.

Examples include:

- CLI
- debugging tools
- packaging and publishing tools
- performance analysis and diagnostics tools

This part solves the problem of "how to actually develop, debug, and ship an agent".

If you put these six parts together, you can understand them like this:

- **Agent Framework** decides how things are organized
- **Agent Runtime (Ink)** decides how things run
- **Built-in Components** decide how things are displayed
- **API** decides what the agent can do
- **Design Guidelines** decide how to design things better
- **Developer Tools** decide how things are developed and shipped

## The Simplest Way to Remember It

If all of the above still feels like a lot, remember this sentence first:

**AIUI = AI + UI + agent logic + device capabilities**

And one step further:

**AIUI is a development framework that brings AI into the real interaction flow of a product.**

It does not only make AI talk. It makes AI able to:

- understand what the user wants right now
- decide how to respond
- call the right interface and capabilities
- continuously return process and result feedback to the user

## What Should You Read Next?

If you finish this page, a good next reading order is:

1. **Concept Introduction**: understand the core terms first
2. **Project Structure**: learn how an AIUI project is organized
3. **Agent Framework**: understand the core way AIUI works
4. **Quick Start**: build your first AIUI agent

If you are still a beginner, that is completely fine. You do not need to understand every technical detail at once. As long as you first understand what AIUI is for, and then gradually learn how it works, you are already on the right path.
