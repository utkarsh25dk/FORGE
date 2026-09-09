import Foundation
import CoreGraphics

/// Which side of the body a muscle is visible from on the map.
enum BodyView: String, Codable, Hashable, CaseIterable {
    case front, back
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

    // MARK: Body map geometry

    /// Which view this muscle is drawn on. `nil` means it isn't drawn at all.
    var bodyView: BodyView? {
        switch self {
        case .chestUpper, .chestMid, .chestLower, .deltAnterior, .deltLateral,
             .biceps, .forearms, .absUpper, .absLower, .obliques,
             .quads, .adductors, .abductors:
            return .front
        case .lats, .trapsUpper, .trapsMid, .rhomboids, .erectors, .deltPosterior,
             .triceps, .glutes, .hamstrings, .calves, .soleus:
            return .back
        case .cardiovascular:
            return nil
        }
    }

    /// Normalised rectangles in a 0-1 space, one per side for bilateral muscles.
    /// Deliberately simple blocks: the map needs to say "this region", not pass
    /// an anatomy exam.
    var regions: [CGRect] {
        func pair(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) -> [CGRect] {
            [CGRect(x: 0.5 - x - w, y: y, width: w, height: h),
             CGRect(x: 0.5 + x,     y: y, width: w, height: h)]
        }
        func mid(_ y: CGFloat, _ w: CGFloat, _ h: CGFloat) -> [CGRect] {
            [CGRect(x: 0.5 - w / 2, y: y, width: w, height: h)]
        }
        switch self {
        // Front. Limb muscles are aligned to the silhouette's arm and leg
        // columns rather than floated over the torso: arms span 0.145-0.280
        // and 0.720-0.855, thighs 0.310-0.485 and 0.515-0.690.
        case .deltAnterior:  return pair(0.190, 0.192, 0.110, 0.058)
        case .deltLateral:   return pair(0.250, 0.206, 0.072, 0.052)
        case .chestUpper:    return mid(0.236, 0.190, 0.032)
        case .chestMid:      return mid(0.272, 0.200, 0.034)
        case .chestLower:    return mid(0.310, 0.184, 0.030)
        case .biceps:        return pair(0.250, 0.258, 0.090, 0.082)
        case .forearms:      return pair(0.255, 0.348, 0.085, 0.095)
        case .absUpper:      return mid(0.344, 0.124, 0.056)
        case .absLower:      return mid(0.404, 0.124, 0.056)
        case .obliques:      return pair(0.070, 0.348, 0.052, 0.104)
        case .abductors:     return pair(0.105, 0.438, 0.070, 0.072)
        case .adductors:     return pair(0.005, 0.478, 0.060, 0.100)
        case .quads:         return pair(0.043, 0.500, 0.120, 0.145)
        // Back
        case .trapsUpper:    return mid(0.192, 0.210, 0.044)
        case .deltPosterior: return pair(0.190, 0.196, 0.110, 0.055)
        case .trapsMid:      return mid(0.240, 0.156, 0.050)
        case .rhomboids:     return mid(0.294, 0.134, 0.044)
        case .lats:          return pair(0.028, 0.266, 0.102, 0.108)
        case .triceps:       return pair(0.250, 0.258, 0.090, 0.085)
        case .erectors:      return mid(0.376, 0.112, 0.070)
        case .glutes:        return pair(0.005, 0.428, 0.115, 0.078)
        case .hamstrings:    return pair(0.043, 0.545, 0.120, 0.128)
        case .calves:        return pair(0.050, 0.700, 0.100, 0.088)
        case .soleus:        return pair(0.055, 0.790, 0.090, 0.055)
        case .cardiovascular: return []
        }
    }
}
