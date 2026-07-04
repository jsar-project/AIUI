# AIUI Developer Tools & Skills

[简体中文](./README.zh-CN.md)

This repository provides developer tools, CLIs, and AI agent skills for building applications on **AIUI** (Artificial Intelligence User Interface) — an agentic runtime designed for AI glasses with displays.

## 🚀 Quick Start

### Create a new AIUI Agent

You can quickly scaffold a new AIUI Agent project using our official CLI tool. Run the following command and follow the prompts:

```bash
npm create @yodaos-pkg/aiui-agent my-agent
```

This will generate a ready-to-use AIUI project template including:
- `app.js` and `app.json` for global configuration.
- `AGENTS.md` for agent capability manifestation.
- A modern Single File Component (SFC) `index.ink` page setup.

## 🧪 Samples

The [`samples/`](./samples/) directory contains runnable example projects that demonstrate AIUI features and provide reference implementations for common UI patterns.

At the moment, the repository includes [`samples/capabilities/`](./samples/capabilities/), a complete sample app that you can use to explore page structure, assets, helper modules, and feature demos in one place.

- `pages/`: Example pages covering a range of AIUI capabilities and UI patterns.
- `assets/`: Static resources used by the demos, such as images, SVGs, and audio files.
- `lib/`: Helper modules shared by sample pages.

Representative demos inside `samples/simple/pages/` include:
- `layout`, `grid`, `position`: Layout and positioning patterns.
- `image`, `list`, `input_textarea`: Common UI building blocks.
- `canvas`, `canvas_api`, `chart`, `lottie`: Rendering and visual content examples.
- `media_query`, `css_vars`, `filter`, `transform`: Styling and responsive behavior examples.

## 🎨 Design System

The [`design/`](./design/) directory holds AIUI's visual design language specs. Each spec is scoped to a specific **display type** — the `-monochrome` suffix marks files that target single-color display hardware.

- [`design/design-system-monochrome.md`](./design/design-system-monochrome.md) — the **single-green monochrome** token spec, currently applicable to RokidGlasses1 / RokidGlasses2, whose hardware can only reproduce one luminous green channel over pure black. Covers colors (one green across four opacity tiers), typography, spacing, radii, border widths, component chrome, and Do's & Don'ts.
- [`design/preview-monochrome.html`](./design/preview-monochrome.html) — a self-contained, browsable visual showcase of the monochrome-green system. Open it directly in any browser; no build step required.

> This design system **currently applies only to single-green monochrome display devices**. A full-color variant (`design-system-fullcolor.md`) may be added in the future when AIUI ships on full-color display hardware.

The same monochrome-green spec is also bundled inside the `aiui-dev` skill (see below), so AI agents generating AIUI code align with these tokens automatically.

## 🤖 AI Agent Skills

We provide built-in instructions and context files to help LLMs (Large Language Models) or AI coding assistants write AIUI code effectively.

### Install via CLI

You can easily install the AIUI developer skill into your project using the `npx skills add` command. This will fetch the necessary context files and make them available to your AI coding assistant:

```bash
npx skills add https://github.com/jsar-project/AIUI/tree/main/skills/aiui-dev
```

If you want to install a specific released version of the skill instead of the latest `main` branch, replace `main` with the desired tag name:

```bash
npx skills add https://github.com/jsar-project/AIUI/tree/v0.1.0/skills/aiui-dev
```

- **`aiui-dev` Skill**: Located in [`skills/aiui-dev/SKILL.md`](./skills/aiui-dev/SKILL.md), this document contains comprehensive API references, project structure guidelines, and `.ink` SFC specifications. You can feed this file to your AI assistant to grant it the "skill" of developing AIUI applications.

## Feedback

If you'd like to request a feature or report a bug, please use the GitHub issue templates:

- [Feature Request](https://github.com/jsar-project/AIUI/issues/new?template=feature_request.yml)
- [Bug Report](https://github.com/jsar-project/AIUI/issues/new?template=bug_report.yml)

## Repository Structure

```text
.
├── design/
│   ├── design-system-monochrome.md  # AIUI monochrome-green visual design language (token spec)
│   ├── preview-monochrome.html      # browsable visual showcase of the monochrome system
│   └── README.md                    # one-page intro to the design language
├── packages/
│   └── create-aiui-agent/    # npm CLI for scaffolding AIUI agent projects
├── samples/
│   └── capabilities/         # runnable AIUI capabilities app and feature demos
├── skills/
│   └── aiui-dev/             # AI Agent skill documentation (SKILL.md)
└── .github/workflows/        # Automated daily build and publish workflows
```

## 📄 License

Apache License 2.0
