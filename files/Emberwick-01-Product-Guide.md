# Emberwick — Product Guide
### Doc 1 of 3

**Name:** Emberwick — *a wick carries the flame; each memory is a small light you keep lit.*
**Tagline:** A warm, private map of your life — one good week at a time.
**One-line pitch:** Emberwick turns your life into a grid where every week you've lived is a square, and the good ones light up. Capture wins, hard moments, and small notes, pin each to the week it happened, and shake your Jar to relive a memory you'd forgotten.

**Doc set:**
- **01 — Product Guide** (this doc): what it is, why, principles, feature map, parked ideas.
- **02 — Design & Technical Spec:** screens, flow, visual system, animations, data model, week math, sync, frameworks.
- **03 — Phases & Roadmap:** locked v1 scope, fast-follow phases, risks, open questions.
- **prototype.html:** a runnable HTML/CSS/JS reference — see the note below.

> **About the prototype.** `prototype.html` is a reference for **flow and initial UI feel only.** It does **not** contain all the intended animations — several are far easier and better done natively in SwiftUI and are listed in Doc 02 to be added there. Do **not** replicate the prototype 1:1. Treat it as a starting point; UI, motion, and details will evolve on the go.

**Platform:** iOS, SwiftUI, iPhone-first (iPad later). Private and on-device first.
**Status:** Concept, flow, UI direction, and name locked. Ready to begin the SwiftUI build (start with the grid math — see Doc 02 / Doc 03).

---

## 1. What it is

A merge of two ideas — **Life in Weeks** (your whole life drawn as a grid, one box = one week) and **The Jar** (collect tiny wins, shake to relive a random one). Neither works alone:

- Life in Weeks has instant emotional impact but no reason to return — it's a poster.
- The Jar has a real payoff (rediscovering a forgotten good moment) but the memories pile into a formless, contextless blob.

**Core insight:** the Jar is the *input*, the grid is the *view*. Every moment lands on the week it happened. The grid slowly lights up; the shake arrives *with context* ("this was ~2 years ago").

---

## 2. Guiding principles

- **Warm, not morbid.** Framed as "look how much good has happened, and how much blank canvas is left" — never a death countdown. Same visual, opposite feeling. Protected decision.
- **One home, one mode.** The grid is home; the Jar is a *mode inside it*, not a co-equal second app. If the two feel bolted together, we've drifted.
- **No guilt.** No streaks, no nagging notifications, no obligation. Returning is a pleasure.
- **Motivation from your own life,** not a quote database.
- **Private by default.** On-device first; no feed, no accounts required to start.

---

## 3. Feature map (summary — full detail in Doc 02 & 03)

| Area | v1 (locked) | Later (Doc 03) |
|---|---|---|
| Grid | Full-life grid, day-of-year week mapping, era tint bands | Richer era treatment |
| Entries | One model: win / loss / note — all with notes + optional images | Loss→win threads |
| Tiers | Wins get an optional one-tap tier: **bronze / silver / gold / diamond** (diamond rare) | — |
| Jar | Top-bar mode, all-time scope, weighted shake + tap reveal, tier-scaled reveal effect | Year-in-review replay |
| Home logic | Jar-first until a win-count threshold, then grid; Settings override (Default / Jar / Grid) | — |
| Week view | Calm full-screen page, **no dates** (v1 uses divide logic), entries listed | Dates once calendar-accurate weeks land |
| Resurfacing | "You did this a year ago" (own past win, not quotes) | Widget, negative-space prompts |
| Storage | Local SwiftData | CloudKit sync, manual export |
| Navigation | Tap any cell + pinch to zoom life → year → week | — |

---

## 4. Parked / rejected / low-value ideas
*(Kept on purpose — a rejected idea today may seed a good one later. Each notes the reason and a revisit trigger.)*

- **"Weeks left" / mortality countdown framing.** Parked for tone (anxiety). *Revisit as:* an optional perspective mode for users who explicitly opt in.
- **Fully random memory-box colors.** Reads as noise. Replaced by tier-driven color (and eras as tints).
- **Hard mode flip at exactly 100 wins.** Jarring. Replaced by a smart adaptive default + Settings override.
- **ISO week numbering.** Splits early-January into the prior year's row. Replaced by day-of-year/7 (Doc 02).
- **"Empty the Jar" (destructive/date-locked).** Implied deletion + guilt-trips empty Januarys. Replaced by non-destructive, optional, all-time replay.
- **Generic motivational quotes.** Cheapens the app; clashes with a tone that also holds losses. Replaced by "your own past win." *Revisit as:* tiny hand-curated set, shown rarely — but own-win is better.
- **Supabase as primary backend.** Deprioritized; CloudKit fits private single-user iOS. *Revisit if:* Android/web or shared/multi-user features.
- **Streaks / daily nagging / push.** Rejected by design (anti-habit, no-guilt).
- **Tier over-specification (4+ tiers, forced rating).** Trimmed to 4 optional one-tap tiers. *Note:* tier could later be *implied* by entry richness.

---

## 5. Naming note

**Emberwick** is a coined word (ember + wick), chosen for warmth + ownability. Before launch: **reserve in App Store Connect** and run a quick **trademark search** to confirm it's clear. Rejected: *Ember* (taken — mug app etc.), *Emberly* (taken several times), and the whole *Ever-/-glow/-light + memories* lane (saturated: Everlight, Everlog, Evermore).
