# Emberwick — Phases & Roadmap
### Doc 3 of 3

Companion to **Doc 01 (Product Guide)** and **Doc 02 (Design & Technical Spec)**.

> **Prototype reference.** `prototype.html` is for **flow and initial UI only** — it lacks several animations that will be built natively in SwiftUI (see Doc 02 §4.2). Don't copy it 1:1; UI evolves on the go.

---

## Phase 1 — v1 (locked scope)

The goal of v1 is a complete, warm, genuinely usable app with the full core loop — buildable solo, demoable, and shippable to the App Store.

- **Grid** — full-life grid, home view, with **day-of-year** week mapping (Doc 02 §1.1).
- **One `Entry` model** — `win` / `loss` / `note`, each with title + optional notes + optional images.
- **Tap any week** → **calm, full-screen, dateless** week page; view + add entries.
- **Eras as tinted bands** — create era (name, start, end) → tints its band. No resize/overlap/nesting yet.
- **Win tiers** — optional, one-tap, **bronze / silver / gold / diamond** (diamond rare). Drives grid glow + reveal effect.
- **The Jar** — bottom-bar mode, **all-time scope**, **weighted shake** (favor long-unseen) + tap fallback, tier-scaled reveal, "add a win." Never deletes.
- **Adaptive home + Settings override** — Jar-first until a win-count threshold, then grid; Settings = Default / Jar / Grid.
- **Hidden win count** until a threshold (warm subtitle instead) so sparse early grids don't demotivate.
- **"You did this a year ago"** resurfacing — own past win, not quotes.
- **Zoom navigation** — tap any cell + pinch, life → year → week (with the SwiftUI motion upgrades in Doc 02 §4.2).
- **Images on wins.**
- **Local storage: SwiftData.**
- **Warm visual system** per Doc 02 §3 (Emberwick palette + Gabarito/DM Sans + glow).

**Onboarding (in v1):** first run lets the user drop a handful of milestone wins ("graduated / moved / met them") so the map feels alive on day one and teaches the mechanic without a tutorial. (For any demo: pre-seed a persona so the mature, glowing grid is visible.)

---

## Phase 2 — fast-follow (high value, post-launch)

- **CloudKit sync** (SwiftData built-in) — cross-phone restore on Apple ID.
- **Manual export** (JSON + images) — trust/safety valve.
- **Loss → win threads** — link an entry to a later one; the grid draws a faint thread (hard week + its resolution).
- **Negative-space prompts** — occasionally ask about a *specific* lived-but-empty week near an era boundary.
- **Year in Review / replay** — optional, un-dated, non-destructive scroll-back through a year's or era's wins.
- **Resurfacing widget** — Lock Screen widget occasionally showing one past win.
- **Share-sheet capture** — "add to jar" from anywhere; turn an existing photo into a win in one tap.
- **Richer era treatment** — era color as a narrative band system.

---

## Phase 3 — later / nice-to-have

- **iPad layout.**
- **Deeper motion** — particle systems, elaborate reveals.
- **Optional perspective mode** — the "weeks remaining" memento-mori view, strictly opt-in.
- **Calendar-accurate weeks** — if/when we move off pure divide-logic, week pages could safely show dates.

---

## Known risks

- **Back-loaded payoff / cold start.** A new grid is nearly empty; the "constellation" magic is months away. *Mitigations:* milestone-backfill onboarding, Jar-first adaptive default, negative-space prompts, demo persona.
- **Feel over features.** The app lives on polish — the shake, the reveal, the zoom. Mediocre execution = "just a notes app." Craft is the product.
- **Scope sprawl.** It's quietly a life-journaling app with a memory-resurfacing engine — a bigger, better idea than "grid + jar." Hold the v1 line.
- **Tone drift.** Guard "warm, not morbid" at every step, especially losses and any perspective feature.
- **Divide-logic vs calendar.** v1 intentionally uses day-of-year buckets, so week pages omit dates to avoid mismatches. Don't surface dates until this is reconciled (Phase 3).

---

## Open questions

- **Win-count threshold** (Jar → Grid switch): suggest ~15–25.
- **Win-count display threshold** (hide count until): suggest 50 or 100.
- Weighted-shake recency curve strength.
- Final micro-copy for onboarding, empty states, and the warm home subtitle.
- App Store Connect **name reservation** + trademark check for **Emberwick** before launch.

---

## Suggested build order (SwiftUI)

1. **Grid math first** — `Entry` model + day-of-year mapping + render the full-life grid from sample data. This underpins everything.
2. **Zoom navigation** — tap + `matchedGeometryEffect` life → year → week; add `MagnificationGesture`.
3. **Week page** — dateless, entry list, add/edit entries (win/loss/note, notes, images, optional tier).
4. **Eras** — create + tint bands behind the grid.
5. **The Jar** — all-time weighted shake, tier-scaled reveal, CoreHaptics.
6. **Home logic** — adaptive Jar-first + Settings override; hidden win count.
7. **Resurfacing** — "you did this a year ago."
8. **Polish pass** — the SwiftUI motion upgrades (Doc 02 §4.2), reduced-motion, empty states, onboarding, icon.
9. **Ship** — App Store metadata, privacy (on-device), TestFlight, submit.
10. **Phase 2** — CloudKit sync + export first.
