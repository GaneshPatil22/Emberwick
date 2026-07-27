# Emberwick — Master Reference

> **Single source of truth** for building the Emberwick iOS app. Consolidates the three product docs (`files/Emberwick-01…03`) and the `files/prototype.html` reference. Read this first before touching code.
>
> **Context:** This is a **hackathon** build — UI/UX polish and "feel" are the product. Do NOT copy the prototype 1:1; it's a flow/look reference only. Build richer, native SwiftUI motion.

---

## 1. What Emberwick is

*"A wick carries the flame; each memory is a small light you keep lit."*

A merge of two ideas:
- **Life in Weeks** — your whole life as a grid, one box = one week (~90 rows = a life). Emotional but static; no reason to return.
- **The Jar** — collect tiny wins, shake to relive a random forgotten one. Real payoff but contextless.

**Core insight:** the Jar is the **input**, the grid is the **view**. Every moment lands on the week it happened. The grid slowly lights up; a shake surfaces a memory *with context* ("~2 years ago").

**Platform:** iOS, SwiftUI, iPhone-first (iPad later). Private, on-device first.

---

## 2. Guiding principles (protected decisions)

- **Warm, not morbid.** "Look how much good has happened + how much blank canvas is left." Never a death countdown. Same visual, opposite feeling.
- **One home, one mode.** The grid is home; the Jar is a *mode inside it*, not a co-equal second app.
- **No guilt.** No streaks, no nagging notifications, no obligation. Returning is a pleasure.
- **Motivation from your own life**, not a quote database.
- **Private by default.** On-device first; no feed, no accounts to start.

---

## 3. Core mental model

### 3.1 The grid
- One box = **one week**. 52–53 boxes/row, one row per **year**, ~90 rows for a full life.
- **Week → box mapping (day-of-year, NOT ISO weeks):**
  - `boxIndex = (dayOfYear − 1) / 7` (integer division). Range `0…52`.
  - Box 0 = Jan 1–7, box 1 = Jan 8–14, … box 52 = final 1–2 day sliver (2 days in leap years).
  - Every year restarts at box 0 on Jan 1 — a date can **never** leak into the prior row.
  - Rows run **birth year → birth year + 90**. Weeks before birth in the first row render as a quiet "before you" state.
  - **Why not ISO weeks:** they push early-January into the previous year's week 52/53.

### 3.2 Entries — ONE unified model
Do **not** build win/loss/note separately. One `Entry` with a `kind`:
- `kind`: `win` | `loss` | `note`
- Shared: `title` (required), `notes` (optional), `images` (optional), `date`
- `win`-only: `tier` (optional), Jar-eligible
- A **week is DERIVED, never stored** — all entries whose date maps to `(year, boxIndex)`.

### 3.3 The Jar
- The Jar **points at** wins (a lens); it never contains or deletes them.
- Shake = pick a random win from scope; **default scope = all-time** (never empty if ≥1 win).
- **Weighted** toward wins not seen in a long time (rediscover, don't replay).
- **Wins only** — losses/notes live in the week page, never shaken out.
- "Put it back" never deletes.

### 3.4 Eras
- **Era = a span** → soft, low-saturation horizontal tint band (background wash).
- **Win = a point** → bright, tier-colored box (foreground).
- Different **roles**, not shades of one palette. Eras stay quiet so wins always pop above.
- **v1:** create an era (name, start, end) that tints its band. No drag-resize, overlap rules, or nesting.

### 3.5 Visual grammar (box states)
| State | Look |
|---|---|
| Ahead (unlived) | Outline only |
| This week | Accent (raspberry-coral), gentle "beat" |
| Lived, no memory | Neutral fill |
| Lived, has memory | Tier color + soft glow |
| Inside an era | Soft tint band behind everything above |

---

## 4. Screens & flow (locked)

**Home logic:** Jar-first until a **win-count threshold**, then the full-life grid becomes home. Overridable in **Settings → Home mode: Default (adaptive) / Jar / Grid**. A **Map / Jar switch always sits in the bottom bar.**

```
        ┌────────── bottom bar: [ Map ] [ Jar ] ──────────┐
   [ Full-life grid ] ─tap cell / pinch out→ [ Year ] ─tap week / pinch out→ [ Week page ]
        ▲  ▲                                    │                              │
        └──┴──────────── pinch in / back ───────┴──────────────────────────────┘

   [ Jar ] ─shake (button or device)→ [ Reveal a random past win ] ─"put it back"→ [ Jar ]
```

- **Full-life grid (home when mature):** header title + warm subtitle, jar button top-right. **Win count hidden until a threshold** (warm line instead, so a sparse early grid doesn't demotivate). Legend order fixed: **bronze, silver, gold, diamond, this week, ahead.** Every cell tappable → zooms into its year.
- **Year:** that year's 52 weeks enlarged; title shows age (row-derived — safe). Tap any week → week page.
- **Week page:** **calm, full-screen, NO dates** (v1 divide-logic isn't calendar-accurate). Era chip, soft title, the week's entries (win with tier pill, note, hard-week quietly), "Add to this week."
- **Jar:** glass jar with glowing orbs; "Shake for a memory" (button + real device shake), "Add a win." Reveal = tier-scaled effect, "Put it back" (never deletes).

---

## 5. Visual system

Deliberately **NOT** the cream + serif + terracotta (#D97757) AI cliché. Warm and energetic; the four tiers ARE the palette, chrome stays warm-neutral, and **glow is the signature** (memories emit light; jar wins are glowing orbs).

### Palette
| Token | Hex | Use |
|---|---|---|
| paper | `#FDF6EE` | app background |
| paper-2 | `#FBEFE3` | raised warm surface |
| ink | `#34262C` | primary text |
| ink-soft | `#7B6A6F` | secondary text |
| ink-faint | `#A99AA0` | hints |
| accent | `#F0567A` | this week + primary actions (raspberry-coral) |
| accent-ink | `#B62E51` | text on accent tints |
| bronze | `#C0763A` | tier |
| silver | `#98A0AD` | tier |
| gold | `#F2A72C` | tier |
| diamond | `#31BFD6` | tier (rare) |

Supporting: `line = rgba(52,38,44,.10)`, `line-2 = rgba(52,38,44,.16)`. Body background is a soft radial `#EFE8DE → #E4DACE`.

### Type
- **Gabarito** — display / headings (600–800). Warm rounded, grown-up, not serif.
- **DM Sans** — body (400–500).

### Depth & shape
- Soft shadows and glows are fine (product surface, not flat claude.ai).
- Corners generous (14–24px).
- Tiers **locked**: bronze / silver / gold / diamond; diamond deliberately rare. Tier drives grid glow **and** reveal effect. Rating is **optional, one-tap, never forced.**

---

## 6. Animation & interaction spec

### 6.1 Already in prototype (reference feel)
- Grid entrance: staggered pop-in of cells.
- Ambient: this-week cell "beat," diamond cells "twinkle," jar orbs "bob," jar glow "breathe."
- Zoom: tap/pinch life → year → week (approximated via scale + fade + transform-origin at tapped cell).
- Jar: shake wobble → reveal with ripple + tier-colored glow + confetti burst scaled to tier; staggered haptics.
- Week page: entries rise staggered; press states.

### 6.2 MUST be added / upgraded in SwiftUI (NOT in prototype — this is the reason not to copy 1:1)
- **True continuous pinch-zoom** with `MagnificationGesture` (prototype uses a threshold flip).
- **`matchedGeometryEffect`** so a tapped week *is* the same square enlarged — a real "flight" life → year → week, not a cross-fade.
- **Spring physics** on all transitions (`.spring` / `.interactiveSpring`).
- **CoreHaptics** with **tier-specific patterns** (bronze subtle → diamond a rich flourish).
- **Richer reveal:** real particle/emitter (Canvas/TimelineView or SpriteKit), not DOM confetti.
- **Grid "lighting up"** micro-animation when a memory is added (box ignites into its tier color).
- **Reduced-motion** honored via `@Environment(\.accessibilityReduceMotion)`.

---

## 7. Data model (SwiftData sketch)

```swift
// One model for all three kinds — a week is DERIVED, never stored.
@Model final class Entry {
    var id: UUID
    var date: Date          // maps to (year, boxIndex) via day-of-year
    var kind: EntryKind     // .win / .loss / .note
    var title: String       // required
    var notes: String?      // optional — all kinds
    var imageData: [Data]   // optional — all kinds (heavy for sync; compress)
    var tier: Tier?         // wins only, optional
    // var linkedEntryID: UUID?   // Phase 2: loss → win threads
}

enum EntryKind: String, Codable { case win, loss, note }
enum Tier: String, Codable { case bronze, silver, gold, diamond }   // diamond rare

@Model final class Era {
    var id: UUID
    var name: String
    var startDate: Date
    var endDate: Date
    var tintHex: String     // soft, low-saturation
}
```

**Week derivation:**
```swift
func boxIndex(for date: Date, cal: Calendar = .current) -> Int {
    let doy = cal.ordinality(of: .day, in: .year, for: date)! // 1...366
    return (doy - 1) / 7   // 0...52
}
// row = year(date) - birthYear
```

---

## 7b. Engineering principles (how we write the code)

Follow these when writing Swift/SwiftUI — **but the top rule overrides all: do NOT over-engineer.** Apply each principle only where it earns its keep.

- **SOLID** — single-responsibility types, depend on abstractions only where a real seam exists (don't add protocols preemptively).
- **Pure functional core, impurity at the edges** — grid math, week derivation, and weighted-shake selection are pure functions of their inputs. Side effects (SwiftData writes, CoreHaptics, CoreMotion, PhotosPicker) are isolated at the boundary.
- **Immutability** — prefer `let` and value types; mutate through well-defined state.
- **DRY** — one source of truth for every rule (e.g. one `boxIndex` function used everywhere).
- **KISS** — simplest thing that works; reach for abstraction only on a second concrete use or a real testing need.
- **Constants for everything** — no magic values inline. Centralize design tokens (colors, fonts, paddings, corner radii, animation durations, sizes) and copy strings in a theme/constants layer. The §5 palette and type scale become named tokens.
- **swiftui-pro skill** — installed at `Emberwick/.agents/skills/swiftui-pro/`; iOS 26 target, Swift 6.2+, SwiftUI-first, one type per file, feature-based folders, modern APIs, HIG + accessibility.

**Guard against over-engineering:** for a solo hackathon v1, a clean constants file + pure math helpers + thin SwiftData layer is enough. Don't build a DI container, generic repositories, or a coordinator pattern unless a concrete need appears.

---

## 8. Frameworks

- **SwiftUI** — UI, grid, `matchedGeometryEffect`, `MagnificationGesture`, springs.
- **SwiftData** — persistence (+ CloudKit later).
- **CoreMotion** — shake-to-reveal (device shake).
- **CoreHaptics** — tier-specific haptics.
- **PhotosUI / PhotosPicker** — image attachment.
- **WidgetKit** — resurfacing widget (Phase 2).
- **CloudKit** — sync (Phase 2).

---

## 9. Backup / sync strategy

- **v1:** local **SwiftData**.
- **Fast-follow:** **CloudKit** via SwiftData built-in sync — free, private, no backend, native cross-device restore on same Apple ID.
- **Safety valve:** manual **JSON + images export** (trust feature).
- **Supabase:** only if Android/web or shared/multi-user later. **Images are the heavy part** of any sync — compress, store references.

---

## 10. Phases & roadmap

### Phase 1 — v1 (LOCKED scope)
Complete, warm, usable app with the full core loop — buildable solo, demoable, shippable.
- Full-life grid, home view, day-of-year mapping.
- One `Entry` model (win/loss/note + title + optional notes + optional images).
- Tap any week → calm, full-screen, **dateless** week page; view + add entries.
- Eras as tinted bands (name/start/end). No resize/overlap/nesting.
- Win tiers — optional, one-tap, bronze/silver/gold/diamond. Drives grid glow + reveal.
- The Jar — bottom-bar mode, all-time scope, weighted shake + tap fallback, tier-scaled reveal, "add a win." Never deletes.
- Adaptive home + Settings override (Default / Jar / Grid). Hidden win count until threshold.
- **"You did this a year ago"** resurfacing — own past win, not quotes.
- Zoom navigation life → year → week (with §6.2 motion upgrades).
- Images on wins. Local SwiftData. Warm visual system (§5).
- **Onboarding:** first run lets the user drop a handful of milestone wins so the map feels alive day one and teaches the mechanic without a tutorial. For demos: pre-seed a persona so the mature, glowing grid is visible.

### Phase 2 — fast-follow
- CloudKit sync • Manual export (JSON + images) • Loss → win threads (faint grid thread) • Negative-space prompts • Year in Review / replay • Resurfacing widget (Lock Screen) • Share-sheet capture • Richer era treatment.

### Phase 3 — later
- iPad layout • Deeper motion (particle systems, elaborate reveals) • Optional "weeks remaining" perspective mode (strictly opt-in) • Calendar-accurate weeks (then week pages can show dates).

---

## 11. Suggested build order (SwiftUI)

1. **Grid math first** — `Entry` model + day-of-year mapping + render full-life grid from sample data. Underpins everything.
2. **Zoom navigation** — tap + `matchedGeometryEffect` life → year → week; add `MagnificationGesture`.
3. **Week page** — dateless, entry list, add/edit entries (kind, notes, images, optional tier).
4. **Eras** — create + tint bands behind the grid.
5. **The Jar** — all-time weighted shake, tier-scaled reveal, CoreHaptics.
6. **Home logic** — adaptive Jar-first + Settings override; hidden win count.
7. **Resurfacing** — "you did this a year ago."
8. **Polish pass** — §6.2 motion upgrades, reduced-motion, empty states, onboarding, icon.
9. **Ship** — App Store metadata, privacy (on-device), TestFlight, submit.
10. **Phase 2** — CloudKit sync + export first.

---

## 12. Tunables to decide during build

- **Win-count threshold** (Jar → Grid home switch): suggest **~15–25** (NOT 100).
- **Win-count display threshold** (hide count until): suggest **50 or 100**.
- **Weighted-shake recency curve** strength (how strongly to favor long-unseen wins).
- Final micro-copy for onboarding, empty states, warm home subtitle.

---

## 13. Known risks (guard these)

- **Cold start / back-loaded payoff.** A new grid is nearly empty; the "constellation" magic is months away. *Mitigations:* milestone-backfill onboarding, Jar-first adaptive default, negative-space prompts, demo persona.
- **Feel over features.** The app lives on polish — the shake, reveal, zoom. Mediocre execution = "just a notes app." **Craft is the product.**
- **Scope sprawl.** It's quietly a life-journaling app with a resurfacing engine. Hold the v1 line.
- **Tone drift.** Guard "warm, not morbid" everywhere, especially losses and any perspective feature.
- **Divide-logic vs calendar.** v1 uses day-of-year buckets → week pages omit dates to avoid mismatches. Don't surface dates until reconciled (Phase 3).

---

## 14. Parked / rejected ideas (kept on purpose)

- **"Weeks left" / mortality framing** — parked for tone. Revisit as opt-in perspective mode.
- **Fully random memory-box colors** — reads as noise. Replaced by tier color + era tints.
- **Hard flip at exactly 100 wins** — jarring. Replaced by adaptive default + Settings override.
- **ISO week numbering** — splits early-January. Replaced by day-of-year/7.
- **"Empty the Jar" (destructive)** — implies deletion + guilt. Replaced by non-destructive all-time replay.
- **Generic motivational quotes** — cheapens tone that also holds losses. Replaced by "your own past win."
- **Supabase as primary backend** — deprioritized; CloudKit fits private single-user iOS.
- **Streaks / daily nagging / push** — rejected by design (anti-habit, no-guilt).
- **Tier over-specification (4+ tiers, forced rating)** — trimmed to 4 optional one-tap tiers.

---

## 15. Prototype reference values (from `files/prototype.html`)

Demo constants used to seed the reference grid — useful for building a demo persona:
- Grid: 52 cols × 52 rows; 32 lived rows + 20 extra weeks in the current row; win threshold 50; win count 41.
- Tier distribution (rarity): diamond ~5%, gold ~25%, silver ~32%, bronze ~rest.
- Sample eras: rows 18–21 (diamond tint), rows 22–31 (gold tint).
- Device shake threshold: `|x|+|y|+|z| > 34` while on the Jar screen.
- Reveal confetti count by tier: diamond 38, gold 28, else 18.
- Sample wins carry `{tier, meta ("2 years ago"), title, body}` — the "meta" is the resurfacing context line.

**Prototype is flow + look only.** Real animations (continuous pinch, matchedGeometry flight, spring physics, CoreHaptics, particle reveal, ignite-on-add) are built native per §6.2.

---

## 16. Naming

**Emberwick** = coined (ember + wick), for warmth + ownability. Before launch: reserve in App Store Connect + trademark search. Rejected: *Ember* (taken), *Emberly* (taken), and the whole *Ever-/-glow/-light + memories* lane (saturated).
```
