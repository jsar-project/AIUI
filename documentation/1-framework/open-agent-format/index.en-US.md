# Open Agent Format

Open Agent Format, or OAF, is an open project format that uses directories and file conventions to describe an agent. Instead of treating an agent as a single prompt file, it breaks the problem into clear engineering layers: who the agent is, how it starts, how it interacts with users, and how its capabilities are reused.

In AIUI, Open Agent Format is not only a description spec, but also the scaffold that turns an agent into a runnable application. You can think of it as AIUI taking OAF and extending it from a static description into an AI-Native User Interface with pages, components, modules, and distributable packages.

## What It Actually Is

If an agent only exists as a block of text, it is hard to answer practical engineering questions such as:

- Where the agent identity, responsibility, and behavioral boundaries are declared
- Which entry point starts the application
- How pages are organized and what UI the user finally sees
- How reusable components, modules, and assets are split out
- How the same capabilities are migrated and reused across projects

Open Agent Format solves the organization problem behind those questions. It brings agent definition back into the file system itself, so the project structure becomes part of the agent definition.

In other words, OAF is not a single config file. It is an engineering-oriented organization model:

- `AGENTS.md` expresses the agent description layer
- `app.json` and the application entry express the runtime layer
- `pages/` expresses pages and interaction
- Components, modules, and packages express the reuse layer

## What AIUI Extends

Standard OAF focuses more on how to describe an agent. AIUI goes one step further and adds the layer that turns the agent into a UI application.

In AIUI, a complete OAF project usually contains at least these parts:

- `AGENTS.md`: defines agent identity, system instructions, capability boundaries, and collaboration constraints
- `app.json`: defines the application entry, page list, and global window configuration
- `pages/`: defines concrete pages, page lifecycle, events, and interaction logic
- `components/`: encapsulates reusable UI and local interaction units
- `modules/` or other regular module files: split business logic, utility functions, and asset imports
- `package.json` and package exports: distribute reusable capabilities to other AIUI applications

Because of this, Open Agent Format in AIUI can be understood as two connected layers:

- Description layer: what this agent is
- Application layer: how this agent is run, presented, and reused

That is also the biggest difference between AIUI and agent projects that only contain prompts or isolated configuration.

## How To Read The Structure

Here is a simplified example of an OAF / AIUI project:

```text
agent-app/
  AGENTS.md
  app.json
  app.js
  pages/
    home/
      index.ink
  components/
    agent-card.ink
  modules/
    format-message.ts
  package.json
```

Each layer answers a different question:

- `AGENTS.md`: who this agent is and how it should think and respond
- `app.json` / `app.js`: how the agent application starts and which global behaviors it owns
- `pages/`: which UI the user actually sees and interacts with
- `components/`: which UI fragments should be reused and encapsulated
- `modules/`: which logic, assets, or capabilities should be factored out
- `package.json`: which capabilities should be exposed as a package for other projects

If you think of AIUI as the framework that gives an agent a real UI, then OAF is the underlying file format that keeps that UI project organized.

## Why It Matters

The value of Open Agent Format is not in introducing another term. Its value is that it makes agent projects more readable, maintainable, and portable:

- The directory structure itself becomes documentation, which lowers handoff and collaboration cost
- The boundary between the description layer and the UI layer becomes clearer
- Pages, components, modules, and packages have explicit responsibilities, which helps long-term evolution
- Different platforms can map to the same structure more easily instead of hiding behavior in private configuration

This matters even more in AIUI, because AIUI is not built for agents that only answer with text. It is built for agent applications that can run pages, host interactions, and manage state.

## Continue Reading

- [AGENTS.md](/AIUI/framework/config-agents): learn how the agent description file defines identity, description, and instructions
- [app.json](/AIUI/framework/open-agent-format-app-json): learn how application entry, page lists, and global configuration work
- [Pages](/AIUI/framework/open-agent-format-page): learn how pages carry concrete UI, lifecycle, and interaction
- [Components](./custom-components): learn how reusable UI units are registered, composed, and connected
- [Modules](./module): learn how logic, assets, and WebAssembly are organized through modules
- [Packages](./package): learn how modules and components are packaged into distributable capabilities
