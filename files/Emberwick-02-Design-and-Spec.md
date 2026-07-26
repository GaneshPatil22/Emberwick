# Emberwick — Design & Technical Spec
### Doc 2 of 3

Companion to **Doc 01 (Product Guide)** and **Doc 03 (Phases & Roadmap)**.

> **Prototype reference.** `prototype.html` shows the **flow and initial UI feel only**. It does **not** contain every animation — several are easier/better in SwiftUI (see §5). Use it for the flow and the look direction, not as a spec to copy 1:1. UI will keep evolving.

---

## 1. Core mental model

### 1.1 The grid
- One box = **one week**. 52–53 boxes per row, one row per **year**, ~90 rows for a full life.
- **Week → box mapping (day-of-year, NOT ISO weeks):**
  - `boxIndex = (dayOfYear − 1) / 7` (integer division).
  - Box 0 = Jan 1–7, box 1 = Jan 8–14, … box 52 = the final 1–2 days (short "sliver"; 2 days in leap years).
  - Every year restarts at box 0 on Jan 1 — a date can **never** leak into the prior row. (e.g. 2 Jan 2022 → first box of the 2022 row.)
  - Rows run **birth year → birth year + 90**. Weeks before birth in the first row render as a quieter "before you" state.
  - ISO weeks are rejected because they push early-January dates into the previous year's week 52/53.

### 1.2 Entries (one unified model)
Do **not** build win/loss/note separately. One `Entry` with a `kind`:
- `kind`: `win` | `loss` | `note`
- Shared: `title` (required), `notes` (optional), `images` (optional), `date`
- `win`-only: `tier` (optional), Jar-eligible
- A **week is derived**, not stored — all entries whose date maps to that `(year, boxIndex)`.

### 1.3 The Jar
- The Jar **points at** wins (a lens) — it never contains or deletes them.
- Shake = pick a random win from the current scope; **default scope = all-time** (never empty if ≥1 win exists).
- **Weighted** toward wins not seen in a long time (keeps rediscovering, not replaying).
- **Wins only** — losses/notes live in the week page but are never shaken out.

### 1.4 Eras
- **Era = a span** → a soft, low-saturation horizontal tint band. Background wash.
- **Win = a point** → a bright, tier-colored box. Foreground.
- Different **roles**, not different shades of one palette. Eras stay quiet enough that wins always pop above them.
- **v1:** create an era (name, start, end) that tints its band. No drag-resize, overlap rules, or nesting.

### 1.5 Visual grammar (box states)
| State | Look |
|---|---|
| Ahead (unlived) | Outline only |
| This week | Accent (raspberry-coral) |
| Lived, no memory | Neutral fill |
| Lived, has memory | Tier color + soft glow |
| Inside an era | Soft tint band behind everything above |

---

## 2. Screens & flow (locked)

**Home logic:** Jar-first until a **win-count threshold**, then the full-life grid becomes home. Overridable in **Settings → Home mode: Default (adaptive) / Jar / Grid**. A **Map / Jar switch always sits in the bottom bar**.

**Flow:**
```
        ┌─────────── bottom bar: [ Map ] [ Jar ] ───────────┐
        │                                                    │
   [ Full-life grid ] ──tap a cell / pinch out──▶ [ Year ] ──tap a week / pinch out──▶ [ Week page ]
        ▲  ▲                                         │                                     │
        └──┴────────────── pinch in / back ──────────┴─────────────────────────────────────┘

   [ Jar ] ──shake (or device shake)──▶ [ Reveal a random past win ] ──"put it back"──▶ [ Jar ]
                                         "add a win" ▲
```

- **Full-life grid (home when mature):** header title + warm subtitle, jar button top-right. **Win count is hidden until a threshold** (so a sparse early grid doesn't demotivate) — show a warm line instead. Legend order is fixed: **bronze, silver, gold, diamond, this week, ahead.** **Every cell is tappable** and zooms into its year.
- **Year:** that year's 52 weeks enlarged; title shows age (row-derived — safe, it's the year not the week). Tap any week → week page.
- **Week page:** **calm, full-screen, NO dates** (v1's divide logic isn't calendar-accurate, so a date could mismatch). Shows an era chip, a soft title, and the week's entries (win with tier pill, note, hard-week handled quietly), plus "Add to this week."
- **Jar:** the glass jar with glowing orbs; "Shake for a memory" (button + real device-shake), "Add a win." Reveal = tier-scaled effect (see §4), "Put it back" (never deletes).

---

## 3. Visual system

Deliberately **not** the cream + serif + terracotta (#D97757) AI cliché. Warm and energetic; the four tiers are the palette, chrome stays warm-neutral, and **glow is the signature** (memories emit light; jar wins are glowing orbs).

**Palette**
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

**Type:** Gabarito (display / headings, 600–800) + DM Sans (body, 400–500). Warm rounded, grown-up, not a serif.
**Depth:** soft shadows and glows are fine (this is a product surface, not the flat claude.ai system). Corners generous (14–24px).
**Tiers:** metals are **locked** — bronze / silver / gold / diamond; diamond is deliberately rare. Tier drives both the grid glow and the reveal effect. Rating is **optional and one-tap** (never forced).

---

## 4. Animation & interaction spec

### 4.1 Already in the prototype (reference feel)
- Grid entrance: staggered pop-in of cells.
- Ambient: this-week cell "beat," diamond cells "twinkle," jar orbs "bob," jar glow "breathe."
- Zoom: tap/pinch life → year → week (approximated via scale + fade + transform-origin at the tapped cell).
- Jar: shake wobble → reveal with ripple + tier-colored glow + confetti burst that scales with tier; staggered haptics via `navigator.vibrate`.
- Week page: entries rise in staggered; press states on cells/buttons.

### 4.2 Must be added / upgraded in SwiftUI (NOT in the prototype)
> These were skipped or only approximated in HTML because they're materially easier and better native. This list is the reason not to copy the prototype 1:1.
- **True continuous pinch-zoom** with `MagnificationGesture` (prototype uses a threshold flip, not finger-following).
- **`matchedGeometryEffect`** so a tapped week *is* the same square enlarged — a real "flight" from life → year → week, not a cross-fade.
- **Spring physics** on all transitions (`.spring`/`.interactiveSpring`) for a fluid, native feel.
- **CoreHaptics** with **tier-specific haptic patterns** (bronze subtle → diamond a rich flourish), beyond the crude web vibrate.
- **Richer reveal**: real particle/emitter effect (Canvas/TimelineView or SpriteKit) rather than DOM confetti.
- **Grid "lighting up"** micro-animation when a new memory is added (the box ignites into its tier color).
- **Reduced-motion** honored via `@Environment(\.accessibilityReduceMotion)`.

---

## 5. Data model (sketch)

```swift
// One model for all three kinds — a week is DERIVED, never stored.
@Model final class Entry {
    var id: UUID
    var date: Date          // maps to (year, boxIndex) via day-of-year
    var kind: EntryKind     // .win / .loss / .note
    var title: String       // required
    var notes: String?      // optional — all kinds
    var imageData: [Data]   // optional — all kinds (heavy for sync; see §7)
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

## 6. Backup / sync strategy
- **v1:** local **SwiftData**.
- **Fast-follow:** **CloudKit** via SwiftData's built-in sync — free, private, no backend, native cross-device restore on the same Apple ID.
- **Safety valve:** manual **JSON + images export** (trust feature — people give a life-archive their trust more readily when they can get data out).
- **Supabase:** only if Android/web or shared/multi-user later. **Images are the heavy part** of any sync path — plan for it (compress, store references).

---

## 7. Frameworks
- **SwiftUI** — UI, grid, `matchedGeometryEffect`, `MagnificationGesture`, springs.
- **SwiftData** — persistence (+ CloudKit later).
- **CoreMotion** — shake-to-reveal.
- **CoreHaptics** — tier-specific haptics.
- **PhotosUI / PhotosPicker** — image attachment.
- **WidgetKit** — resurfacing widget (Phase 2).
- **CloudKit** — sync (Phase 2).

---

## 8. Tunables to decide during build
- **Win-count threshold** for Jar → Grid home switch (suggest ~15–25; not 100).
- **Win-count display threshold** — hide the count until this many wins (suggest 50 or 100).
- Weighted-shake recency curve (how strongly to favor long-unseen wins).
