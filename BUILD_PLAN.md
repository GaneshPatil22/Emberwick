# Emberwick — Build Plan (phased, testable)

> **How to read this:** each phase is a **self-contained, runnable, reviewable increment.** You can build it, test it in the simulator, give feedback, we adjust, and only then move on. Phases are ordered so each one stands on the last. Product scope and rationale live in `EMBERWICK.md`; this doc is the *implementation* roadmap.
>
> **Legend:** ✅ done · 🔜 next · ⬜ planned · 🔮 post-v1 (future)
>
> **Ground rules every phase follows:** pure functional core / impurity at the edges · SOLID / DRY / KISS · constants for all tokens · one type per file · feature-based folders · swiftui-pro skill (iOS 26, Swift 6, modern APIs, HIG, accessibility incl. Reduce Motion) · **no over-engineering**.

---

## Progress at a glance

| Phase | Title | State | Testable outcome |
|---|---|---|---|
| 0 | Foundation — tokens, models, grid math | ✅ **done** | Builds clean; grid math verified 11/11 edge cases |
| 1 | Full-life grid render (demo persona) | ✅ **done** | Glowing life grid renders on launch from seeded data |
| 2 | Zoom navigation (life → year → week) | ✅ **done** | Tap/pinch to fly between levels |
| 3 | Week page + add/edit entries | ✅ **done** | Add a win → grid lights up, persists |
| 4 | Eras (tint bands) | ✅ **done** | Create an era → band appears behind grid |
| 5 | The Jar (shake + reveal + haptics) | ✅ **done** | Shake → a past win is revealed |
| 6 | Home logic + Settings | ✅ **done** | App opens to Jar or Grid adaptively |
| 7 | Resurfacing ("a year ago") | ⬜ | A past win resurfaces in context |
| 8 | Onboarding + polish pass | ✅ **mostly** | First-run backfill; reduce-motion; empty states |
| 9 | Ship prep | ⬜ | Icon, metadata, privacy, TestFlight build |
| F | Future (post-v1) | 🔮 | CloudKit, export, threads, widget, … |

---

## ✅ Phase 0 — Foundation (COMPLETE)

**Goal:** the non-visual bedrock everything else sits on.

**Delivered:**
- **Design tokens** (`DesignSystem/`): `Color+Hex`, `EmberPalette`, `EmberTypography`, `EmberSpacing`, `EmberRadius`, `Tier+Palette` (tier→color mapping kept out of the model).
- **Domain models** (`Models/`): `EntryKind`, `Tier` (pure enums), `Entry` + `Era` (`@Model`, SwiftData). One unified `Entry`; week is derived, never stored.
- **Grid math** (`Grid/`): `GridConstants` (53 cols / 90 rows), `GridPosition`, `GridMath` (pure day-of-year mapping, calendar injectable).
- Project set to iOS 26.5 / Swift 6 language mode; skill relocated out of the app bundle.

**Verified:** `xcodebuild` clean (0 warnings). Grid math edge cases all pass — box boundaries, the Dec sliver (box 52, leap & non-leap), and the critical guarantee that **Jan 2 never leaks into the prior year's row** (why we reject ISO weeks).

**Future hooks planted here:** `Entry`/`Era` are SwiftData models → CloudKit sync (Phase F) is a container flag later, not a rewrite. `GridMath.calendar` is injectable → calendar-accurate weeks (Phase F) won't touch call sites. `Tier`/`EntryKind` are `Codable` → JSON export (Phase F) is nearly free.

---

## ✅ Phase 1 — Full-life grid render (COMPLETE)

**Delivered:** SwiftData container (`EmberwickModelContainer`, on-disk + in-memory preview); deterministic dev seeder (`DemoSeeder`/`DemoPersona`/`SeededRandomNumberGenerator`) filling 46 wins + 8 losses + 16 notes + 3 eras, no images, idempotent, `#if DEBUG`; pure `GridSnapshot` state builder (`GridCellState`, best-tier-per-week); `LifeGridView` (Canvas, glow on memory/this-week cells) + `GridHeaderView` + `GridLegendView` composed in `LifeGridScreen`. Builds clean; verified on iPhone 17 Pro simulator.

**Review notes / possible tweaks:** glow is subtle at ~6pt cell size; lived-empty vs ahead contrast is gentle; memory density is concentrated in the active-age band. All tunable — flag if you want changes.

---

<details><summary>Original Phase 1 plan (for reference)</summary>

## Phase 1 — Full-life grid render

**Goal:** launch the app and see the warm, glowing life grid rendered from a seeded demo persona. This is the emotional core made visible and the backbone for zoom later.

**Features / scope:**
- SwiftData `ModelContainer` wired into the app; in-memory container for previews.
- **Demo persona seeder (dev toggle)** — deterministic sample data behind a `#if DEBUG` toggle: a good number of **wins** (spread across years, realistic tier rarity — diamond rare), plus **losses**, **notes**, and a few **eras**, so the mature grid reads well in a demo. Seeded RNG → reproducible. **No images** (added later via the Phase 3 edit UI). Idempotent (won't double-seed).
- **Grid cell state** derived (pure) from entries + today: `ahead` / `thisWeek` / `livedEmpty` / `memory(tier)` / era tint. One `GridCellState` enum + a pure builder `func cellStates(entries:today:birthYear:) -> [GridPosition: GridCellState]`.
- **Views:** `LifeGridView` (the 53×N lattice via `Grid`/`Canvas`), `GridCellView`, `GridLegendView` (fixed order: bronze, silver, gold, diamond, this week, ahead), warm header (title + subtitle). Win count **hidden** (warm line instead).
- Tier glow on memory cells; accent "this week" cell.

**Done & testable when:** running in the simulator shows a full-life grid with lit tier-colored cells, a "this week" accent cell, the legend, and the warm header — matching the palette. Reviewer can eyeball feel and density.

**Tests:** unit-test the pure `cellStates` builder and the seeder determinism (see "Testing" below). Visual review via `#Preview` + simulator.

**Design decisions to lock with you:** cell rendering approach (`LazyVGrid` vs `Canvas` — I'll recommend `Canvas` for 4,700+ cells performance) and whether the demo persona ships as a dev-only toggle.

**Future hooks:** `cellStates` returns a dictionary keyed by `GridPosition` → zoom (Phase 2) and ignite-on-add (Phase 8) reuse it. Legend/tier rendering centralized → richer era treatment (Phase F) slots in.

</details>

---

## ✅ Phase 2 — Zoom navigation (COMPLETE)

**Delivered:** `GridLevel` path type; `MapView` (`NavigationStack`) driving native `.navigationTransition(.zoom)` — a real flight, not a cross-fade. Life grid: tap a cell (Canvas hit-tested via `GridCanvasMetrics.position(at:)`) → an invisible `matchedTransitionSource` anchor (`LifeZoomSourceOverlay`) at that cell → zoom into `YearLevelView`. Year: 53 enlarged real cells (`YearWeekCell`), each a zoom source → zoom into `WeekLevelView` (dateless placeholder). Back via swipe/back-button; light pinch too (pinch-out on life → current year, pinch-in → back). `MapDestination` routes levels. Builds clean; year + week levels verified in the simulator.

**Note:** couldn't automate a tap in this environment, so the *animation* is verified by wiring (native API + matching source IDs), not a captured frame — tap in the sim to feel the flight. `ContentView` now hosts `MapView`; the old `LifeGridScreen` was removed (superseded by `LifeLevelView`).

**Zoom — FINAL: plain pan-zoom (reverted from the gallery reflow).** Tried a Photos-style reflow gallery (`LazyVStack` of Canvas rows) but reverted per feedback: too costly, focal anchoring never felt right, and the plain zoom already conveys "which year am I on." Current behavior (`LifeGridInteractiveView`):
- **Pinch** = continuous finger-following magnify of the Canvas poster (crisp redraw), anchored at the pinch point, clamped 1…`maxZoomScale`(10); **drag** pans when zoomed. One row = one year always.
- **Tap** a cell → its **year** (`YearLevelView`, 53 weeks enlarged), then tap a week → its week page — both via native `.navigationTransition(.zoom)`. Flow is **life → year → week**; routed via `MapRoute` + `MapDestination`.
- Layout-loop-safe (fixed base measured; grid is an overlay). **0% CPU.** See [[emberwick-grid-zoom-design]].
- **Untested here:** pinch/pan *feel* (no gesture automation) — tune on-device.
- **Abandoned for v1:** the reflow gallery + variable-size cells (LazyVGrid pegs at ~4,770 cells; documented in the memory so we don't retry blindly).

---

<details><summary>Original Phase 2 plan (for reference)</summary>

## Phase 2 — Zoom navigation (life → year → week)

**Goal:** the signature interaction — a real "flight" between the three levels, not a cross-fade.

**Features / scope:**
- Navigation state machine: `GridLevel` enum (`life` / `year(Int)` / `week(GridPosition)`), driven by a small `@Observable` view model.
- `matchedGeometryEffect` so a tapped cell *becomes* the enlarged view.
- Continuous `MagnificationGesture` (finger-following) + spring physics (`.interactiveSpring`).
- `YearGridView` (that year's 52 weeks enlarged; title shows age — safe, row-derived).
- Back / pinch-in to collapse levels.

**Done & testable when:** tap a cell → fly into its year → tap a week → fly into the (placeholder) week page; pinch to reverse. Smooth springs, correct origin cell.

**Tests:** unit-test the level state machine (pure transitions). Interaction reviewed manually.

**Future hooks:** week page is a placeholder here, filled in Phase 3. Level enum carries `GridPosition` so deep-linking (widget tap → week, Phase F) is trivial later.

</details>

---

## ✅ Phase 3 — Week page + add/edit entries (COMPLETE)

**Delivered:** `WeekLevelView` — calm, full-screen, **dateless** page showing the era chip (`EraChip`, tint from `Era.tintHex`), a soft title, the week's entries as soft cards (`EntryRowView` with `TierPill` for rated wins / `EntryKindLabel` for notes & hard weeks / `EntryImageStrip` thumbnails), and "Add to this week." `EntryEditView` sheet (add + edit): segmented kind picker, required title, notes (`TextField` axis `.vertical`), **wins-only** one-tap optional tier (`TierSelector`), and multi-photo `PhotosPicker` (compressed on import via `ImageCompression`), plus Delete when editing. Persists via SwiftData; the derived week is recomputed so a saved entry lights up its grid cell. `GridMath.representativeDate` maps a new entry into the right week; `Color(hexString:)` added for era tints; `EmberPalette.card` surface token.

**Verified:** builds clean; empty + populated week pages render correctly (era chip + gold tier pill confirmed) in the simulator.

**Untested here (needs your tap):** the add/edit sheet flow itself (open → pick kind/tier → add photos → save → grid lights up), since there's no tap/photo-picker automation. Please add a couple of entries + a few photos on-device to confirm.

---

<details><summary>Original Phase 3 plan (for reference)</summary>

## Phase 3 — Week page + add/edit entries

**Goal:** the capture loop closes — add an entry, watch its week light up, and it persists across launches.

**Features / scope:**
- `WeekPageView`: calm, full-screen, **NO dates** (v1 divide-logic isn't calendar-accurate). Era chip, soft title, entry list (`EntryRowView` with tier pill / note / hard-week treatment), "Add to this week."
- **Add/Edit entry flow** (`EntryEditView` sheet): kind picker (win/loss/note), title (required), notes (`TextField` axis `.vertical`), optional images (`PhotosPicker`), optional one-tap tier (wins only).
- Persistence via SwiftData; image data compressed at the edge before save.
- Wins-only fields gated by kind.

**Done & testable when:** add a gold win to a week → return to grid → that cell now glows gold; relaunch → still there. Edit and delete work.

**Tests:** unit-test entry validation + the compress-image edge helper (pure part). Manual review of the sheet UX and accessibility (VoiceOver labels, Dynamic Type on the text-heavy page).

**Future hooks:** `Entry.linkedEntryID` reserved for loss→win threads (Phase F). Image compression isolated → sync image strategy (Phase F) reuses it. Dateless-by-design note documented so calendar-accurate weeks (Phase F) is a deliberate later switch.

</details>

---

## ✅ Phase 4 — Eras (COMPLETE)

**Delivered:** pure `EraBandCalculator.bands(eras:birthYear:rowCount:)` → `[EraBand]` (row ranges, clamped); `LifeGridView` draws the bands **behind** the cells in the Canvas (low-saturation tint at ~0.55 so wins pop above); `EraEditView` create sheet (name, start/end `DatePicker`s, soft-tint swatch picker from `EraTints`) persisted via SwiftData; an **add-era button** in the life header. Bands thread `MapView → LifeLevelView → LifeGridInteractiveView → LifeGridView`. Week-page era chip was already added in Phase 3.

**Verified:** builds clean; the 3 seeded eras render as bands behind the grid in the simulator.

**Untested here (needs your tap):** the create-era sheet flow (open → name/dates/tint → save → new band appears). Standard Form sheet; please try it on-device.

---

<details><summary>Original Phase 4 plan (for reference)</summary>

## Phase 4 — Eras (tint bands)

**Goal:** span-level context behind the point-level wins.

**Features / scope:**
- `EraEditView`: create an era (name, start, end, soft tint). v1 create-only — no resize/overlap/nesting.
- Pure `func eraBands(eras:birthYear:) -> [EraBand]` mapping eras to row ranges.
- Render low-saturation horizontal bands behind the grid (z-below cells) so wins always pop.
- Era chip surfaced on the week page.

**Done & testable when:** create an era spanning a few years → a soft band appears behind those grid rows; its weeks show the era chip.

**Tests:** unit-test `eraBands` row-range math (incl. partial-year edges). Visual review of contrast (wins must stay dominant).

**Future hooks:** `EraBand` is a value type → richer narrative era treatment (Phase F) extends rendering only.

</details>

---

## ✅ Phases 5, 6, 8 (COMPLETE / mostly) — built together

**Phase 5 — The Jar.** `JarView` (glass jar + glowing tier orbs via `JarIllustration`, "N good moments inside", Shake + Add-a-win). Pure `JarSelector` weighted pick favoring long-unseen wins (new `Entry.lastSeenAt` timestamp, set on reveal — never deletes). `RevealView` — tier-scaled glow orb + context ("2 years ago · Bronze") + "Put it back", with tier-scaled `sensoryFeedback` haptics. `ShakeDetector` (CoreMotion) for device shake. Reuses `EntryEditView` for Add-a-win. Verified: Jar + reveal render in the simulator.

**Phase 6 — Home shell + Settings.** `RootView` = Map / Jar `TabView` bottom bar; adaptive initial tab (`HomeMode` in `@AppStorage`, `HomeConstants.jarToGridThreshold`); `SettingsView` (Home mode: Adaptive/Jar/Grid) via a Jar gear; grid win count hidden until `hideWinCountThreshold` (warm subtitle otherwise). `ContentView` → `RootView`.

**Phase 8 — Onboarding + polish.** `OnboardingView` first-run milestone backfill (empty store only); `EmberMotion` animation tokens; Reduce Motion honored (intro, reveal, jar orbs); empty states (empty jar, empty week). Verified onboarding renders.

**Untested here (need device):** device-shake, haptics, and the tap-driven shake→reveal / tab-switch / add-win / settings flows — no gesture/haptic automation in this env. Build verified; static states screenshotted.

**Deferred (noted):** ignite-on-add grid micro-animation (hard with Canvas); richer particle reveal; CHHaptics custom tier patterns (using `sensoryFeedback` for now); onboarding historical-date backfill (milestones land on the current week — there's no date field yet); app icon (Phase 9).

**Dev flags (DEBUG):** `-openJar` (start on Jar), `-skipSeed` (empty store to see onboarding).

---

<details><summary>Original Phase 5–8 plans (for reference)</summary>

## Phase 5 — The Jar (shake + reveal + haptics)

**Goal:** the payoff — rediscover a forgotten win, with tier-scaled delight.

**Features / scope:**
- `JarView`: glass jar with glowing orbs (ambient bob/breathe), "Shake for a memory," "Add a win."
- **Weighted shake** (pure): `func pickWin(from:lastSeen:now:) -> Entry?` favoring long-unseen wins; all-time scope; wins only; never empty if ≥1 win.
- **Reveal** (`RevealView`): tier-scaled effect (glow + particle burst via `Canvas`/`TimelineView`), context line ("~2 years ago · gold"), "Put it back" (never deletes; updates a `lastSeenDate`).
- **CoreHaptics** tier-specific patterns (bronze subtle → diamond flourish) via `sensoryFeedback` / `CHHapticEngine`.
- **Device shake** via CoreMotion, active only on the Jar screen.

**Done & testable when:** on the Jar, tap Shake (or shake the device) → a weighted-random past win reveals with tier-scaled visuals + haptics → "Put it back" returns to the jar without deleting; a just-seen win is less likely next time.

**Tests:** unit-test the weighting/selection (deterministic with injected `now` + seeded RNG) and the "never empty / never repeat immediately" rules. Reveal + haptics reviewed on device.

**Future hooks:** selection takes scope as a parameter → Year-in-Review replay (Phase F) reuses it with a narrower scope. `lastSeenDate` on `Entry` also feeds resurfacing (Phase 7).

---

## ⬜ Phase 6 — Home logic + Settings

**Goal:** the app opens to the right place and respects the user's choice.

**Features / scope:**
- Adaptive home: Jar-first until a win-count threshold (~15–25), then grid.
- `SettingsView`: Home mode override (Default / Jar / Grid) via `@AppStorage`.
- Persistent **Map / Jar** bottom bar (`Tab` API, enum-backed selection).
- Hidden win count until a higher threshold (~50); warm subtitle otherwise.
- Tunables centralized as constants.

**Done & testable when:** with few wins the app opens on the Jar; past the threshold it opens on the grid; Settings override sticks across launches; the bottom bar switches modes.

**Tests:** unit-test the pure "which home?" decision function across counts/overrides. Manual review of Settings persistence.

**Future hooks:** decision function isolated → the opt-in "weeks remaining" perspective mode (Phase F) adds a branch, not a rewrite.

---

## ⬜ Phase 7 — Resurfacing ("you did this a year ago")

**Goal:** gentle, own-life motivation — never quotes.

**Features / scope:**
- Pure `func resurfacedWin(entries:today:) -> Entry?` — a past win near an anniversary of today, respecting recency.
- A warm, dismissible surface on the grid/home (not a notification, no guilt).

**Done & testable when:** with a seeded win dated ~1 year ago, the home shows "You did this a year ago" with that win; dismiss is frictionless.

**Tests:** unit-test the anniversary/selection logic (injected `today`).

**Future hooks:** same selection powers the Lock Screen widget (Phase F) and negative-space prompts (Phase F).

---

## 🔨 Signature intro animation (built early, per request)

The **memory-flight intro** is done ahead of Phase 8. On each cold launch of the life view, a handful of win tokens (photo, or title-on-paper, or blurred-paper fallback) **fly from bottom-center up into their week cells** along arcs with a letter-flutter, growing mid-air then shrinking as they tuck in (~2.5s, staggered). Honors **Reduce Motion** (skips). Verified flying in the simulator.

**Reusable:** the core `MemoryFlightView` (start → end arc + flutter + scale/opacity via `KeyframeAnimator`) is generic over content — **the Jar reveal (Phase 5) reuses it** (one token flying out of the jar). Pieces: `Animation/` — `MemoryFlightView`, `MemoryTokenView`, `MemoryTokenContent`, `FlightState`, `FlightPlan`, `IntroFlightPlanner` (pure), `MemoryFlight`, `IntroFlightOverlay`. Wired via `LifeGridInteractiveView.startIntroIfNeeded()`.

- **Untested here:** the *motion feel* (no animation playback in this env) — tune arc height / flutter / durations on-device. Plays every cold launch by default (change the `didStartIntro` gate for first-run-only later).

---

## ⬜ Phase 8 — Onboarding + polish pass

**Goal:** day-one liveliness and the craft that makes it "not a notes app."

**Features / scope:**
- **Onboarding:** first-run milestone backfill ("graduated / moved / met them") so the map feels alive immediately; teaches the mechanic without a tutorial.
- **Motion upgrades** (from `EMBERWICK.md` §6.2): grid ignite-on-add micro-animation, staggered entrance, spring polish, richer reveal particles.
- **Reduce Motion** honored everywhere (`@Environment(\.accessibilityReduceMotion)`); Dynamic Type + VoiceOver audit.
- Empty states, warm micro-copy, `EmberMotion` token file introduced (only now that animations are real — avoids premature tokens).

**Done & testable when:** fresh install walks through backfill and lands on a living grid; adding a win visibly ignites its cell; toggling Reduce Motion swaps to calm transitions; VoiceOver reads the grid sensibly.

**Tests:** accessibility pass (manual + audit). Onboarding flow reviewed.

</details>

---

## ⬜ Phase 9 — Ship prep

**Goal:** a submittable build.

**Features / scope:** app icon, App Store metadata, on-device privacy copy, name reservation + trademark check for "Emberwick," demo persona pre-seed for screenshots, TestFlight build.

**Done & testable when:** archived build installs via TestFlight and runs the full loop.

---

## 🔮 Phase F — Future (post-v1), and how we're ready for it now

These are **not** built in v1, but v1's design leaves each one cheap:

| Future feature | Enabled by (already or planned) |
|---|---|
| **CloudKit sync** | SwiftData `@Model` types → enable sync on the container; keep image data compressed/reference-friendly (Phase 3). |
| **Manual JSON + image export** | `Codable` enums + value-type DTOs; a pure `export(entries:)` mirrors the seeder. |
| **Loss → win threads** | `Entry.linkedEntryID` reserved (Phase 3); grid draws a faint thread using `GridPosition` pairs. |
| **Year-in-Review / replay** | Jar selection takes a scope parameter (Phase 5); replay = narrower scope, non-destructive. |
| **Resurfacing widget** | WidgetKit reuses the Phase 7 selection; deep-link via `GridLevel(week:)` (Phase 2). |
| **Negative-space prompts** | Reuse era-band + empty-cell detection (Phases 1/4). |
| **Calendar-accurate weeks** | `GridMath.calendar` injectable (Phase 0); flip divide-logic → real weeks, then week pages can show dates. |
| **"Weeks remaining" perspective mode** | Home decision function branch (Phase 6); strictly opt-in. |
| **iPad layout** | Feature-based views + tokens scale; adapt grid columns/spacing. |
| **Share-sheet capture** | Reuse `EntryEditView` + image compression. |

---

## Testing approach (per phase)

- **Pure logic → unit tests.** Grid math, cell-state builder, era bands, jar weighting, home decision, resurfacing selection are all pure functions with injectable `now`/`calendar`/RNG — ideal for `swift-testing`.
- **UI/interaction → simulator + `#Preview`.** Reviewed by you each phase.
- **Test target:** not yet created (Phase 0 validated math via a throwaway script). **Recommendation:** add a `swift-testing` unit-test target at the start of **Phase 1** so every pure function since Phase 0 gets locked in. *(Open decision — see below.)*
- **Accessibility** is a first-class check in Phases 3, 6, 8 (Dynamic Type, VoiceOver, Reduce Motion).

---

## Decisions (locked)

1. **Unit-test target** — ✅ **added** (`EmberwickTests`, swift-testing). Grid-math suite green (6/6). Every pure function gets tests from here on.
2. **Grid rendering** — `Canvas` for the dense full-life grid (perf at ~4,770 cells); real views for the 52-cell year level (where tap + matchedGeometry flight matter). *Confirmed approach; revisit feel after Phase 1.*
3. **Demo persona / dev seeder** — ✅ a **dev-only toggle** that fills the store with realistic wins/losses/notes **and** eras in good demo numbers. **No seeded images** (I can't add real photos) — the seeder leaves image slots empty and the user adds a few photos later via the **entry image add/edit UI (Phase 3)**. Real first-run onboarding still comes in Phase 8.
4. **Tunable values** — confirm thresholds (Jar→Grid ~15–25; hide count ~50) during Phase 6.

---

## Suggested next action

Begin **Phase 1** — wire the SwiftData container, add the deterministic demo-persona seeder, build the pure `cellStates` builder, and render `LifeGridView` so you can see the glowing grid on launch. (And, if you agree, add the unit-test target first.)
