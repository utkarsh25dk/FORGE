import Foundation

// MARK: - Muscle groups

enum MuscleGroup: String, Codable, CaseIterable, Hashable {
    case chest, back, shoulders, biceps, triceps
    case quads, hamstrings, glutes, calves, hipsAndAdductors
    case abs, obliques, lowerBack
    case fullBody, cardiovascular

    var label: String {
        switch self {
        case .chest: return "Chest"
        case .back: return "Back"
        case .shoulders: return "Shoulders"
        case .biceps: return "Biceps"
        case .triceps: return "Triceps"
        case .quads: return "Quads"
        case .hamstrings: return "Hamstrings"
        case .glutes: return "Glutes"
        case .calves: return "Calves"
        case .hipsAndAdductors: return "Hips & Adductors"
        case .abs: return "Abs"
        case .obliques: return "Obliques"
        case .lowerBack: return "Lower Back"
        case .fullBody: return "Full Body"
        case .cardiovascular: return "Cardiovascular"
        }
    }

    /// The muscles most people under-train because they can't see them in a mirror.
    /// Used by the coach to spot a front-loaded routine.
    var isPosteriorChain: Bool {
        switch self {
        case .back, .hamstrings, .glutes, .lowerBack: return true
        default: return false
        }
    }

    /// Groups that name an actual muscle, as opposed to systemic effects. Only
    /// these are meaningful in "you haven't trained X" style observations.
    var isSpecificMuscle: Bool {
        switch self {
        case .fullBody, .cardiovascular: return false
        default: return true
        }
    }
}

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
    var primary: [MuscleGroup]
    var secondary: [MuscleGroup] = []
    var pattern: MovementPattern
}

/// Muscle and pattern data, keyed by (category, subgroup) rather than by exercise.
/// FORGE's subgroups already partition the library along muscle lines, so 50
/// entries cover all 250 exercises without annotating each one — and adding an
/// exercise to an existing subgroup inherits the right data for free.
enum ExerciseAttributeTable {

    private static let table: [WorkoutCategory: [String: ExerciseAttributes]] = [
        .upperBody: [
            "Chest":     ExerciseAttributes(primary: [.chest], secondary: [.triceps, .shoulders], pattern: .push),
            "Back":      ExerciseAttributes(primary: [.back], secondary: [.biceps], pattern: .pull),
            "Shoulders": ExerciseAttributes(primary: [.shoulders], secondary: [.triceps], pattern: .push),
            "Biceps":    ExerciseAttributes(primary: [.biceps], pattern: .pull),
            "Triceps":   ExerciseAttributes(primary: [.triceps], secondary: [.chest], pattern: .push),
        ],
        .lowerBody: [
            "Quads":                 ExerciseAttributes(primary: [.quads], secondary: [.glutes], pattern: .squat),
            "Hamstrings":            ExerciseAttributes(primary: [.hamstrings], secondary: [.glutes, .lowerBack], pattern: .hinge),
            "Glutes":                ExerciseAttributes(primary: [.glutes], secondary: [.hamstrings], pattern: .hinge),
            "Calves":                ExerciseAttributes(primary: [.calves], pattern: .accessory),
            "Adductors & Abductors": ExerciseAttributes(primary: [.hipsAndAdductors], secondary: [.glutes], pattern: .accessory),
        ],
        .fullBody: [
            "Compound Lifts":  ExerciseAttributes(primary: [.fullBody], secondary: [.glutes, .hamstrings, .back, .quads], pattern: .hinge),
            "Circuit Training": ExerciseAttributes(primary: [.fullBody], secondary: [.cardiovascular], pattern: .conditioning),
            "Functional":      ExerciseAttributes(primary: [.fullBody], secondary: [.back, .shoulders], pattern: .carry),
            "Kettlebell":      ExerciseAttributes(primary: [.fullBody], secondary: [.glutes, .hamstrings, .shoulders], pattern: .hinge),
            "Bodyweight Flow": ExerciseAttributes(primary: [.fullBody], secondary: [.abs, .cardiovascular], pattern: .conditioning),
        ],
        .core: [
            "Upper Abs":             ExerciseAttributes(primary: [.abs], pattern: .core),
            "Lower Abs":             ExerciseAttributes(primary: [.abs], secondary: [.hipsAndAdductors], pattern: .core),
            "Obliques":              ExerciseAttributes(primary: [.obliques], secondary: [.abs], pattern: .core),
            "Deep Core & Stability": ExerciseAttributes(primary: [.abs], secondary: [.lowerBack, .obliques], pattern: .core),
            "Lower Back":            ExerciseAttributes(primary: [.lowerBack], secondary: [.glutes], pattern: .core),
        ],
        .cardio: [
            "Steady-State":     ExerciseAttributes(primary: [.cardiovascular], pattern: .conditioning),
            "Intervals":        ExerciseAttributes(primary: [.cardiovascular], secondary: [.quads], pattern: .conditioning),
            "Incline & Stairs": ExerciseAttributes(primary: [.cardiovascular], secondary: [.quads, .glutes, .calves], pattern: .conditioning),
            "Cycling":          ExerciseAttributes(primary: [.cardiovascular], secondary: [.quads], pattern: .conditioning),
            "Rowing":           ExerciseAttributes(primary: [.cardiovascular], secondary: [.back, .quads], pattern: .conditioning),
        ],
        .hiit: [
            "Bodyweight HIIT": ExerciseAttributes(primary: [.cardiovascular], secondary: [.fullBody], pattern: .conditioning),
            "Equipment HIIT":  ExerciseAttributes(primary: [.cardiovascular], secondary: [.fullBody], pattern: .conditioning),
            "Tabata":          ExerciseAttributes(primary: [.cardiovascular], secondary: [.fullBody], pattern: .conditioning),
            "EMOM":            ExerciseAttributes(primary: [.cardiovascular], secondary: [.fullBody], pattern: .conditioning),
            "Circuit HIIT":    ExerciseAttributes(primary: [.cardiovascular], secondary: [.fullBody], pattern: .conditioning),
        ],
        .flexibility: [
            "Static Stretching":       ExerciseAttributes(primary: [.fullBody], pattern: .mobility),
            "Dynamic Mobility":        ExerciseAttributes(primary: [.fullBody], pattern: .mobility),
            "Yoga Flow":               ExerciseAttributes(primary: [.fullBody], secondary: [.abs], pattern: .mobility),
            "Foam Rolling":            ExerciseAttributes(primary: [.fullBody], pattern: .mobility),
            "Hip & Shoulder Mobility": ExerciseAttributes(primary: [.hipsAndAdductors], secondary: [.shoulders], pattern: .mobility),
        ],
        .recovery: [
            "Active Recovery":  ExerciseAttributes(primary: [.cardiovascular], pattern: .recovery),
            "Breathwork":       ExerciseAttributes(primary: [.cardiovascular], pattern: .recovery),
            "Light Walk":       ExerciseAttributes(primary: [.cardiovascular], pattern: .recovery),
            "Restorative Yoga": ExerciseAttributes(primary: [.fullBody], pattern: .recovery),
            "Sleep & Rest":     ExerciseAttributes(primary: [.fullBody], pattern: .recovery),
        ],
        .activity: [
            "Walking & Hiking": ExerciseAttributes(primary: [.cardiovascular], secondary: [.quads, .calves], pattern: .conditioning),
            "Cycling":          ExerciseAttributes(primary: [.cardiovascular], secondary: [.quads], pattern: .conditioning),
            "Swimming":         ExerciseAttributes(primary: [.cardiovascular], secondary: [.back, .shoulders], pattern: .conditioning),
            "Dancing":          ExerciseAttributes(primary: [.cardiovascular], secondary: [.fullBody], pattern: .conditioning),
            "Outdoor Play":     ExerciseAttributes(primary: [.cardiovascular], secondary: [.fullBody], pattern: .conditioning),
        ],
        .sports: [
            "Basketball":    ExerciseAttributes(primary: [.cardiovascular], secondary: [.quads, .calves], pattern: .conditioning),
            "Soccer":        ExerciseAttributes(primary: [.cardiovascular], secondary: [.quads, .hamstrings], pattern: .conditioning),
            "Tennis":        ExerciseAttributes(primary: [.cardiovascular], secondary: [.shoulders, .obliques], pattern: .conditioning),
            "Combat Sports": ExerciseAttributes(primary: [.cardiovascular], secondary: [.fullBody, .obliques], pattern: .conditioning),
            "Climbing":      ExerciseAttributes(primary: [.back], secondary: [.biceps, .cardiovascular], pattern: .pull),
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
            ?? ExerciseAttributes(primary: [.fullBody], pattern: .conditioning)
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
    var attributes: ExerciseAttributes {
        ExerciseAttributeTable.attributes(category: category, subgroup: subgroup)
    }
    var primaryMuscles: [MuscleGroup] { attributes.primary }
    var secondaryMuscles: [MuscleGroup] { attributes.secondary }
    var allMuscles: [MuscleGroup] { attributes.primary + attributes.secondary }
    var movementPattern: MovementPattern { attributes.pattern }
    var level: ProgramLevel { ExerciseDifficulty.level(for: self) }
}

extension WorkoutEntry {
    /// Attributes for a logged entry, resolved through the library. Falls back to
    /// the category/subgroup table so custom entries still classify.
    var movementPattern: MovementPattern {
        ExerciseAttributeTable.attributes(category: category, subgroup: subgroup ?? "").pattern
    }
    var muscles: [MuscleGroup] {
        let a = ExerciseAttributeTable.attributes(category: category, subgroup: subgroup ?? "")
        return a.primary + a.secondary
    }
}
