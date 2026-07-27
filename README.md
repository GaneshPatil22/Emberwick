# 🔥 Emberwick

> **A warm, private map of your life — one good week at a time.**

Emberwick turns your life into a grid where **every week you've lived is a square, and the good ones light up.** Capture wins, hard moments, and small notes; each one lands on the week it happened, and the map slowly fills with light. Shake the **Jar** to relive a memory you'd forgotten — with context ("this was ~2 years ago").

*A wick carries the flame; each memory is a small light you keep lit.*

Built for iOS with SwiftUI + SwiftData, iPhone-first, **private and on-device**.

---

## ✨ What makes it special

Emberwick fuses two ideas that are weak alone:

- **Life in Weeks** — your whole life as a grid (1 box = 1 week, ~90 rows). Beautiful, but static.
- **The Jar** — collect tiny wins, shake to relive a random one. A real payoff, but contextless.

**The insight:** the Jar is the *input*, the grid is the *view*. Every win you drop also lights up its week on the map. Two views of the same life.

**Guiding principles**
- 🕯️ **Warm, not morbid** — "look how much good has happened, and how much blank canvas is left." Never a death countdown.
- 🌱 **No guilt** — no streaks, no nagging, no obligation. Returning is a pleasure.
- 💛 **Your own life is the motivation** — never generic quotes.
- 🔒 **Private by default** — on-device first; no accounts to start.

---

## 🎯 Important features

| Feature | Description |
|---|---|
| **Full-life grid** | 53 weeks × ~90 years, drawn with a single `Canvas` for performance. Memories glow in their tier color. |
| **Day-of-year week math** | `boxIndex = (dayOfYear − 1) / 7` — a January date never leaks into the previous year's row (ISO weeks rejected). |
| **Pinch-zoom + pan** | Crisp magnify of the poster (the Canvas redraws at zoom), one row always = one year. |
| **Zoom navigation** | Tap a cell → its **year** → a **week**, via native `.navigationTransition(.zoom)` flights. |
| **Dateless week page** | Calm, full-screen page with an era chip, the week's entries, and "Add to this week." |
| **One unified entry** | `win` / `loss` / `note` — shared title/notes/images/date; wins get an optional one-tap **tier** (bronze → silver → gold → 💎 diamond). |
| **Eras** | Soft, low-saturation tint bands behind the grid (a span), so bright wins (points) always pop above. |
| **Memory-flight intro** | On launch, 15–25 memory cards fly up from the bottom and tuck into their weeks — reusable for the Jar reveal. |
| **The Jar** *(planned)* | Weighted shake surfaces a long-unseen win with tier-scaled delight; never deletes. |
| **Local-first storage** | SwiftData now; CloudKit sync + JSON export as fast-follow. |

---

## 🚦 Current progress

Built in independently-testable phases (see [`BUILD_PLAN.md`](BUILD_PLAN.md)):

| Phase | Feature | Status |
|---|---|---|
| 0 | Foundation — design tokens, models, grid math (verified) | ✅ Done |
| 1 | Full-life grid render (seeded demo persona) | ✅ Done |
| 2 | Zoom navigation (life → year → week) | ✅ Done |
| 3 | Week page + add/edit entries (with photos) | ✅ Done |
| ✨ | Signature memory-flight intro animation | ✅ Done |
| 4 | Eras (create + tint bands) | ⬜ Planned |
| 5 | The Jar (shake + reveal + haptics) | ⬜ Planned |
| 6 | Adaptive home + Settings | ⬜ Planned |
| 7 | Resurfacing ("you did this a year ago") | ⬜ Planned |
| 8 | Onboarding + polish pass | ⬜ Planned |
| 9 | Ship prep (icon, metadata, TestFlight) | ⬜ Planned |
| F | Future: CloudKit sync, export, loss→win threads, widget | 🔮 Later |

**Verified:** builds clean (iOS 26 / Swift 6), grid-math unit tests green, core loop runs in the simulator.

---

## 🧭 User flow

```mermaid
flowchart TD
    Launch([App launch]) --> Intro[Memory-flight intro<br/>cards fly into their weeks]
    Intro --> Life[["🗺️ Full-life grid (home)"]]

    Life -- pinch / drag --> Life
    Life -- tap a cell --> Year["📅 Year view<br/>(that year's 53 weeks)"]
    Year -- tap a week --> Week["📖 Week page<br/>(dateless, entries)"]
    Year -- back / pinch in --> Life
    Week -- back --> Year

    Week -- "Add to this week" --> Editor["✏️ Entry editor<br/>kind · title · notes · tier · photos"]
    Editor -- save --> Persist[(SwiftData)]
    Persist -- cell ignites --> Life

    Jar["🫙 The Jar (planned)"] -. shake .-> Reveal["✨ Reveal a past win"]
    Life -. bottom bar .-> Jar
```

---

## 🏗️ Architecture (class / view view)

Pure functional core (grid math, snapshot, planners) with impurity pushed to the edges (SwiftData, photos, haptics). One type per file, feature-based folders.

```mermaid
classDiagram
    direction LR

    class Entry {
      <<Model>>
      +id
      +date
      +kind
      +title
      +notes
      +imageData
      +tier
      +isJarEligible()
    }
    class Era {
      <<Model>>
      +name
      +startDate
      +endDate
      +tintHex
    }
    class EntryKind {
      <<enum>>
      win
      loss
      note
    }
    class Tier {
      <<enum>>
      bronze
      silver
      gold
      diamond
    }

    class GridMath {
      <<pure>>
      +boxIndex()
      +position()
      +representativeDate()
    }
    class GridSnapshot {
      +today
      +state()
      +make()
    }
    class GridPosition {
      +row
      +column
    }
    class GridCellState {
      <<enum>>
      ahead
      thisWeek
      livedEmpty
      memory
      beforeBirth
    }

    class MapView { <<View>> }
    class LifeLevelView { <<View>> }
    class LifeGridInteractiveView { <<View>> }
    class LifeGridView { <<Canvas>> }
    class YearLevelView { <<View>> }
    class WeekLevelView { <<View>> }
    class EntryEditView { <<View>> }

    class MemoryFlightView { <<View>> }
    class FlightModifier { <<Animatable>> }
    class IntroFlightPlanner { <<pure>> }

    class EmberwickModelContainer { <<SwiftData>> }
    class DemoSeeder { <<DEBUG>> }
    class EmberPalette { <<tokens>> }

    MapView --> LifeLevelView
    MapView --> YearLevelView
    MapView --> WeekLevelView
    LifeLevelView --> LifeGridInteractiveView
    LifeGridInteractiveView --> LifeGridView
    LifeGridInteractiveView --> IntroFlightPlanner
    IntroFlightPlanner --> MemoryFlightView
    MemoryFlightView --> FlightModifier
    YearLevelView --> WeekLevelView
    WeekLevelView --> EntryEditView
    EntryEditView --> Entry
    GridSnapshot --> GridCellState
    GridSnapshot ..> GridMath
    GridSnapshot ..> Entry
    LifeGridView ..> GridSnapshot
    Entry --> EntryKind
    Entry --> Tier
    EntryEditView ..> EmberwickModelContainer
    DemoSeeder ..> Entry
    DemoSeeder ..> Era
```

### Source layout

```
Emberwick/
├── App/            AppConfig
├── Models/         Entry · Era · EntryKind · Tier            (domain, pure)
├── Grid/           GridMath · GridSnapshot · GridConstants · Canvas grid,
│                   life/year/week views, MapView + zoom routing
├── Week/           WeekLevelView · EntryEditView · rows, pills, era chip
├── Animation/      MemoryFlightView · FlightModifier · intro planner/overlay
├── DesignSystem/   EmberPalette · Typography · Spacing · Radius · styles (tokens)
├── Persistence/    EmberwickModelContainer (SwiftData)
├── DevTools/       DemoPersona · DemoSeeder (seeded, #if DEBUG)
└── Utilities/      ImageCompression
EmberwickTests/     GridMathTests
```

---

## 🛠️ Tech stack

- **SwiftUI** — grid `Canvas`, `matchedTransitionSource` + `.navigationTransition(.zoom)`, `MagnifyGesture`, `KeyframeAnimator` / `Animatable`.
- **SwiftData** — persistence (CloudKit-ready for a fast-follow).
- **PhotosUI** — image attachment (compressed on import).
- **Target:** iOS 26 · Swift 6.

## 🎨 Design system

Deliberately **not** the cream + serif + terracotta AI cliché. Warm and energetic; the four tiers *are* the palette, chrome stays warm-neutral, and **glow is the signature** (memories emit light).

| Token | Hex | | Token | Hex |
|---|---|---|---|---|
| paper | `#FDF6EE` | | accent | `#F0567A` |
| ink | `#34262C` | | bronze | `#C0763A` |
| ink-soft | `#7B6A6F` | | silver | `#98A0AD` |
| gold | `#F2A72C` | | diamond | `#31BFD6` |

---

## 🚀 Getting started

```bash
open Emberwick.xcodeproj      # Xcode 26+
# Run the Emberwick scheme on an iOS 26 simulator.
# A DEBUG demo persona is seeded on first launch so the grid is alive immediately.
```

## 📚 More docs

- [`EMBERWICK.md`](EMBERWICK.md) — full product + technical spec.
- [`BUILD_PLAN.md`](BUILD_PLAN.md) — phased, testable roadmap.

---

<sub>Private, on-device, and warm by design. 🕯️</sub>
