import Foundation

/// FORGE's built-in training plans. Every slot references an `ExerciseLibrary`
/// template by id, so a program never restates exercise data it can inherit.
enum ProgramLibrary {

    // MARK: helpers

    private static func slot(_ id: String, sets: Int? = nil, reps: Int? = nil, hold: Int? = nil, min: Int? = nil) -> ProgramSlot {
        ProgramSlot(exerciseId: id, sets: sets, reps: reps, holdSec: hold, durationMin: min)
    }
    private static func rest(_ title: String) -> ProgramDay {
        ProgramDay(title: title, focus: nil, slots: [])
    }
    private static func day(_ title: String, _ focus: WorkoutCategory, _ slots: [ProgramSlot]) -> ProgramDay {
        ProgramDay(title: title, focus: focus, slots: slots)
    }

    // MARK: - First Fourteen

    /// Two weeks, no equipment, nothing longer than about twenty minutes. Built for
    /// someone whose actual problem is showing up, not intensity.
    static let firstFourteen = Program(
        id: "first-fourteen",
        name: "First Fourteen",
        tagline: "Two weeks. No equipment. Just show up.",
        summary: """
        Fourteen days of short, unglamorous sessions designed around one goal: proving to \
        yourself that you train now. Nothing here takes more than twenty minutes and nothing \
        needs equipment. Week two repeats week one with a little more volume — not because \
        two weeks builds much strength, but because repeating a week is how you find out \
        whether the schedule actually fits your life. If a day feels like too much, cut the \
        last exercise and finish the rest. A short completed day beats a perfect abandoned one.
        """,
        level: .beginner,
        equipment: "None",
        weekPattern: [
            day("Foundations", .fullBody, [
                slot("fb-flow-2", sets: 2, reps: 8),
                slot("ub-chest-3", sets: 2, reps: 8),
                slot("lb-glutes-2", sets: 2, reps: 12),
                slot("core-deep-1", sets: 2, hold: 20),
            ]),
            day("Easy Miles", .recovery, [
                slot("rec-walk-1", min: 20),
                slot("flex-dyn-2", min: 2),
            ]),
            day("Core & Control", .core, [
                slot("core-deep-2", sets: 2, reps: 10),
                slot("core-lower-2", sets: 2, reps: 10),
                slot("core-lowback-1", sets: 2, hold: 15),
                slot("core-lowback-5", min: 3),
            ]),
            rest("Rest"),
            day("Move Everything", .fullBody, [
                slot("fb-circuit-3", sets: 2, reps: 20),
                slot("fb-flow-1", sets: 2, reps: 8),
                slot("lb-adduct-3", sets: 2, reps: 12),
                slot("core-oblique-2", sets: 2, hold: 15),
            ]),
            day("Open Up", .flexibility, [
                slot("flex-dyn-5", min: 4),
                slot("flex-static-1", sets: 2, hold: 30),
                slot("flex-hip-1", sets: 2, hold: 30),
                slot("flex-static-3", sets: 2, hold: 30),
            ]),
            rest("Rest"),
        ],
        weeks: [
            WeekProgression(label: "Week 1 — Learn the shape",
                            note: "Get through every day once. Don't chase difficulty; chase attendance."),
            WeekProgression(label: "Week 2 — Same days, more of them",
                            note: "One extra set on everything. Same movements, so you can feel the difference directly.",
                            setsDelta: 1, repsDelta: 2, holdDeltaSec: 5),
        ]
    )

    // MARK: - Groundwork

    /// Four weeks of straight sets. The classic base-building shape: build, add
    /// volume, slow down, peak.
    static let groundwork = Program(
        id: "groundwork",
        name: "Groundwork",
        tagline: "Four weeks of straight sets to build a real base.",
        summary: """
        Groundwork is a 28-day strength base for people who've been training on and off \
        without a plan. No circuits: finish all sets of one exercise, rest, then move on. \
        The rest is doing real work, so take it. Each week changes one variable and only \
        one — week 1 sets the baseline, week 2 adds a set, week 3 keeps the volume but \
        slows every rep down, and week 4 peaks. Dumbbells help on a few movements but \
        nothing here requires them; do the bodyweight version and add reps instead. \
        When you finish, run it again with slightly more load — that second cycle is \
        where most of the strength actually shows up.
        """,
        level: .intermediate,
        equipment: "Bodyweight, dumbbells optional",
        weekPattern: [
            day("Push", .upperBody, [
                slot("ub-chest-3", sets: 3, reps: 10),
                slot("ub-triceps-5", sets: 3, reps: 8),
                slot("ub-shoulders-2", sets: 3, reps: 12),
                slot("core-deep-1", sets: 3, hold: 30),
            ]),
            day("Legs", .lowerBody, [
                slot("lb-quads-3", sets: 3, reps: 10),
                slot("lb-glutes-2", sets: 3, reps: 15),
                slot("lb-hams-5", sets: 3, reps: 8),
                slot("lb-calves-4", sets: 3, reps: 12),
            ]),
            rest("Rest"),
            day("Pull & Core", .upperBody, [
                slot("ub-back-1", sets: 3, reps: 5),
                slot("core-lowback-1", sets: 3, hold: 20),
                slot("core-deep-5", sets: 3, hold: 20),
                slot("core-oblique-2", sets: 3, hold: 25),
            ]),
            day("Full Body", .fullBody, [
                slot("fb-flow-1", sets: 3, reps: 10),
                slot("fb-circuit-5", sets: 3, reps: 15),
                slot("lb-quads-5", sets: 3, reps: 8),
                slot("core-lower-1", sets: 3, reps: 12),
            ]),
            day("Active Recovery", .recovery, [
                slot("rec-active-1", min: 25),
                slot("flex-roll-1", sets: 2, hold: 45),
                slot("flex-hip-4", sets: 2, hold: 40),
            ]),
            rest("Rest"),
        ],
        weeks: [
            WeekProgression(label: "Week 1 — Baseline",
                            note: "Three sets everywhere. Note what each movement actually felt like; you'll want that reference in week 4."),
            WeekProgression(label: "Week 2 — Add a set",
                            note: "A fourth set on everything. Volume is the only thing that changed.",
                            setsDelta: 1),
            WeekProgression(label: "Week 3 — Slow it down",
                            note: "Same four sets, but take three full counts on the lowering half of every rep. Slow is much heavier than it sounds.",
                            setsDelta: 1, repsDelta: -2, holdDeltaSec: 10),
            WeekProgression(label: "Week 4 — Peak",
                            note: "Five sets. This is the heaviest week; if a day falls apart, drop to three sets and finish it anyway.",
                            setsDelta: 2, repsDelta: 2, holdDeltaSec: 15),
        ]
    )

    // MARK: - Still Water

    /// Three weeks of mobility and breathing, for deload blocks or desk-bound weeks.
    static let stillWater = Program(
        id: "still-water",
        name: "Still Water",
        tagline: "Three weeks of mobility, breathing and unhurried movement.",
        summary: """
        Not every block should be hard. Still Water is three weeks of mobility, breathwork \
        and easy walking — useful as a deload between harder programs, during a stressful \
        stretch, or as a way back in after time off. Sessions run ten to twenty-five minutes \
        and none of them will leave you sweating. The holds get longer each week rather than \
        the sessions getting harder, which is the honest way to make progress in mobility. \
        Do it in the evening if you can; most of it doubles as a wind-down.
        """,
        level: .beginner,
        equipment: "Mat, foam roller optional",
        weekPattern: [
            day("Hips", .flexibility, [
                slot("flex-dyn-4", min: 4),
                slot("flex-hip-1", sets: 2, hold: 40),
                slot("flex-hip-2", sets: 2, hold: 45),
                slot("flex-hip-4", sets: 2, hold: 40),
            ]),
            day("Walk & Breathe", .recovery, [
                slot("rec-walk-3", min: 20),
                slot("rec-breath-1", min: 8),
            ]),
            day("Spine", .flexibility, [
                slot("core-lowback-5", min: 4),
                slot("flex-hip-5", sets: 2, hold: 30),
                slot("flex-roll-2", sets: 2, hold: 45),
                slot("core-deep-3", sets: 2, hold: 20),
            ]),
            rest("Rest"),
            day("Legs & Feet", .flexibility, [
                slot("flex-static-1", sets: 2, hold: 35),
                slot("flex-static-2", sets: 2, hold: 35),
                slot("flex-static-5", sets: 2, hold: 35),
                slot("flex-roll-4", sets: 2, hold: 45),
            ]),
            day("Wind Down", .recovery, [
                slot("rec-sleep-1", min: 10),
                slot("rec-restore-2", sets: 2, hold: 60),
                slot("rec-restore-1", sets: 1, hold: 300),
            ]),
            rest("Rest"),
        ],
        weeks: [
            WeekProgression(label: "Week 1 — Find the range",
                            note: "Stop where the stretch first shows up. Don't push past it this week."),
            WeekProgression(label: "Week 2 — Hold longer",
                            note: "Ten more seconds on every hold. Breathe out as you settle deeper.",
                            holdDeltaSec: 10),
            WeekProgression(label: "Week 3 — Settle in",
                            note: "Twenty seconds longer than week 1. This is where connective tissue actually starts to change.",
                            holdDeltaSec: 20, durationDeltaMin: 2),
        ]
    )

    // MARK: - Aggregate

    static let all: [Program] = [firstFourteen, groundwork, stillWater]

    static func byId(_ id: String) -> Program? { all.first { $0.id == id } }
}
