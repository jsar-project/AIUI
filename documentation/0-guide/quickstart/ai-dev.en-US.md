# Developing with AI

In Rokid AIUI agent development, using AI-assisted development has become the standard way to improve efficiency. By introducing the **AIUI Agent Development Skill**, you can enable your AI assistant to deeply understand AIUI framework conventions, component APIs, and best practices.

## Install the Skill

You can use the [vercel-labs/skills](https://github.com/vercel-labs/skills) ecosystem to integrate AIUI development capabilities into your project with a single command:

```bash
# Install the AIUI-related Skill into the current project
npx skills add https://github.com/jsar-project/AIUI/tree/main/skills/aiui-dev
```

## Features and Usage

`aiui-dev` is a professional Skill for AIUI agent development. It provides a complete AIUI development context for coding agents, so the AI does not just generate generic frontend code, but can assist according to AIUI project structure, page conventions, component systems, and design constraints.

### Core Capabilities
- **Understand AIUI project structure**: Recognizes core directories and configuration files such as `AGENTS.md`, `app.json`, `app.js`, `pages/`, `widgets/`, `workers/`, and `assets/`, helping you scaffold or organize AIUI projects.
- **Generate standards-compliant page code**: Understands the recommended `.ink` single-file component structure in AIUI, including `<script def>`, `<script setup>`, `<page>`, and `<style>`, making it suitable for directly generating page prototypes and business pages.
- **Handle page configuration and data modeling**: Can help you design page input structures and UI component contracts based on fields such as `page.json`, `description`, `schema`, and `data` in page definitions.
- **Write AIUI templates and styles**: Familiar with WXML data binding, conditional rendering, built-in components, and WXSS/Flexbox layout rules, allowing it to generate AIUI page structures and style code more accurately.
- **Use built-in AIUI components and APIs**: Covers common component capabilities as well as Web APIs and `wx.*` compatible APIs for scenarios such as network requests, voice, camera, Canvas, storage, and routing.
- **Follow AIUI design guidelines**: Understands AIUI constraints around sizing, card-based layout, primary colors, border radius, borders, and visual limitations for wearable scenarios, helping you generate interfaces that better fit the device experience.
- **Assist with debugging and migration**: Can provide advice that is closer to the actual runtime when troubleshooting AIUI pages, completing API calls, or migrating WeChat Mini Program-style code to AIUI.

### Install into a Coding Agent
You can install this Skill into the coding agent you are using through the `skills` command. `skills` supports project-level or global installation, and also supports installing into different agents.

- Use the `npx skills add ...` command above to install `aiui-dev` into the current project.
- If you want to learn about supported agents, installation methods, parameter options, and more usage details for `skills`, refer to [skills - npm](https://www.npmjs.com/package/skills).

After installation, the AI assistant can help you with page generation, API integration, style authoring, troubleshooting, and design alignment based on AIUI-specific context.
