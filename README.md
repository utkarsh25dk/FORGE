# FORGE

A native SwiftUI workout tracker for iOS. It builds a training plan around the equipment you
actually own, teaches how each movement is performed, and tracks what you did — entirely on device.

<sub>iOS 26 · SwiftUI · 86 Swift files · no dependencies · no network calls</sub>

---

## What it does

**Builds a plan you can actually follow.** Seven questions — what you can train with, which dumbbell
weights you own, how often you train now, how often you'd like to, how long a session can be, and
what you're training for — and FORGE generates a four-week program from them. Every exercise in it is
one you can perform with what you have.

**Knows a bench isn't a dumbbell.** The library records one equipment tag per exercise, which isn't
enough: an Incline Dumbbell Press is tagged "Dumbbell" but is impossible without an adjustable bench,
and Pull-Ups are tagged "Bodyweight" but need a bar. A separate requirements table covers the
difference, so the app never claims you can do something you can't.

**Teaches the movement.** 186 of the 250 exercises carry written form guidance: numbered steps,
breathing, the specific ways the movement goes wrong, and both a regression and a progression. The
remaining 64 — walks, wind-downs, sports — carry none, because they have nothing to teach. Absence is
a deliberate state, not a gap.

**Coaches from your actual history.** An on-device model reads your recent training and comments on
what it sees: a push-heavy fortnight, a posterior chain that hasn't been touched in two weeks, a
muscle group missing entirely.

**The rest.** Multi-week programs with a day-by-day schedule, streaks, XP and badges, hydration and
sleep check-ins, body measurements, personal records, a calendar heatmap, home screen widgets, and
Live Activities during a workout.

## Privacy

FORGE makes no network calls. Not "anonymized telemetry" or "we don't sell your data" — there is no
networking code in the project at all, which you can check:

```bash
grep -rE "URLSession|URLRequest|\.dataTask" --include="*.swift" FORGE ForgeWidget
```

Accounts are local. Training data lives in Application Support on the device. The coach runs through
Apple's Foundation Models framework, on device. Passwords are hashed with PBKDF2-HMAC-SHA256 at
600,000 iterations.

## Building

Requires Xcode 26 or later.

```bash
git clone git@github.com:utkarsh25dk/FORGE.git
cd FORGE
open FORGE.xcodeproj
```

**The Xcode project is generated, not hand-edited.** After adding, removing or renaming any Swift
file, regenerate it:

```bash
python3 generate_project.py
```

Object IDs are derived from file paths rather than random, so regenerating with no source changes
reproduces `project.pbxproj` byte for byte, and adding one file changes about four lines instead of
rewriting the whole thing. Don't edit the pbxproj by hand — it will be overwritten.

## Project structure

```
FORGE/
  App/           Design system, shared components, app entry, App Intents
  Models/        Exercise library, form guidance, programs, equipment, gamification
  Persistence/   Store, auth, app state, coach engine, program + equipment engines
  Features/      One directory per screen area
ForgeWidget/     Home screen widgets and Live Activities
```

Two data tables are worth knowing about, because both are keyed rather than duplicated per exercise:

- **`ExerciseAttributes`** maps `(category, subgroup)` to muscles and movement pattern. The 50 pairs
  cover all 250 exercises, so `ExerciseLibrary.swift` stays a clean list of one-line definitions and a
  new exercise inherits correct data for free.
- **`ExerciseForm`** is keyed by exercise id, so guidance lands in batches without touching the library.

## Design system

Everything comes from `App/DesignSystem.swift`. Dark-first; the light palette is a considered
translation rather than an inversion.

| | |
|---|---|
| Accent | `#FA5F4A` dark · `#C2410C` light |
| Ground | `#0A0B0A` dark · `#F2F4EF` light |
| Display / numerals | Space Grotesk Bold |
| Body | Manrope |
| Spacing | 4, 8, 12, 16, 24, 32 |
| Radii | 8, 12, 16 |

The fire gradient (`#FFB03C → #FF5C2E → #FF2D3E`) is reserved for exactly one hero moment per
screen — the streak. Never headings, icons, buttons or backgrounds.

Copy is US English. No emoji anywhere; that's enforced by the design spec, not preference.

## A note on data

FORGE's exercise library and all written guidance are original. Two external sources were evaluated
and rejected as data sources:

- **[DAREBEE](https://darebee.com)** is CC BY-NC-ND, which forbids inclusion in an app. Their terms do
  welcome linking, so 16 exercises link out to their video demonstrations — each verified against the
  exercise's own description rather than matched on name, because their "Leg Extensions" is a donkey
  kick and their "Tricep Dips" is the floor version. DAREBEE is a free, ad-free, non-profit resource
  and worth supporting.
- **A public-domain exercise dataset** covered 16% of this library and matched the wrong movement
  often enough to be unusable.

## Licence

Source code is MIT — see [LICENSE](LICENSE).

The bundled Manrope and Space Grotesk fonts are **not** covered by it. They are third-party works
under the SIL Open Font License 1.1 and ship with their license texts. See [NOTICE](NOTICE).
