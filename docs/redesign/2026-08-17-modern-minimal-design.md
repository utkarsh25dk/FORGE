# FORGE — Modern Minimal Redesign

Status: approved, not yet built. Baseline commit: `9bf584c`.

## Why

FORGE's current visual language is maximalist/gamified: the fire gradient
(`FFB03C → FF5C2E → FF2D3E`) is applied to nearly every number and heading,
every card has a radial glow halo and a two-stop gradient fill, and copy
mixes emoji with SF Symbols. The goal is a modern, minimal pass: pick one
place per screen for color/gradient to do work, and let typography and
whitespace carry the rest. Layout structure (5-tab app, card-based Home,
existing feature set) stays the same — this is a visual/token pass, not a
rearchitecture.

## Scope: 10 changes, ordered into 6 phases by dependency

Phase 1 (design-system foundation) must land first — phases 2-3 depend on
its new tokens. Phases 4-6 are independent of each other and of phases 2-3;
they can be built and verified in any order once Phase 1 is done.

### Phase 1 — Design system foundation
*Files: `FORGE/App/DesignSystem.swift`*
1. **Single-accent discipline** — `fireGradient` no longer applied by
   default everywhere; reserve it for one named hero use per screen.
2. **Drop the glow halos** — remove `fireGlow`/`accentGlow` radial gradients
   as default card chrome; `cardGradient` fill replaced by flat surface +
   1px hairline border as the default card style.
3. **No emoji as UI icons** — SF Symbols only, app-wide rule (enforced in
   later phases wherever copy currently embeds emoji).
4. **Typography over color for hierarchy** — hierarchy driven by
   weight/size; color reserved for state (worked/rest/missed,
   positive/negative), not decoration.

### Phase 2 — Home screen
*Files: `FORGE/Features/Home/HomeView.swift`, `HomeCards.swift`*
5. Collapse the five stacked cards (Streak, WeeklyGoal, Level, Hydration,
   Sleep) into one continuous "Today" surface separated by hairline
   dividers instead of card-in-card chrome.
6. Streak/Level/WeeklyGoal become chrome-free numeral tiles (big quiet
   number, small caption) instead of bordered/glowing cards. Drop the
   hydration emoji per Phase 1 rule 3.

### Phase 3 — Progress / Calendar
*Files: `FORGE/Features/Progress/CalendarHeatmapView.swift`,
`MonthCalendarView.swift`, `WeekCalendarView.swift`*
7. Heatmap moves from the current 3-color worked/rest/missed scheme to
   warm-grayscale-plus-single-accent-for-today.

### Phase 4 — Tab bar
*Files: `FORGE/Features/Root/MainTabView.swift`*
8. Unify tab icon weight (Home currently uses branded `flame.fill` while
   others use plain SF Symbols); subtle selected-state instead of default
   heavy-fill treatment.

### Phase 5 — Weekly Recap card
*Files: `FORGE/Features/Profile/WeeklyRecapCard.swift`*
9. Pare back to graph + streak + one comparison line; drop the category
   breakdown and PR list sections added in the prior pass, lean on
   whitespace.

### Phase 6 — Auth / Onboarding
*Files: `FORGE/Features/Auth/AuthContainerView.swift`, `OnboardingView.swift`,
`LoginView.swift`, `SignUpView.swift`*
10. Editorial, type-led, left-aligned layout replacing the centered
    icon+gradient+CTA template look. Built last: self-contained, highest
    risk of regressing into a "generic AI app" look, easiest to isolate.

## Verification (per phase)

No automated UI test suite exists for this app. Use the pattern already
established in this repo:

1. Build for the simulator (`iPhone 17`, UDID
   `2AA23B87-6234-44DD-A053-FBBC472CB1A2`) via
   `xcodebuild -project FORGE.xcodeproj -scheme FORGE -destination 'id=<udid>' build`.
   Re-run `python3 generate_project.py` first if the file tree changed.
2. If the changed screen isn't reachable through normal navigation with
   current app state, temporarily force it via a hardcoded `if true { ... }`
   short-circuit in `RootView.swift` — never leave this in place.
3. Install + launch on the simulator, screenshot via
   `xcrun simctl io <udid> screenshot`, inspect visually against this spec's
   intent (flat, quiet, one accent moment) for both dark and light
   `ThemeMode`.
4. Revert any temporary test harness / mocked data before moving on.
5. `git add -A && git commit` with a message naming the phase and item
   numbers (e.g. "Phase 2: collapse Home cards, numeral tiles (items 5, 6)").
6. Update `docs/redesign/progress.csv` — flip the row's `status` to `done`.

Physical-device deployment (WhizSama, UDID `00008150-000131061A39401C`) is
blocked separately on the phone reconnecting (`devicectl` last showed it
`unavailable`, tunnel down since 2026-08-09) — this is a pre-existing,
unrelated issue also affecting home/lock screen widgets. Do the whole
redesign in simulator; note in the final report that a device rebuild will
pick up both fixes at once.

## Non-goals

- No change to navigation structure, tab set, or feature scope.
- No change to `ForgeColors` semantic meaning (accent still means accent,
  danger still means danger) — only how often/where color is applied.
- No dark/light mode redesign beyond re-deriving the new flat/hairline
  tokens for both existing palettes in `DesignSystem.swift`.
- Widget/Live Activity code is untouched by this spec.
