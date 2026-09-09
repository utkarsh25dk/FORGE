import Foundation

/// Which side of the body a muscle is visible from on the map.
enum BodyView: String, Codable, Hashable, CaseIterable {
    case front, back

    var label: String { rawValue.uppercased() }
}

/// A specific muscle or muscle head.
///
/// Deliberately finer than a training category: "chest" tells you almost nothing,
/// because an incline press, a flat press and a dip load noticeably different
/// parts of it. Each case carries where it sits on the body map, so the same data
/// drives both the written list and the diagram.
enum Muscle: String, Codable, CaseIterable, Hashable, Identifiable {
    // Chest
    case chestUpper, chestMid, chestLower
    // Back
    case lats, trapsUpper, trapsMid, rhomboids, erectors
    // Shoulders
    case deltAnterior, deltLateral, deltPosterior
    // Arms
    case biceps, triceps, forearms
    // Core
    case absUpper, absLower, obliques
    // Legs
    case glutes, quads, hamstrings, adductors, abductors, calves, soleus
    // Systemic — no single place on the map
    case cardiovascular

    var id: String { rawValue }

    var name: String {
        switch self {
        case .chestUpper: return "Upper chest"
        case .chestMid: return "Mid chest"
        case .chestLower: return "Lower chest"
        case .lats: return "Lats"
        case .trapsUpper: return "Upper traps"
        case .trapsMid: return "Mid traps"
        case .rhomboids: return "Rhomboids"
        case .erectors: return "Lower back"
        case .deltAnterior: return "Front delts"
        case .deltLateral: return "Side delts"
        case .deltPosterior: return "Rear delts"
        case .biceps: return "Biceps"
        case .triceps: return "Triceps"
        case .forearms: return "Forearms"
        case .absUpper: return "Upper abs"
        case .absLower: return "Lower abs"
        case .obliques: return "Obliques"
        case .glutes: return "Glutes"
        case .quads: return "Quads"
        case .hamstrings: return "Hamstrings"
        case .adductors: return "Inner thigh"
        case .abductors: return "Outer hip"
        case .calves: return "Calves"
        case .soleus: return "Soleus"
        case .cardiovascular: return "Cardiovascular"
        }
    }

    /// Coarse grouping, used to summarise a long list into something readable.
    var group: String {
        switch self {
        case .chestUpper, .chestMid, .chestLower: return "Chest"
        case .lats, .trapsUpper, .trapsMid, .rhomboids: return "Back"
        case .erectors: return "Lower back"
        case .deltAnterior, .deltLateral, .deltPosterior: return "Shoulders"
        case .biceps, .triceps, .forearms: return "Arms"
        case .absUpper, .absLower, .obliques: return "Core"
        case .glutes, .quads, .hamstrings, .adductors, .abductors: return "Legs"
        case .calves, .soleus: return "Calves"
        case .cardiovascular: return "Cardiovascular"
        }
    }

    /// The muscles people under-train because a mirror doesn't show them.
    var isPosteriorChain: Bool {
        switch self {
        case .lats, .trapsMid, .rhomboids, .erectors, .glutes, .hamstrings, .deltPosterior:
            return true
        default: return false
        }
    }

    /// False for systemic effects, which can't be "not trained in two weeks"
    /// in any meaningful sense.
    var isSpecificMuscle: Bool { self != .cardiovascular }
}
