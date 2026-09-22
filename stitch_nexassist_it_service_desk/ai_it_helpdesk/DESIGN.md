---
name: AI IT Helpdesk
colors:
  surface: '#fdf9f5'
  surface-dim: '#ddd9d6'
  surface-bright: '#fdf9f5'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f7f3ef'
  surface-container: '#f1edea'
  surface-container-high: '#ece7e4'
  surface-container-highest: '#e6e2de'
  on-surface: '#1c1b1a'
  on-surface-variant: '#464651'
  inverse-surface: '#31302e'
  inverse-on-surface: '#f4f0ec'
  outline: '#767682'
  outline-variant: '#c7c5d3'
  surface-tint: '#5057a7'
  primary: '#5057a7'
  on-primary: '#ffffff'
  primary-container: '#8c93e8'
  on-primary-container: '#212878'
  inverse-primary: '#bec2ff'
  secondary: '#894f3c'
  on-secondary: '#ffffff'
  secondary-container: '#fdb29a'
  on-secondary-container: '#794230'
  tertiary: '#386665'
  on-tertiary: '#ffffff'
  tertiary-container: '#74a2a1'
  on-tertiary-container: '#013838'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#e0e0ff'
  primary-fixed-dim: '#bec2ff'
  on-primary-fixed: '#050a62'
  on-primary-fixed-variant: '#383e8d'
  secondary-fixed: '#ffdbd0'
  secondary-fixed-dim: '#ffb59d'
  on-secondary-fixed: '#360e03'
  on-secondary-fixed-variant: '#6d3827'
  tertiary-fixed: '#bcecea'
  tertiary-fixed-dim: '#a0cfce'
  on-tertiary-fixed: '#002020'
  on-tertiary-fixed-variant: '#1e4e4d'
  background: '#fdf9f5'
  on-background: '#1c1b1a'
  surface-variant: '#e6e2de'
typography:
  headline-xl:
    fontFamily: Space Grotesk
    fontSize: 36px
    fontWeight: '500'
    lineHeight: 44px
  headline-xl-mobile:
    fontFamily: Space Grotesk
    fontSize: 28px
    fontWeight: '500'
    lineHeight: 34px
  headline-lg:
    fontFamily: Space Grotesk
    fontSize: 28px
    fontWeight: '500'
    lineHeight: 34px
  headline-md:
    fontFamily: Space Grotesk
    fontSize: 22px
    fontWeight: '500'
    lineHeight: 28px
  headline-sm:
    fontFamily: Space Grotesk
    fontSize: 18px
    fontWeight: '500'
    lineHeight: 22px
  headline-xs:
    fontFamily: Space Grotesk
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 20px
  body-lg:
    fontFamily: Public Sans
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 21px
  body-md:
    fontFamily: Public Sans
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 19px
  body-sm:
    fontFamily: Public Sans
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 17px
  label-md:
    fontFamily: Public Sans
    fontSize: 13px
    fontWeight: '500'
    lineHeight: 18px
  label-sm:
    fontFamily: Public Sans
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
  mono-data:
    fontFamily: Space Grotesk
    fontSize: 13px
    fontWeight: '500'
    lineHeight: 16px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1rem
  gutter-tablet: 1rem
  gutter-desktop: 1.5rem
  margin: 1rem
  margin-tablet: 1.5rem
  margin-desktop: 2rem
  space-2xs: 0.25rem
  space-xs: 0.5rem
  space-sm: 0.75rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2rem
  space-2xl: 3rem
---

## Brand & Style

This design system delivers a quiet, utilitarian, and high-trust environment tailored for high-volume IT service desk operations. Built around the principles of editorial clarity, architectural precision, and functional calm, it rejects the sensory noise common in contemporary enterprise software.

The aesthetic combines modern minimalism with low-contrast precision:
- **Atmospheric quiet:** The interface functions like technical paper or archival engineering documentation. High visual noise, decorative gradients, glowing effects, and visual gimmicks are strictly banned.
- **Dignified intelligence:** Machine-generated suggestions are presented as calm peer contributions rather than speculative novelties. AI presence is indicated solely through structural anchors—a 2px left accent border and an understated sentence-case label. Sparkles, purple neon washes, and energetic badges are forbidden.
- **Strict sentence case:** All typographic elements—including primary actions, status labels, headers, and metadata—follow natural sentence case. Uppercase tracking and title-cased buttons are prohibited to sustain an unobtrusive, human-scale tone.
- **Tactile structure over illusion:** Spatial differentiation is achieved using precise 1px hairline rules and restrained structural tiers rather than ambient drop shadows or floating elevations.

## Colors

The palette uses low-saturation mineral and paper tones designed to minimize cognitive fatigue during extended operational shifts. 

### Critical Palette Rules
- **Total Green Prohibition:** Green is entirely eliminated across all UI surfaces, tokens, and semantic states. Successful resolutions, healthy services, and positive metrics are represented exclusively by muted slate-teal (`#6E9C9B`) paired with its paper tint (`#DDEBEA`).
- **Surface Foundations:** The default canvas is light mode, grounded in warm paper white (`#F7F6F3`) with pure flat white container surfaces (`#FFFFFF`) defined by warm neutral hairline borders (`#E7E4DC`).
- **Dark Mode Surfaces:** Dark mode transitions to `#17181B` base canvas, `#1F2023` containers, and `#2C2D31` hairline framing.
- **Typography Tones:** High-contrast text uses `#2B2A28` (light) or `#EDEBE6` (dark). Muted annotations, labels, and secondary metadata use `#6B6862` (light) or `#A3A19B` (dark).
- **Semantic Accents:**
  - Primary / Focus / AI Anchor: Dusty periwinkle-indigo `#8C93E8` (tint `#E4E6FA`, dark mode accent `#A9AFF0`).
  - Secondary / System Info: Muted clay-coral `#E39B84` (tint `#F7E5DE`).
  - Warning: Dusty amber `#E3B15C` (tint `#F8ECD6`).
  - Critical / Danger: Desaturated rose `#D8848C` (tint `#F6DEE1`).
  - Resolved / Operational Health: Muted slate-teal `#6E9C9B` (tint `#DDEBEA`).

## Typography

Typography balances systematic readability with technical structure. We employ `Space Grotesk` for headlines, numeric identifiers, ticket reference IDs, and telemetric counters, while `Public Sans` serves as the neutral, highly legible engine for long-form dialogue, body updates, and input controls.

### Structural Typographic Rules
- **No All-Caps:** Never render labels, tags, or table headers in full uppercase. Never use tracked-out letterspacing on section headers.
- **Pure Sentence Case:** Every text element—from button interactions (`Save changes`, `Assign ticket`) to system headers (`Active incident overview`)—is rendered in clean sentence case.
- **No Middle-Dot Meta Delimiters:** Do not use `·` or `•` to divide sequential metadata. Use visual spacing, distinct grid cells, or subtle 1px vertical borders (`#E7E4DC`) to separate author names, dates, and status codes.
- **Data & Identifiers:** Space Grotesk handles tabular numeric data and ticket handles (e.g., `inc-4082`, `84.2 ms`) to maintain monospaced optical grounding without disrupting line cadence.

## Layout & Spacing

The layout is governed by a disciplined 8px dimensional framework. Every gap, margin, inner padding, and container boundary maps cleanly to intervals of 4px and 8px.

### Layout Philosophy
- **Responsive Fluid Canvas:** The desktop interface employs a multi-pane operational console: a fixed 240px contextual tool navigation panel, an adjustable 360px–420px queue list, and a flexible primary triage workspace.
- **Grid Architecture:** 
  - Mobile (<768px): 4-column layout, 16px margins, 16px gutters. Single column stacked drill-down views.
  - Tablet (768px–1023px): 8-column layout, 24px margins, 16px gutters. Split master-detail navigation.
  - Desktop (≥1024px): 12-column layout, 32px canvas margins, 24px column gutters. Full persistent tri-pane workbench.
- **Rhythm & Padding:**
  - Micro-spacing (`space-2xs` [4px], `space-xs` [8px]): Used strictly for tight inline icon pairings, chip interior padding, and grouped metadata.
  - Component-level spacing (`space-sm` [12px], `space-md` [16px]): Applied as inner padding for inputs, list items, and actionable controls.
  - Structural spacing (`space-lg` [24px], `space-xl` [32px]): Canvas tier separation, modal interior padding, and major workspace segmentation.

## Elevation & Depth

This design system avoids decorative depth illusions. Shadow-based drop elevations are completely absent in standard states.

### Architectural Depth System
1. **Zero-Elevation Base:** Workspaces sit flat on `#F7F6F3`. Containers, ticket details, and contextual panels do not hover; they are demarcated by flat white surfaces (`#FFFFFF`) bordered with a crisp, non-retina 1px hairline rule in `#E7E4DC`.
2. **Layer Separation via Tonal Framing:** Layered elements (drawers, inspection sidebars) sit directly adjacent to primary work areas separated by a vertical 1px border. Dark mode mirrors this using `#17181B` (base), `#1F2023` (surface), and `#2C2D31` (hairline border).
3. **Overlays & Dialogs:** Modals and utility dropdowns use a single, restrained, structural shadow purely to decouple the overlay from live input fields: `0 4px 16px rgba(43, 42, 40, 0.06)`, framed by an explicit 1px hairline border in `#E7E4DC`.
4. **Interactive States:** Surface elevation does not shift on hover. Hover states are expressed purely through subtle background color shifts (e.g., `#FFFFFF` to `#F7F6F3`) over 120ms transitions.

## Shapes

The geometric framework is calculated, understated, and functional. Geometry reflects a calibrated tool rather than a consumer novelty.

### Geometry Specifications
- **Interactive Controls & Inputs:** All base buttons, text inputs, selects, and filter tags use an exact `8px` corner radius. This gives form fields a structured, approachable contour without appearing toy-like or spherical.
- **Structural Containers:** Cards, detail panels, system tables, code snippets, and modal dialogs use an exact `12px` corner radius.
- **Status Pills:** Status chips and role identifiers feature a gentle, contained curve matching the control radius (`8px`) or fully rounded pill geometry (`9999px`) only when indicating immutable state tags.

## Components

### 1. Buttons
- **Style:** Flat, clean, single-layer. Never include trailing arrow glyphs (`→`, `›`, `chevron-right`). Text is always sentence case.
- **Primary:** Background `#8C93E8`, text `#FFFFFF`, border none. Hover: `#7980D4`. Active: `#686EC4`.
- **Secondary / Default:** Background `#FFFFFF`, text `#2B2A28`, 1px border `#E7E4DC`. Hover: Background `#F7F6F3`, border `#DCD9D0`.
- **Destructive:** Background `#F6DEE1`, text `#D8848C`, 1px border `#F1CBD0`. Hover: Background `#EFC7CC`.
- **Micro-interaction:** Transitions strictly timed to `120ms ease-out`.

### 2. Status Chips & Badges
- **Structure:** Tint background + 6px saturated solid circular dot + saturated semantic label. No borders, no icons, no all-caps text.
- **Resolved / Stable / Active (No Green Allowed):** Background `#DDEBEA`, dot `#6E9C9B`, text `#4D7574`.
- **Warning / Degraded:** Background `#F8ECD6`, dot `#E3B15C`, text `#966F2A`.
- **Critical / Blocker:** Background `#F6DEE1`, dot `#D8848C`, text `#96474E`.
- **Pending / Info:** Background `#F7E5DE`, dot `#E39B84`, text `#965743`.

### 3. AI Drafting & Suggestion Blocks
- **Structure:** Surfaces containing algorithmic triage notes, ticket classifications, or drafted solutions are visually calm. 
- **Anchoring:** A flat white card (`#FFFFFF`) or tinted canvas (`#FBFBF9`) with an unadorned 2px solid left border in primary accent `#8C93E8`.
- **Labeling:** Preceded exclusively by an unstyled sentence-case descriptor in secondary text (`#6B6862`): `AI suggestion` or `AI draft`.
- **Strict Prohibition:** Absolutely no sparkles, wizard icons, stars, or gradient badges.

### 4. Input Fields & Form Controls
- **Text Inputs:** Height 36px (compact) or 40px (standard). Background `#FFFFFF`, border 1px solid `#E7E4DC`, text `#2B2A28`, border-radius 8px, padding 0 12px.
- **Focus State:** 1px solid `#8C93E8` with a flat 2px unblurred outer ring `#E4E6FA`. No heavy ambient glow.
- **Checkboxes & Radios:** Hairline frame `#DCD9D0`, checked fill `#8C93E8` with a crisp white tick or inner pip. 

### 5. Cards & Tables
- **Cards:** Background `#FFFFFF`, border 1px solid `#E7E4DC`, border-radius 12px, inner padding 16px. No ambient shadow.
- **Data Tables:** Outer border 1px solid `#E7E4DC`. Header row background `#F7F6F3`, text `#6B6862`, font Space Grotesk, 12px, sentence case. Row dividers 1px solid `#E7E4DC`. Row hover: `#FAF9F7` transition 120ms.