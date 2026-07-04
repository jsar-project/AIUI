# AIUI Visual Design Language

This directory holds AIUI's visual design language specs. Each spec is scoped
to a specific **display type**, because AIUI runs on hardware with very
different color reproduction capabilities.

## Layout

```text
design/
├── monochrome/          # single-color display specs (one channel on pure black)
│   ├── design-system-green.md
│   └── preview-green.html
└── fullcolor/           # planned — full-RGB display specs (not yet authored)
```

Today only the **monochrome-green** variant exists; the full-color area is
reserved for future hardware.

| Subdir | Display type | Status |
|--------|--------------|--------|
| [`monochrome/`](./monochrome/) | Single-color display (one channel on pure black) | Active — `green` hue variant available |
| `fullcolor/` | Full-RGB color display | Planned — not yet authored |

## Active spec

The monochrome-green system — for RokidGlasses1 / RokidGlasses2, whose
hardware can only reproduce one luminous green channel over pure black —
lives at:

- [`monochrome/design-system-green.md`](./monochrome/design-system-green.md) — full token spec
- [`monochrome/preview-green.html`](./monochrome/preview-green.html) — browsable visual showcase

See [`monochrome/README.md`](./monochrome/README.md) for details.

## How it fits into the repository

| Audience | Where you meet the design language |
|----------|------------------------------------|
| AI agents (Claude Code, Cursor, Codex, …) | Bundled as `skills/aiui-dev/design-system-green.md` via `npx skills add` |
| Human developers | This directory, linked from the root [`README.md`](../README.md) |
| Sample authors | Mirror these tokens under [`samples/`](../samples/) |

The skill copy is intentionally identical to
`monochrome/design-system-green.md` here, so agents can align generated code
without fetching remote URLs. When you edit one, update the other to keep
them in sync.

## License

Apache License 2.0, inherited from the repository root.
