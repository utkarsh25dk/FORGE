# FORGE — Modern Minimal Redesign, Round 2

Status: in progress. Continues the round-1 spec
(`2026-08-17-modern-minimal-design.md`, items 1-10, all shipped as of
commit `a285a1e`). Round 2 covers the screens/primitives round 1 didn't
touch.

## Scope: 10 changes, 8 phases by dependency

### Phase A — Foundation
*Files: `FORGE/App/DesignSystem.swift`, `FORGE/App/Components.swift`,
`FORGE/Features/Progress/WeeklyChartsView.swift`*
1. `Radius` scale tightened (sm 10->8, md 16->12, lg 22->16) — flat cards at
   22pt read bubbly without a gradient to soften them.
2. `ForgeToast` shadow softened (0.25/12pt -> 0.16/8pt) to match the
   hairline/flat language elsewhere.
3. `WeeklyChartsView`'s hardcoded sleep/hydration hex colors promoted to
   real `ForgeColors` tokens (`dataSleep`, `dataHydration`) with distinct
   light/dark values — semantic series color, deliberately separate from
   `accent`.

### Phase B — Train
*Files: `TrainView.swift`, `DaySectionView.swift`, `WorkoutRow.swift`,
`AddWorkoutSheet.swift`, `CopyDaySheet.swift`*

### Phase C — Suggest
*Files: `SuggestView.swift`, `ExerciseListView.swift`,
`ExerciseDetailSheet.swift`, `SubgroupListView.swift`*

### Phase D — Detail sheets
*Files: `DayDetailSheet.swift`, `HydrationDetailSheet.swift`,
`SleepDetailSheet.swift`, `WorkoutBreakdownSheet.swift`,
`TotalWorkoutsDetailSheet.swift`*

### Phase E — Badges
*Files: `BadgeGridView.swift`, `BadgeDetailSheet.swift`*
Move earned/unearned from color+opacity to the calendar's weight-based
language.

### Phase F — Live workout
*Files: `LiveWorkoutView.swift`, `RestTimerView.swift`*
Highest-traffic screen, untouched by round 1.

### Phase G — Widgets
*Files: `ForgeWidget.swift`, `ForgeWaterWidget.swift`,
`LiveWorkoutActivityWidget.swift`*
Separate target; verify via simulator home-screen widget preview, not the
app-screenshot loop.

### Phase H — Motion recalibration
App-wide pass on bounce/spring intensity, done last once every screen's
visuals have settled.

## Verification

Same loop as round 1: build for simulator `2AA23B87-6234-44DD-A053-FBBC472CB1A2`,
screenshot, revert any temporary `RootView` test scaffolding, commit per
phase, update `docs/redesign/progress-2.csv`.
