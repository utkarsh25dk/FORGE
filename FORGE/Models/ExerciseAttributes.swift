import Foundation

// MARK: - Muscles

// The muscle taxonomy lives in Muscle.swift. It is finer than a training
// category on purpose: "chest" cannot distinguish an incline press from a dip,
// and the body map needs somewhere specific to light up.

// MARK: - Movement pattern

/// The pattern an exercise trains. Coarser than muscle groups and more useful for
/// balance: push versus pull catches a lopsided routine that muscle counts alone
/// can miss.
enum MovementPattern: String, Codable, CaseIterable, Hashable {
    case push, pull, squat, hinge, carry, core
    case conditioning, mobility, recovery, accessory

    var label: String {
        switch self {
        case .push: return "Push"
        case .pull: return "Pull"
        case .squat: return "Squat"
        case .hinge: return "Hinge"
        case .carry: return "Carry"
        case .core: return "Core"
        case .conditioning: return "Conditioning"
        case .mobility: return "Mobility"
        case .recovery: return "Recovery"
        case .accessory: return "Accessory"
        }
    }
}

// MARK: - Attribute table

struct ExerciseAttributes: Hashable {
    var primary: [Muscle]
    var secondary: [Muscle] = []
    var pattern: MovementPattern
}

/// Muscle and pattern data, keyed by (category, subgroup) rather than by exercise.
/// FORGE's subgroups already partition the library along muscle lines, so 50
/// entries cover all 250 exercises without annotating each one — and adding an
/// exercise to an existing subgroup inherits the right data for free.
enum ExerciseAttributeTable {

    private static let table: [WorkoutCategory: [String: ExerciseAttributes]] = [
        .upperBody: [
            "Chest":     ExerciseAttributes(primary: [.chestMid, .chestLower], secondary: [.triceps, .deltAnterior], pattern: .push),
            "Back":      ExerciseAttributes(primary: [.lats, .rhomboids], secondary: [.biceps, .trapsMid, .forearms], pattern: .pull),
            "Shoulders": ExerciseAttributes(primary: [.deltLateral, .deltAnterior], secondary: [.trapsUpper, .triceps], pattern: .push),
            "Biceps":    ExerciseAttributes(primary: [.biceps], secondary: [.forearms], pattern: .pull),
            "Triceps":   ExerciseAttributes(primary: [.triceps], secondary: [.chestLower], pattern: .push),
        ],
        .lowerBody: [
            "Quads":                 ExerciseAttributes(primary: [.quads], secondary: [.glutes, .adductors], pattern: .squat),
            "Hamstrings":            ExerciseAttributes(primary: [.hamstrings], secondary: [.glutes, .erectors], pattern: .hinge),
            "Glutes":                ExerciseAttributes(primary: [.glutes], secondary: [.hamstrings, .erectors], pattern: .hinge),
            "Calves":                ExerciseAttributes(primary: [.calves, .soleus], pattern: .accessory),
            "Adductors & Abductors": ExerciseAttributes(primary: [.adductors, .abductors], secondary: [.glutes], pattern: .accessory),
        ],
        .fullBody: [
            "Compound Lifts":   ExerciseAttributes(primary: [.glutes, .hamstrings, .erectors, .quads], secondary: [.lats, .trapsUpper, .forearms], pattern: .hinge),
            "Circuit Training": ExerciseAttributes(primary: [.quads, .chestMid, .absUpper], secondary: [.cardiovascular, .deltAnterior], pattern: .conditioning),
            "Functional":       ExerciseAttributes(primary: [.forearms, .trapsUpper, .erectors], secondary: [.glutes, .quads], pattern: .carry),
            "Kettlebell":       ExerciseAttributes(primary: [.glutes, .hamstrings], secondary: [.erectors, .deltAnterior, .forearms], pattern: .hinge),
            "Bodyweight Flow":  ExerciseAttributes(primary: [.absUpper, .chestMid, .quads], secondary: [.cardiovascular, .deltAnterior], pattern: .conditioning),
        ],
        .core: [
            "Upper Abs":             ExerciseAttributes(primary: [.absUpper], secondary: [.obliques], pattern: .core),
            "Lower Abs":             ExerciseAttributes(primary: [.absLower], secondary: [.absUpper], pattern: .core),
            "Obliques":              ExerciseAttributes(primary: [.obliques], secondary: [.absUpper, .absLower], pattern: .core),
            "Deep Core & Stability": ExerciseAttributes(primary: [.absLower, .absUpper], secondary: [.erectors, .obliques], pattern: .core),
            "Lower Back":            ExerciseAttributes(primary: [.erectors], secondary: [.glutes, .hamstrings], pattern: .core),
        ],
        .cardio: [
            "Steady-State":     ExerciseAttributes(primary: [.cardiovascular], secondary: [.quads, .calves], pattern: .conditioning),
            "Intervals":        ExerciseAttributes(primary: [.cardiovascular], secondary: [.quads, .hamstrings], pattern: .conditioning),
            "Incline & Stairs": ExerciseAttributes(primary: [.cardiovascular], secondary: [.quads, .glutes, .calves], pattern: .conditioning),
            "Cycling":          ExerciseAttributes(primary: [.cardiovascular], secondary: [.quads, .calves], pattern: .conditioning),
            "Rowing":           ExerciseAttributes(primary: [.cardiovascular], secondary: [.lats, .quads, .rhomboids], pattern: .conditioning),
        ],
        .hiit: [
            "Bodyweight HIIT": ExerciseAttributes(primary: [.cardiovascular], secondary: [.quads, .absUpper, .chestMid], pattern: .conditioning),
            "Equipment HIIT":  ExerciseAttributes(primary: [.cardiovascular], secondary: [.glutes, .quads, .deltAnterior], pattern: .conditioning),
            "Tabata":          ExerciseAttributes(primary: [.cardiovascular], secondary: [.quads, .chestMid], pattern: .conditioning),
            "EMOM":            ExerciseAttributes(primary: [.cardiovascular], secondary: [.quads, .glutes], pattern: .conditioning),
            "Circuit HIIT":    ExerciseAttributes(primary: [.cardiovascular], secondary: [.quads, .absUpper, .deltAnterior], pattern: .conditioning),
        ],
        .flexibility: [
            "Static Stretching":       ExerciseAttributes(primary: [.hamstrings, .quads], secondary: [.calves, .chestMid], pattern: .mobility),
            "Dynamic Mobility":        ExerciseAttributes(primary: [.adductors, .abductors], secondary: [.hamstrings, .deltAnterior], pattern: .mobility),
            "Yoga Flow":               ExerciseAttributes(primary: [.erectors, .hamstrings], secondary: [.absUpper, .deltAnterior], pattern: .mobility),
            "Foam Rolling":            ExerciseAttributes(primary: [.quads, .lats], secondary: [.calves, .glutes], pattern: .mobility),
            "Hip & Shoulder Mobility": ExerciseAttributes(primary: [.adductors, .glutes], secondary: [.deltPosterior, .erectors], pattern: .mobility),
        ],
        .recovery: [
            "Active Recovery":  ExerciseAttributes(primary: [.cardiovascular], secondary: [.quads], pattern: .recovery),
            "Breathwork":       ExerciseAttributes(primary: [.cardiovascular], pattern: .recovery),
            "Light Walk":       ExerciseAttributes(primary: [.cardiovascular], secondary: [.calves], pattern: .recovery),
            "Restorative Yoga": ExerciseAttributes(primary: [.erectors], secondary: [.glutes, .hamstrings], pattern: .recovery),
            "Sleep & Rest":     ExerciseAttributes(primary: [.cardiovascular], pattern: .recovery),
        ],
        .activity: [
            "Walking & Hiking": ExerciseAttributes(primary: [.cardiovascular], secondary: [.quads, .calves, .glutes], pattern: .conditioning),
            "Cycling":          ExerciseAttributes(primary: [.cardiovascular], secondary: [.quads, .glutes], pattern: .conditioning),
            "Swimming":         ExerciseAttributes(primary: [.cardiovascular], secondary: [.lats, .deltPosterior, .trapsMid], pattern: .conditioning),
            "Dancing":          ExerciseAttributes(primary: [.cardiovascular], secondary: [.quads, .calves], pattern: .conditioning),
            "Outdoor Play":     ExerciseAttributes(primary: [.cardiovascular], secondary: [.quads, .calves], pattern: .conditioning),
        ],
        .sports: [
            "Basketball":    ExerciseAttributes(primary: [.cardiovascular], secondary: [.quads, .calves, .glutes], pattern: .conditioning),
            "Soccer":        ExerciseAttributes(primary: [.cardiovascular], secondary: [.quads, .hamstrings, .adductors], pattern: .conditioning),
            "Tennis":        ExerciseAttributes(primary: [.cardiovascular], secondary: [.deltAnterior, .obliques, .forearms], pattern: .conditioning),
            "Combat Sports": ExerciseAttributes(primary: [.cardiovascular], secondary: [.obliques, .deltAnterior, .calves], pattern: .conditioning),
            "Climbing":      ExerciseAttributes(primary: [.lats, .forearms], secondary: [.biceps, .rhomboids, .cardiovascular], pattern: .pull),
        ],
    ]

    /// Every (category, subgroup) pair the table covers. A subgroup missing here
    /// would silently resolve to the default and carry wrong muscle data, so this
    /// is asserted against the full library rather than trusted.
    static var coveredPairs: Set<String> {
        Set(table.flatMap { cat, subs in subs.keys.map { "\(cat.rawValue)|\($0)" } })
    }

    static func attributes(category: WorkoutCategory, subgroup: String) -> ExerciseAttributes {
        table[category]?[subgroup]
            ?? ExerciseAttributes(primary: [.cardiovascular], pattern: .conditioning)
    }
}

// MARK: - Difficulty

/// Difficulty can't come from the subgroup the way muscles can — "Chest" holds
/// both Push-Ups and the Barbell Bench Press — so it's derived per exercise from
/// equipment and category, with an explicit list for the movements whose demand
/// is skill rather than load.
enum ExerciseDifficulty {

    /// High-skill movements where technique, not strength, is the limiter.
    private static let advanced: Set<String> = [
        "fb-compound-5",   // Snatch
        "fb-compound-2",   // Clean and Press
        "fb-compound-4",   // Barbell Complex
        "fb-kb-3",         // Kettlebell Snatch
        "fb-kb-5",         // Turkish Get-Up
        "sport-climb-4",   // Campus Board Training
    ]

    /// Movements a true beginner usually can't complete a set of, or that carry
    /// enough load/impact to warrant a base first — regardless of equipment.
    private static let intermediate: Set<String> = [
        "ub-back-1",       // Pull-Ups
        "ub-triceps-5",    // Dips
        "lb-quads-5",      // Bulgarian Split Squat
        "lb-hams-5",       // Single-Leg RDL
        "core-deep-5",     // Hollow Body Hold
        "fb-flow-5",       // Burpee Broad Jump
        "fb-func-2",       // Sled Push
        "fb-func-3",       // Tire Flip
        "cardio-incl-3",   // Hill Sprints
        "sport-combat-1",  // Boxing Sparring
        "sport-combat-4",  // Wrestling Practice
    ]

    /// Equipment that implies meaningful external load and a technique floor.
    private static let loadedEquipment: Set<String> = ["Barbell", "Kettlebell"]

    static func level(for template: ExerciseTemplate) -> ProgramLevel {
        if advanced.contains(template.id) { return .advanced }
        if intermediate.contains(template.id) { return .intermediate }
        if loadedEquipment.contains(template.equipment) { return .intermediate }
        // HIIT is defined by working near maximum effort, which assumes a base.
        if template.category == .hiit { return .intermediate }
        return .beginner
    }
}

// MARK: - Template conveniences

extension ExerciseTemplate {
    /// A per-exercise override where one exists, otherwise the subgroup default.
    var attributes: ExerciseAttributes {
        ExerciseMuscleOverrides.overrides[id]
            ?? ExerciseAttributeTable.attributes(category: category, subgroup: subgroup)
    }
    var primaryMuscles: [Muscle] { attributes.primary }
    var secondaryMuscles: [Muscle] { attributes.secondary }
    var allMuscles: [Muscle] { attributes.primary + attributes.secondary }
    var movementPattern: MovementPattern { attributes.pattern }
    var level: ProgramLevel { ExerciseDifficulty.level(for: self) }
}

extension WorkoutEntry {
    /// Attributes for a logged entry, resolved through the library. Falls back to
    /// the category/subgroup table so custom entries still classify.
    var movementPattern: MovementPattern {
        ExerciseAttributeTable.attributes(category: category, subgroup: subgroup ?? "").pattern
    }
    var muscles: [Muscle] {
        let a = ExerciseAttributeTable.attributes(category: category, subgroup: subgroup ?? "")
        return a.primary + a.secondary
    }
}

// MARK: - Per-exercise overrides

/// Muscle data for exercises whose subgroup default would mislead.
///
/// The subgroup table is right about the region but blind to variation within
/// it, and within a subgroup the variation is often the entire reason the
/// exercise exists. An incline press is in "Chest" but trains the upper chest;
/// a seated calf raise is in "Calves" but exists specifically for the soleus;
/// a lateral raise is in "Shoulders" but is the one movement that isolates the
/// side delt. Saying "chest" for all five chest exercises is what this feature
/// was built to stop doing.
enum ExerciseMuscleOverrides {

    /// Declared as an array rather than a dictionary literal on purpose.
    /// A Swift dictionary literal with a repeated key traps at runtime, not at
    /// compile time — this table had eight duplicates at one point and the app
    /// would have crashed on launch rather than failing a build. As an array the
    /// duplicates are inspectable, and `duplicateIds` is asserted empty in tests.
    private static let entries: [(String, ExerciseAttributes)] = [
        // Chest — the angle is the exercise
        ("ub-chest-1", ExerciseAttributes(primary: [.chestMid], secondary: [.triceps, .deltAnterior], pattern: .push)),
        ("ub-chest-2", ExerciseAttributes(primary: [.chestUpper], secondary: [.deltAnterior, .triceps], pattern: .push)),
        ("ub-chest-3", ExerciseAttributes(primary: [.chestMid, .chestLower], secondary: [.triceps, .absUpper], pattern: .push)),
        ("ub-chest-4", ExerciseAttributes(primary: [.chestMid, .chestUpper], secondary: [.deltAnterior], pattern: .push)),
        ("ub-chest-5", ExerciseAttributes(primary: [.chestLower, .lats], secondary: [.triceps], pattern: .push)),

        // Back — a row and a pulldown are not the same movement
        ("ub-back-1", ExerciseAttributes(primary: [.lats], secondary: [.biceps, .rhomboids, .forearms], pattern: .pull)),
        ("ub-back-2", ExerciseAttributes(primary: [.lats, .rhomboids], secondary: [.trapsMid, .biceps, .erectors], pattern: .pull)),
        ("ub-back-3", ExerciseAttributes(primary: [.lats], secondary: [.biceps, .rhomboids], pattern: .pull)),
        ("ub-back-4", ExerciseAttributes(primary: [.rhomboids, .trapsMid], secondary: [.lats, .biceps], pattern: .pull)),
        ("ub-back-5", ExerciseAttributes(primary: [.lats], secondary: [.rhomboids, .biceps], pattern: .pull)),

        // Shoulders — three heads, three different exercises
        ("ub-shoulders-1", ExerciseAttributes(primary: [.deltAnterior, .deltLateral], secondary: [.triceps, .trapsUpper], pattern: .push)),
        ("ub-shoulders-2", ExerciseAttributes(primary: [.deltLateral], secondary: [.trapsUpper], pattern: .accessory)),
        ("ub-shoulders-3", ExerciseAttributes(primary: [.deltAnterior, .deltLateral], secondary: [.triceps], pattern: .push)),
        ("ub-shoulders-4", ExerciseAttributes(primary: [.deltPosterior], secondary: [.rhomboids, .trapsMid], pattern: .pull)),
        ("ub-shoulders-5", ExerciseAttributes(primary: [.deltAnterior], secondary: [.trapsUpper], pattern: .accessory)),

        // Arms
        ("ub-biceps-2", ExerciseAttributes(primary: [.biceps, .forearms], pattern: .pull)),
        ("ub-biceps-3", ExerciseAttributes(primary: [.biceps], secondary: [.forearms], pattern: .pull)),
        ("ub-triceps-1", ExerciseAttributes(primary: [.triceps], secondary: [.chestMid, .deltAnterior], pattern: .push)),
        ("ub-triceps-5", ExerciseAttributes(primary: [.triceps, .chestLower], secondary: [.deltAnterior], pattern: .push)),

        // Legs — the seated calf raise exists for the soleus specifically
        ("lb-calves-1", ExerciseAttributes(primary: [.calves], secondary: [.soleus], pattern: .accessory)),
        ("lb-calves-2", ExerciseAttributes(primary: [.soleus], secondary: [.calves], pattern: .accessory)),
        ("lb-calves-3", ExerciseAttributes(primary: [.calves], secondary: [.soleus], pattern: .accessory)),
        ("lb-calves-4", ExerciseAttributes(primary: [.calves], secondary: [.soleus], pattern: .accessory)),
        ("lb-adduct-1", ExerciseAttributes(primary: [.adductors], pattern: .accessory)),
        ("lb-adduct-2", ExerciseAttributes(primary: [.abductors], secondary: [.glutes], pattern: .accessory)),
        ("lb-adduct-3", ExerciseAttributes(primary: [.abductors], secondary: [.glutes], pattern: .accessory)),
        ("lb-adduct-5", ExerciseAttributes(primary: [.abductors], secondary: [.glutes], pattern: .accessory)),

        // Core — upper, lower and rotational are genuinely different
        ("core-deep-4", ExerciseAttributes(primary: [.obliques, .absLower], secondary: [.erectors], pattern: .core)),
        ("core-lowback-1", ExerciseAttributes(primary: [.erectors], secondary: [.glutes, .trapsMid], pattern: .core)),
        ("core-lowback-4", ExerciseAttributes(primary: [.lats, .erectors], secondary: [.rhomboids], pattern: .pull)),

        // Quads — the subgroup name says "quads" for all five, but a leg
        // extension is an isolation and a back squat is a whole-body lift.
        ("lb-quads-1", ExerciseAttributes(primary: [.quads], secondary: [.glutes, .adductors, .erectors, .absUpper], pattern: .squat)),
        ("lb-quads-2", ExerciseAttributes(primary: [.quads], secondary: [.glutes], pattern: .squat)),
        ("lb-quads-3", ExerciseAttributes(primary: [.quads, .glutes], secondary: [.adductors, .calves], pattern: .squat)),
        // Nothing but knee extension: no hip, no trunk, no glute.
        ("lb-quads-4", ExerciseAttributes(primary: [.quads], pattern: .accessory)),
        ("lb-quads-5", ExerciseAttributes(primary: [.quads, .glutes], secondary: [.adductors, .abductors], pattern: .squat)),

        // Hamstrings — hip hinges versus one pure knee flexion.
        ("lb-hams-1", ExerciseAttributes(primary: [.hamstrings, .glutes], secondary: [.erectors, .forearms], pattern: .hinge)),
        ("lb-hams-2", ExerciseAttributes(primary: [.hamstrings], secondary: [.calves], pattern: .accessory)),
        ("lb-hams-3", ExerciseAttributes(primary: [.hamstrings, .erectors], secondary: [.glutes], pattern: .hinge)),
        ("lb-hams-4", ExerciseAttributes(primary: [.hamstrings, .glutes], secondary: [.erectors, .deltAnterior, .forearms], pattern: .hinge)),
        ("lb-hams-5", ExerciseAttributes(primary: [.hamstrings, .glutes], secondary: [.erectors, .obliques], pattern: .hinge)),

        // Glutes — a kickback isolates, a sumo deadlift is a whole posterior
        // chain lift that also loads the adductors through the wide stance.
        ("lb-glutes-1", ExerciseAttributes(primary: [.glutes], secondary: [.hamstrings, .quads], pattern: .hinge)),
        ("lb-glutes-2", ExerciseAttributes(primary: [.glutes], secondary: [.hamstrings], pattern: .hinge)),
        ("lb-glutes-3", ExerciseAttributes(primary: [.glutes], pattern: .accessory)),
        ("lb-glutes-4", ExerciseAttributes(primary: [.glutes, .adductors], secondary: [.hamstrings, .quads, .erectors, .trapsUpper], pattern: .hinge)),
        ("lb-glutes-5", ExerciseAttributes(primary: [.glutes, .quads], secondary: [.calves, .abductors], pattern: .squat)),

        // Upper abs — a full sit-up recruits the hip flexors, a crunch does not.
        // The form guidance warns about exactly that, so the map should show it.
        ("core-upper-1", ExerciseAttributes(primary: [.absUpper], pattern: .core)),
        ("core-upper-2", ExerciseAttributes(primary: [.absUpper], secondary: [.hipFlexors, .absLower], pattern: .core)),
        ("core-upper-3", ExerciseAttributes(primary: [.absUpper], secondary: [.obliques], pattern: .core)),
        ("core-upper-4", ExerciseAttributes(primary: [.absUpper], pattern: .core)),
        ("core-upper-5", ExerciseAttributes(primary: [.absUpper], secondary: [.absLower, .hipFlexors], pattern: .core)),

        // Lower abs — a reverse crunch is a hip curl and stays in the abs; a
        // straight-leg raise leans on the hip flexors, and hanging adds grip.
        ("core-lower-1", ExerciseAttributes(primary: [.absLower], secondary: [.hipFlexors], pattern: .core)),
        ("core-lower-2", ExerciseAttributes(primary: [.absLower], pattern: .core)),
        ("core-lower-3", ExerciseAttributes(primary: [.absLower], secondary: [.hipFlexors], pattern: .core)),
        ("core-lower-4", ExerciseAttributes(primary: [.absLower], secondary: [.hipFlexors, .forearms, .lats], pattern: .core)),
        ("core-lower-5", ExerciseAttributes(primary: [.absLower, .obliques], secondary: [.absUpper], pattern: .core)),

        // Obliques — rotation, lateral flexion and anti-rotation are different
        // jobs, and a side plank is held up by the shoulder.
        ("core-oblique-1", ExerciseAttributes(primary: [.obliques], secondary: [.absUpper], pattern: .core)),
        ("core-oblique-2", ExerciseAttributes(primary: [.obliques, .serratus], secondary: [.deltLateral, .absLower], pattern: .core)),
        ("core-oblique-3", ExerciseAttributes(primary: [.obliques, .serratus], secondary: [.absUpper, .deltAnterior], pattern: .core)),
        ("core-oblique-4", ExerciseAttributes(primary: [.obliques], secondary: [.absLower, .absUpper], pattern: .core)),
        ("core-oblique-5", ExerciseAttributes(primary: [.obliques], pattern: .core)),

        // Circuit and flow work — grouped together by format, but a jumping
        // jack and a bear crawl have almost nothing in common.
        ("fb-circuit-1", ExerciseAttributes(primary: [.quads, .chestMid, .absUpper], secondary: [.cardiovascular, .deltAnterior, .triceps], pattern: .conditioning)),
        ("fb-circuit-2", ExerciseAttributes(primary: [.absLower, .deltAnterior], secondary: [.cardiovascular, .quads, .hipFlexors], pattern: .conditioning)),
        ("fb-circuit-3", ExerciseAttributes(primary: [.cardiovascular], secondary: [.calves, .deltLateral, .abductors], pattern: .conditioning)),
        ("fb-circuit-4", ExerciseAttributes(primary: [.quads, .deltAnterior], secondary: [.glutes, .triceps, .absUpper], pattern: .conditioning)),
        ("fb-circuit-5", ExerciseAttributes(primary: [.deltAnterior, .absUpper], secondary: [.quads, .triceps, .serratus], pattern: .conditioning)),

        ("fb-flow-1", ExerciseAttributes(primary: [.chestMid, .quads], secondary: [.triceps, .cardiovascular], pattern: .conditioning)),
        ("fb-flow-2", ExerciseAttributes(primary: [.absUpper, .hamstrings], secondary: [.deltAnterior, .chestMid], pattern: .conditioning)),
        ("fb-flow-3", ExerciseAttributes(primary: [.absUpper, .deltAnterior], secondary: [.abductors, .obliques], pattern: .conditioning)),
        ("fb-flow-4", ExerciseAttributes(primary: [.deltAnterior, .absUpper], secondary: [.quads, .serratus, .triceps], pattern: .conditioning)),
        ("fb-flow-5", ExerciseAttributes(primary: [.quads, .glutes], secondary: [.cardiovascular, .chestMid, .calves], pattern: .conditioning)),

        // Full body — the big lifts deserve accuracy
        ("fb-compound-1", ExerciseAttributes(primary: [.glutes, .hamstrings, .erectors], secondary: [.quads, .lats, .trapsUpper, .forearms], pattern: .hinge)),
        ("fb-compound-5", ExerciseAttributes(primary: [.trapsUpper, .glutes, .hamstrings], secondary: [.deltLateral, .quads, .erectors], pattern: .hinge)),
        ("fb-func-1", ExerciseAttributes(primary: [.forearms, .trapsUpper], secondary: [.erectors, .obliques], pattern: .carry)),
        ("fb-kb-5", ExerciseAttributes(primary: [.deltAnterior, .obliques], secondary: [.glutes, .absUpper], pattern: .carry)),
    ]

    static let overrides: [String: ExerciseAttributes] =
        Dictionary(entries, uniquingKeysWith: { first, _ in first })

    /// Ids appearing more than once. Must be empty.
    static var duplicateIds: [String] {
        var seen = Set<String>(), dupes = Set<String>()
        for (id, _) in entries where !seen.insert(id).inserted { dupes.insert(id) }
        return dupes.sorted()
    }
}
