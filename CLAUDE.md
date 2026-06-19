<!-- @gumgum/resonance:start -->
## @gumgum/resonance — Design System Integration

This project uses the @gumgum/resonance design system. Claude Code must follow the DS component-first build methodology. The DS ships 78 components, a full skill system, and enforcement hooks. **Read this entire section carefully — it contains compaction-resistant rules that govern all UI work.**

### Setup (React Projects)

Every React app using resonance needs three things:

1. **CSS** — import the complete stylesheet:
   ```ts
   import '@gumgum/resonance/styles.css'
   ```

2. **Fonts** — load Mulish in your HTML `<head>`:
   ```html
   <link rel="preconnect" href="https://fonts.googleapis.com" />
   <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
   <link href="https://fonts.googleapis.com/css2?family=Mulish:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet" />
   ```

3. **ResonanceProvider** — wrap your app:
   ```tsx
   import { ResonanceProvider } from '@gumgum/resonance'
   import defaultFoundation from '@gumgum/resonance/foundation.json'
   <ResonanceProvider config={defaultFoundation}><App /></ResonanceProvider>
   ```

**CRITICAL**: Never hand-roll a ResonanceConfig. Always import the default from the package.
**CRITICAL**: Never use `html/resonance.css` for React projects — that's a subset for static HTML only.

---

### Design System Skill Loading (MANDATORY)

**You MUST read design system skills before writing any `.tsx`/`.jsx` file that uses DS components.** A hook will BLOCK your first UI file write until you do.

**Route through the orchestrator — do NOT pick skills manually:**

1. Read `node_modules/@gumgum/resonance/skills/resonance.md` — the master orchestrator
2. Follow its **Step 1** (boot foundations) and **Step 2** (route to the correct process skill based on the task)
3. The process skill owns the full loading cascade — it tells you which foundation, pattern, component, and critique skills to load
4. Read the component usage skill for each component you plan to use: `node_modules/@gumgum/resonance/skills/components/<group>/<component>.md`

**Pattern skills are critical for layout quality.** The orchestrator routes to these, but if you're building a page, make sure you load the relevant pattern:
- Dashboard → `skills/patterns/dashboard-layout.md`
- Data table page → `skills/patterns/data-table.md`
- Form → `skills/patterns/form-layout.md`
- Settings → `skills/patterns/settings-page.md`
- Detail/entity page → `skills/patterns/detail-page.md`
- CRUD lifecycle → `skills/patterns/crud-resource.md`
- Empty states → `skills/patterns/empty-state.md`
- Full pattern index → `skills/patterns/index.md`

**After reading skills, signal completion for each file you'll edit:**
```bash
touch /tmp/.gg-skills-loaded-$(basename "$PWD")-<ComponentName>
```
Where `<ComponentName>` is the basename (without extension) of the file being edited. Per-file markers expire after 10 minutes.

---

### Design Principles (Compaction-Resistant)

These principles govern ALL UI decisions. They survive context compaction — re-read them if you're unsure:

1. **80/20 Rule** — 80% neutral (gray, surface, ink). 20% bold (brand color, accent). Most of the page is calm. Color is reserved for emphasis, status, and interaction.

2. **Hierarchy Through Typography, Not Container Inflation** — Create visual hierarchy with heading levels, font weight, and text size — NOT by making cards bigger, adding borders, or spanning grid columns. Three cards with the same layout but different heading sizes convey hierarchy. One card spanning 2 columns does not.

3. **Containers Own Layout; Primitives Own Styling** — `Flex`, `Grid`, `Container`, `Section` control spacing and arrangement. `Text`, `Heading`, `Badge`, `Icon` control appearance. Don't put layout concerns on primitives (`Text` with `display:flex`) or styling on containers (`Flex` with `background`).

4. **Trust the Component** — DS components know their own defaults. NEVER re-declare spacing, sizing, or styling that a component already provides. If `Card.Container` is already `flex-direction: column` with gap, don't wrap its children in another `Flex direction="column"`. If `Badge` has `width: fit-content`, don't add it again.

5. **Realistic, Dense Content** — UI mockups must have realistic data: full names, real dates, plausible numbers, 4-6 items in lists (not 2), descriptive labels. Sparse placeholder content ("Item 1", "Lorem ipsum", single-word labels) is a quality failure.

6. **Select is the Default Dropdown** — `Select` (Radix-based, styled) is the default choice. `NativeSelect` only when: (a) native mobile OS picker required, or (b) SSR without JS hydration.

---

### Type Scale (Compaction-Resistant)

| Level | Component | Size | Weight | Use For |
|-------|-----------|------|--------|---------|
| H1 | `<Heading as={1}>` | 3rem (48px) | 900 Black | Page hero titles |
| H2 | `<Heading as={2}>` | 3rem (48px) | 700 Bold | Major sections |
| H3 | `<Heading as={3}>` | 2rem (32px) | 500 Medium | Page titles (most common) |
| H4 | `<Heading as={4}>` | 1.5rem (24px) | 600 SemiBold | Card titles, subsections |
| H5 | `<Heading as={5}>` | 1.25rem (20px) | 800 ExtraBold | Small section headers |
| H6 | `<Heading as={6}>` | 0.875rem (14px) | 600 SemiBold | Label-like headings |
| subhead | `<Text size="subhead">` | 1.125rem (18px) | 600 | Lead paragraphs |
| body | `<Text>` (default) | 1rem (16px) | 400 | Body text |
| label | `<Text size="label">` | 0.875rem (14px) | 600 | Form labels, table headers |
| caption | `<Text size="caption">` | 0.75rem (12px) | 400 | Metadata, timestamps |

**A typical page uses H3 (page title), H5 (section headers), body (content), label (form labels), caption (metadata).** Using H1-H2 for page titles is almost always too large.

---

### Spacing Scale (Compaction-Resistant)

4px base grid. All spacing is a multiple of 4px.

| Token | Size | Common Use |
|-------|------|------------|
| `2xs` | 4px | Icon-to-label gaps |
| `xs` | 8px | Compact gaps, badge padding |
| `sm` | 12px | Inner component spacing |
| `md` / `"3"` | 16px | Standard gaps, card padding |
| `lg` / `"4"` | 24px | Default card padding, section padding |
| `xl` | 32px | Section gaps, page margins |
| `2xl` | 48px | Major section breaks |

**Layout component gap props use numeric scale:** `gap="2"` = 8px, `gap="3"` = 12px, `gap="4"` = 16px, `gap="6"` = 24px, `gap="8"` = 32px.

**Typical page rhythm:** `gap="6"` between sections, `gap="4"` between cards/groups, `gap="3"` within cards, `gap="2"` for inline label+value pairs.

---

### Quick API Reference (Compaction-Resistant)

These survive context compaction — reference them constantly:

**Typography:**
- `<Heading as={3}>` — NOT `level={3}`. Type: `1|2|3|4|5|6`
- `<Text color="muted">` — NOT `color="gray"`. Semantic colors: `'ink'|'muted'|'primary'|'secondary'|'destructive'`
- `<Text size="label">` — NOT `size="sm"`. Sizes: `'caption'|'label'|'body'|'subhead'`

**Layout:**
- `<Flex direction="column" gap="4">` — vertical stack with 16px gap
- `<Flex align="center" justify="between">` — horizontal row, centered, space-between
- `<Grid columns="3" gap="4">` — 3-column grid with 16px gap
- `<Container size="lg" py="8" px="6">` — max-width container with padding
- `<Section mb="8">` — semantic section wrapper with bottom margin
- `<Box p="4">` — generic box with padding

**Data Display:**
- `<Badge intent="success">` — Status: `'neutral'|'info'|'success'|'warning'|'error'`
- `<Badge color="emerald">` — Palette: 8 colors (emerald, sky, coral, tangerine, marigold, agave, lilac, gray)
- `<Card variant="default">` — `'default'|'elevated'|'interactive'|'classic'|'ghost'`. Default is the most common — don't overuse `elevated`.
- `<Tag>` — removable label. `<Badge>` — status indicator. Don't confuse them.

**Forms:**
- `<Button size="lg">` — Size5: `'xs'|'sm'|'md'|'lg'|'xl'`
- `<Input>`, `<Select>`, `<Button>` share height scale. **Adjacent controls MUST use the same size.**
- `<Select>` is the default dropdown (not `NativeSelect`)

**Icons:**
- `<Icon icon={GearSix}>` — NOT `name="GearSix"`. The `icon` prop takes a **Phosphor component reference**, not a string. Import from `@phosphor-icons/react`. There is NO `name` prop — using it crashes at runtime.

**Feedback:**
- `<Spinner size="lg">` — Size3: `'sm'|'md'|'lg'`
- `<Callout intent="warning">` — `'info'|'success'|'warning'|'error'`
- `<Separator />` — use between logical sections inside cards or pages

**Tokens:**
- All colors via `var(--gg-color-*)` — NEVER raw hex
- All spacing via `var(--gg-space-*)` or component props — NEVER raw px
- All font sizes via `var(--gg-fs-*)` — NEVER raw rem/px

---

### Anti-Patterns (NEVER Do These)

These are the most common mistakes. Violating any of these is a quality failure:

1. **NEVER use `<Icon name="...">`** — The Icon component has NO `name` prop. Use `<Icon icon={ComponentRef}>` with an imported Phosphor component.
2. **NEVER use raw HTML where DS components exist** — No `<h1>`, `<p>`, `<button>`, `<input>`, `<select>`, `<table>`, `<textarea>`. No `<div style={{display:'flex'}}>`. Use DS components.
3. **NEVER use raw hex colors** — No `#00CE7C`, no `rgb()`. Use `var(--gg-color-*)` tokens.
4. **NEVER wrap Card.Container children in a sole-child `<Flex direction="column">`** — Card.Container IS already `display:flex; flex-direction:column; gap`. Adding another flex column is redundant.
5. **NEVER add inline styles that echo component defaults** — If Card already has padding, don't add `style={{padding: ...}}`. Trust the component.
6. **NEVER add `border-left` or any single-side colored border accent** — Permanently banned. Use background tints, icon colors, or uniform borders for intent differentiation.
7. **NEVER use `NativeSelect` as the default dropdown** — Use `Select`. NativeSelect is only for native mobile pickers or SSR without JS.
8. **NEVER make a Card itself collapsible** — Cards are containers. If content needs expand/collapse, put an `<Accordion>` inside the Card.
9. **NEVER use H1/H2 for page titles in product UI** — H3 is the standard page title. H1/H2 are for hero/marketing sections.
10. **NEVER use sparse placeholder content** — "Item 1", "Lorem ipsum", 2-item lists. Use realistic names, dates, descriptions, 4-6 items.
11. **NEVER skip dark mode** — All UI must work in both light and dark themes. Test with `mode="dark"` on the provider.
12. **NEVER use grid-column spanning to create fake hierarchy** — Three equal cards with different heading sizes create hierarchy. One wider card does not.

---

### Self-Critique Gate (MANDATORY Before Completing UI Work)

Before marking any UI task as done, assess your output against these 5 axes. Fix any failures before proceeding:

1. **Component Coverage** — Is every visible element a DS component? Any raw `<div>`, `<span>`, `<h1>`, `<p>`, `<button>`? (Exception: custom chart internals, iframe containers.)
2. **Token Compliance** — Any raw hex colors, raw px values, raw rem font sizes? All visual values must use `var(--gg-*)` tokens or component props.
3. **Size Alignment** — Do adjacent form controls (Button, Input, Select) use the same `size` prop? Is the type hierarchy correct (H3 page title, H5 sections, body/label/caption content)?
4. **Layout Quality** — Is spacing consistent and rhythmic? Are Flex/Grid gaps using the standard scale (gap="2" through gap="8")? Is there enough content density (no sparse, undercooked pages)?
5. **Dark Mode** — Would this break in dark mode? Any hardcoded colors, white backgrounds, or ink-based overlays?

If any axis fails, fix it before proceeding. This is not optional.

---

### Core Rules

- **Use DS components** — never use raw HTML for things the DS provides (78 components)
- **Use CSS custom properties** — `var(--gg-*)` for all visual values, never raw hex/px
- **Use layout primitives** — `<Flex>`, `<Grid>`, `<Box>`, `<Container>`, `<Section>` instead of styled divs
- **Use DS typography** — `<Text>`, `<Heading>`, `<Code>` instead of raw HTML text elements
- **Use Phosphor Icons** — via `<Icon icon={Component}>` component, no other icon libraries
- **Route through the orchestrator** — `skills/resonance.md` decides what skills to load, not you

### Enforcement

Claude Code hooks in `.claude/hooks/` enforce these rules at the tool-call level. Hooks are installed as shims that delegate to `node_modules/@gumgum/resonance/claude/hooks/` — updating the package automatically updates enforcement behavior.

**Enforcement Pipeline (Edit/Write execution order):**

```
Edit/Write .tsx file
  → block-subagent-ui-writes.sh    (subagent? DENY)
  → require-design-brief.sh        (brief with 3+ DS tokens? DENY)
  → enforce-ds-usage.sh            (raw HTML, hex colors? DENY)
  → enforce-skill-context.sh       (per-file skill marker fresh? DENY)
  → [write happens]
  → post-write-dom-check.sh        (log, remind to verify; CRITICAL after 3+)
```

**Hook details:**

| Hook | Event | Behavior |
|------|-------|----------|
| `block-subagent-ui-writes.sh` | PreToolUse:Edit\|Write | **BLOCKS** subagent .tsx/.jsx writes in src/. Subagents lack DS context. |
| `require-design-brief.sh` | PreToolUse:Edit\|Write | **BLOCKS** component writes without a design brief file containing 3+ DS token references. |
| `enforce-ds-usage.sh` | PreToolUse:Edit\|Write | **BLOCKS** raw HTML elements, raw hex colors, `<Icon name=...>`. Exemptions: `// ds-exempt: <reason>` (line) or `/* ds-exempt-file: <reason> */` (file). Kill switch: `config.json → "enforce_ds_blocking": false`. |
| `enforce-skill-context.sh` | PreToolUse:Edit\|Write | **BLOCKS** UI writes until per-file skill marker exists. Markers expire after 10 minutes. |
| `enforce-skill-loading.sh` | PreToolUse:Agent | **BLOCKS** subagents that don't reference `skills/resonance.md`. |
| `trace-skill-loads.sh` | PostToolUse:Read | Logs skill file reads to `.lab/skill-traces/` for cascade analysis. |
| `post-write-dom-check.sh` | PostToolUse:Edit\|Write | Tracks unverified UI writes. After 3+ unverified, escalates to CRITICAL with mandatory visual verification checklist. |
| `annotate-cascade.sh` | Manual | Tags skill loading cascades with triggering prompt. Call before loading skills: `bash .claude/hooks/annotate-cascade.sh "<prompt>"` |

**Preset levels** (set via `npx @gumgum/resonance setup --preset=<level>` or `"resonance": {"enforcement": "<level>"}` in package.json):

| Preset | Active Hooks | Use Case |
|--------|-------------|----------|
| **strict** (default) | All 8 | Maximum quality enforcement |
| standard | 6 (no subagent block, brief, or dom check) | Teams comfortable with DS |
| lite | 2 (skill loading + DS usage only) | Quick start, non-UI-heavy projects |

For the full component inventory, decision tree, and critique protocol, read:
`node_modules/@gumgum/resonance/skills/process/build.md`
<!-- @gumgum/resonance:end -->
