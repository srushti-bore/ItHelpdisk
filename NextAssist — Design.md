# NextAssist — Design System (GSAP + Advanced UI/UX)

## 1. Purpose

This document defines the **visual design system, interaction patterns, and motion guidelines** for NextAssist.

The goal is to build a **premium, modern, human-first IT platform UI** that avoids generic SaaS design and delivers a smooth, high-quality experience.

---

## 2. Tech Stack Alignment

- **Frontend:** Flutter  
- **Backend:** FastAPI  
- **Motion System:** GSAP (GreenSock Animation Platform)

All animations must follow **GSAP-style timeline-based motion principles**, even when implemented in Flutter.

---

## 3. Design Philosophy

NextAssist UI must feel:

- Warm and tactile  
- Minimal but expressive  
- Spacious (NOT crowded)  
- Professional and premium  
- Non-generic  

### Core Rule:
> AI is assistive, not dominant in UI.

---

## 4. Color System (Pastel sRGB)

### ❌ Remove Completely:
- Green accent (too strong, visually dominant)
- Neon colors
- Over-saturated gradients

---

### ✅ Use:

Soft pastel palette derived from sRGB:

- Soft Lavender  
- Muted Blue  
- Warm Peach  
- Light Beige / Sand  

### Color Rules:
- Low saturation
- Soft contrast
- High readability
- Consistent tone across UI

---

## 5. Theme

### Primary Mode: Light Mode

- Background: Off-white / soft neutral
- Cards: Slight elevation
- Borders: Subtle (not heavy)

---

## 6. Liquid Glassmorphism (Controlled Usage)

Use glassmorphism only in selected areas:

### Allowed:
- AI Assistant Panel
- Modals
- Floating overlays

### Requirements:
- Background blur
- Transparency
- Soft glow edges
- Layered depth

### Avoid:
- Full-page glass UI
- Overuse (causes visual noise)

---

## 7. Layout & Spacing System (CRITICAL)

### Problem:
Design must NOT feel crowded.

---

### Rules:

#### Spacing System:
- Use 8pt / 12pt grid
- Maintain consistency

---

#### Padding:
- Cards: 16–24px minimum
- Sections: Large spacing
- Inputs: Comfortable interaction size

---

#### Layout Behavior:
- Avoid dense stacking
- Use whitespace intentionally
- Separate content clearly

---

## 8. Typography

- Clean sans-serif font
- Clear hierarchy

### Structure:
- Heading → bold
- Subheading → medium
- Body → readable spacing

### Avoid:
- Dense text blocks
- Small font sizes

---

## 9. GSAP Motion System

All animations must be:

- Smooth (60 FPS)
- Natural (ease-based)
- Purpose-driven

---

### 9.1 Motion Principles

- Motion guides attention
- Avoid unnecessary animation
- Keep interactions fast and fluid

---

### 9.2 Required GSAP Use Cases

#### Page Transitions
- Fade + slight movement
- No abrupt switching

---

#### Card Interactions
- Hover lift (subtle 3D)
- Shadow expansion
- Scale ≤ 1.02

---

#### AI Panel
- Smooth expand/collapse
- Blur + slide animation

---

#### Case Timeline
- Progressive reveal
- Step-by-step animation

---

#### Loading States
- Skeleton loaders
- Shimmer effect
- Avoid spinners

---

## 10. 3D Interaction Layer

### Goal:
Subtle depth, not heavy 3D.

### Use:
- Card tilt
- Layered shadows
- Depth perception

### Avoid:
- Heavy 3D rendering
- Performance-heavy visuals

---

## 11. Interaction Design

Every user action must have feedback:

- Hover state
- Click response
- Success / error indication

### Rule:
> No silent interactions.

---

## 12. AI UX Integration

- AI appears as assistive components
- No full-screen takeover
- Clearly marked suggestions
- Always editable by user

---

## 13. Case Screen Layout

### Structure:

Left Panel:
- Case details
- Metadata

Right Panel:
- Activity timeline
- Internal notes
- AI assistant

---

### Goal:
Balanced, clean, non-cluttered layout

---

## 14. Anti-Generic Design Rule (VERY IMPORTANT)

The UI must NOT look like:

- Generic admin dashboards  
- Template-based SaaS UI  
- ChatGPT-style interfaces  

---

### Instead:

Create a unique identity using:

- Spacing  
- Motion  
- Soft color palette  
- Depth and layering  

---

## 15. Performance Rules

- Optimize all animations
- Avoid layout shifts
- Maintain fast response time
- Do not block UI interactions

---

## 16. Accessibility

- Maintain readable contrast
- Use proper text sizes
- Support keyboard navigation
- Do not rely only on color

---

## 17. Final Design Goal

NextAssist should feel like:

> A premium, modern, human-first IT platform  
> — not just another dashboard.

---