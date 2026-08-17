You're picking up a design-system redesign on FORGE, a native SwiftUI iOS
workout app at `~/FORGE` (bundle ID `com.utkarsh25rk.forge`, iOS 26.0
deployment target). It's a git repo (initialized 2026-08-17) — check
`git log` for history so far.

Read these two files first, in full, before touching anything:
1. `docs/redesign/2026-08-17-modern-minimal-design.md` — the design spec:
   why, the 10 changes grouped into 6 phases, exact files per phase, the
   verification procedure, and explicit non-goals.
2. `docs/redesign/progress.csv` — the checklist. Each row is one item;
   `status` is `todo`/`doing`/`done`. This is also mirrored in a Google
   Sheet the user tracks by eye — after you flip a row to `done` here,
   tell the user which rows changed so they can update the Sheet (you
   don't have Sheets access).

Work phase by phase, in order (Phase 1 first — everything else in the spec
depends on its design-system tokens). Within a phase, implement the listed
items together since they touch the same files. For each phase:

- Re-run `python3 generate_project.py` if you added/removed/renamed any
  Swift files (it regenerates `FORGE.xcodeproj/project.pbxproj` by
  scanning the `FORGE/FORGE` and `ForgeWidget` trees — the pbxproj is not
  hand-edited).
- Build for the simulator: `iPhone 17`, UDID
  `2AA23B87-6234-44DD-A053-FBBC472CB1A2`.
  `xcodebuild -project FORGE.xcodeproj -scheme FORGE -destination 'id=2AA23B87-6234-44DD-A053-FBBC472CB1A2' build`
- If the screen you're changing isn't reachable through normal navigation
  given current app state, temporarily force it via a hardcoded
  `if true { ... }` short-circuit in
  `FORGE/Features/Root/RootView.swift` — you MUST revert this before
  moving to the next phase. Never leave test scaffolding in place.
- Install + launch on the simulator, screenshot with
  `xcrun simctl io 2AA23B87-6234-44DD-A053-FBBC472CB1A2 screenshot <path>`,
  and actually look at it against the spec's intent: flat surfaces,
  hairline borders instead of glow/gradient chrome, one accent/gradient
  moment per screen, no emoji. Check both dark and light `ThemeMode`
  (toggle in-app or via the theme manager).
- SourceKit will show stale/false-positive diagnostics after most edits in
  this codebase — trust `xcodebuild` output over inline diagnostics, but
  don't ignore a diagnostic that names a symbol that genuinely doesn't
  exist (check with grep before dismissing).
- Commit with a message naming the phase and item numbers, e.g.
  `Phase 2: collapse Home cards, numeral tiles (items 5, 6)`.
- Update `docs/redesign/progress.csv`: flip the row(s) to `done`, add a
  one-line note if anything deviated from the spec.

Known unrelated issue, do not fix as part of this work: the user's
physical iPhone ("WhizSama") has been unreachable via `devicectl` since
2026-08-09 (free Apple ID provisioning profile likely expired, breaking
home/lock screen widgets). All work here should happen in the simulator.
When the user reconnects their phone, a rebuild+reinstall will refresh
signing and can ship this redesign and fix the widgets in the same pass —
mention that if it comes up, but don't chase it.

Stop and ask the user before starting Phase 6 (Auth/Onboarding) even if
Phases 1-5 went smoothly — it's the highest-risk phase for regressing into
a generic templated look, and worth a quick check-in on direction (mockup
or description) before committing to a full rewrite of 4 screens.
