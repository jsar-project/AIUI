# AIUI Visual Design Language

> **Scope**: This design system currently applies only to **single-green
> monochrome display** devices — RokidGlasses1 / RokidGlasses2, whose hardware
> can reproduce only one luminous green channel over pure black. AIUI may add
> a separate full-color variant (e.g. `design-system-fullcolor.md`) in the
> future; until then, treat everything here as specific to the monochrome-green
> hardware, not as a general-purpose AIUI visual language.

This directory holds the **monochrome-green** visual design language for
**AIUI**. The `-monochrome` suffix on each file is intentional: it scopes the
content to single-color display hardware and leaves room for additional
display-type variants later.

## Files

| File | Purpose | Audience |
|------|---------|----------|
| [`design-system-monochrome.md`](./design-system-monochrome.md) | Full token spec for the single-green display: colors, typography, spacing, radii, border widths, component chrome, and Do's & Don'ts. The diff-able source of truth. | Contributors, designers, AI agents |
| [`preview-monochrome.html`](./preview-monochrome.html) | A self-contained, browsable visual showcase of every token and component. Open it directly in any browser — no build step. | Anyone who wants to see the system at a glance |

## Why a separate design language?

AIUI runs on transparent AR displays that can only render a single green
channel. That constraint shapes every decision here:

- **One hue, four opacity tiers** — hierarchy is expressed through green
  opacity on black, never through a second color.
- **Outlines, not shadows** — structure comes from clear borders and stable
  whitespace, because drop shadows read poorly on see-through displays.
- **Fixed canvas** — content is width-locked (480px) and height-capped
  (≤ 380px) to stay inside the user's comfortable field of view.
- **Errors stay green** — error states use a muted border + faint fill rather
  than red, which the hardware cannot reproduce.

See the [Do's & Don'ts](./design-system-monochrome.md#dos-and-donts) section
of the spec for the full set of rules.

## How it fits into the repository

| Audience | Where you meet the design language |
|----------|------------------------------------|
| AI agents (Claude Code, Cursor, Codex, …) | Bundled inside [`skills/aiui-dev/design-system-monochrome.md`](../skills/aiui-dev/design-system-monochrome.md) when installed via `npx skills add` |
| Human developers | This directory, linked from the root [`README.md`](../README.md) |
| Sample authors | Mirror these tokens when building pages under [`samples/`](../samples/) |

The copy at `skills/aiui-dev/design-system-monochrome.md` is intentionally
identical to `design-system-monochrome.md` here — it is bundled into the AI
skill so agents can align generated code with the same tokens without fetching
remote URLs. When you edit one, please update the other to keep them in sync.

## Future variants

This monochrome-green system is the *first* AIUI display-type variant. When
AIUI ships on full-color display hardware, the intent is to add a sibling
spec (e.g. `design-system-fullcolor.md` + `preview-fullcolor.html`) under
this same directory, sharing token structure but expanding the palette beyond
the single green channel.

## License

Apache License 2.0, inherited from the repository root.
