import Foundation
import CoreGraphics
import SwiftUI

/// Which side of the body a muscle is visible from on the map.
enum BodyView: String, Codable, Hashable, CaseIterable {
    case front, back, side

    var label: String { rawValue.uppercased() }

    /// Frame width as a fraction of height. A profile is genuinely narrower than
    /// a front view, so giving all three the same box leaves the side figure
    /// stranded in dead space.
    var widthRatio: CGFloat { self == .side ? 0.52 : 0.58 }
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

    /// Views this muscle is visible on. Most muscles show on two: a lat is
    /// visible from behind and in profile, a pectoral from the front and in
    /// profile. The side view is the one that shows front chain against back
    /// chain at a glance.
    var bodyViews: Set<BodyView> {
        switch self {
        case .chestUpper, .chestMid, .chestLower, .absUpper, .absLower, .quads:
            return [.front, .side]
        case .deltAnterior:            return [.front, .side]
        case .deltLateral:             return [.front, .back, .side]
        case .biceps, .forearms:       return [.front, .side]
        case .obliques, .adductors, .abductors: return [.front]
        case .lats, .erectors, .glutes, .hamstrings, .calves:
            return [.back, .side]
        case .trapsUpper:              return [.back, .side]
        case .trapsMid, .rhomboids:    return [.back]
        case .deltPosterior:           return [.back, .side]
        case .triceps:                 return [.back, .side]
        case .soleus:                  return [.back, .side]
        case .cardiovascular:          return []
        }
    }

    /// The shapes a muscle takes on a given view, in a 0-1 space.
    ///
    /// Ellipses and tapered polygons rather than rectangles: a pectoral fans out
    /// from the sternum, a lat is a wing narrowing into the waist, a calf is a
    /// teardrop. Blocks read as a mannequin; these read as a body.
    func shapes(for view: BodyView) -> [MuscleShape] {
        guard bodyViews.contains(view) else { return [] }
        func both(_ s: MuscleShape) -> [MuscleShape] { [s, s.mirroredHorizontally] }

        switch view {
        case .front: return frontShapes(both)
        case .back:  return backShapes(both)
        case .side:  return sideShapes()
        }
    }

    private func frontShapes(_ both: (MuscleShape) -> [MuscleShape]) -> [MuscleShape] {
        switch self {
        case .chestUpper:   return both(.poly([(0.500, 0.226), (0.362, 0.238), (0.348, 0.262), (0.500, 0.256)]))
        case .chestMid:     return both(.poly([(0.500, 0.258), (0.346, 0.264), (0.342, 0.292), (0.500, 0.292)]))
        case .chestLower:   return both(.poly([(0.500, 0.294), (0.344, 0.294), (0.360, 0.322), (0.500, 0.318)]))
        case .deltAnterior: return both(.ellipse(CGRect(x: 0.288, y: 0.198, width: 0.080, height: 0.070)))
        case .deltLateral:  return both(.ellipse(CGRect(x: 0.266, y: 0.218, width: 0.058, height: 0.072)))
        case .biceps:       return both(.ellipse(CGRect(x: 0.248, y: 0.296, width: 0.062, height: 0.100)))
        case .forearms:     return both(.poly([(0.230, 0.404), (0.290, 0.398), (0.278, 0.512), (0.234, 0.516)]))
        // The torso ends at y 0.470, so the whole column is laid out to finish
        // above it rather than spilling past the waist.
        case .absUpper:     return [.roundedRect(CGRect(x: 0.442, y: 0.316, width: 0.116, height: 0.040), 4),
                                    .roundedRect(CGRect(x: 0.442, y: 0.360, width: 0.116, height: 0.040), 4)]
        case .absLower:     return [.roundedRect(CGRect(x: 0.446, y: 0.404, width: 0.108, height: 0.036), 4),
                                    .roundedRect(CGRect(x: 0.454, y: 0.444, width: 0.092, height: 0.030), 4)]
        case .obliques:     return both(.poly([(0.436, 0.336), (0.398, 0.348), (0.404, 0.452), (0.440, 0.470)]))
        case .abductors:    return both(.ellipse(CGRect(x: 0.360, y: 0.446, width: 0.064, height: 0.080)))
        case .adductors:    return both(.poly([(0.494, 0.498), (0.440, 0.508), (0.446, 0.612), (0.494, 0.596)]))
        case .quads:        return both(.poly([(0.492, 0.516), (0.378, 0.522), (0.396, 0.678), (0.482, 0.678)]))
        default:            return []
        }
    }

    private func backShapes(_ both: (MuscleShape) -> [MuscleShape]) -> [MuscleShape] {
        switch self {
        case .trapsUpper:    return [.poly([(0.500, 0.186), (0.352, 0.222), (0.500, 0.262), (0.648, 0.222)])]
        case .deltPosterior: return both(.ellipse(CGRect(x: 0.284, y: 0.200, width: 0.080, height: 0.072)))
        case .deltLateral:   return both(.ellipse(CGRect(x: 0.264, y: 0.220, width: 0.056, height: 0.070)))
        case .trapsMid:      return [.poly([(0.500, 0.252), (0.402, 0.268), (0.500, 0.336), (0.598, 0.268)])]
        case .rhomboids:     return both(.poly([(0.496, 0.262), (0.428, 0.276), (0.436, 0.322), (0.496, 0.314)]))
        case .lats:          return both(.poly([(0.492, 0.278), (0.352, 0.272), (0.372, 0.362), (0.470, 0.392)]))
        case .triceps:       return both(.ellipse(CGRect(x: 0.248, y: 0.294, width: 0.062, height: 0.104)))
        case .erectors:      return both(.poly([(0.498, 0.352), (0.454, 0.356), (0.462, 0.470), (0.498, 0.466)]))
        case .glutes:        return both(.ellipse(CGRect(x: 0.382, y: 0.448, width: 0.114, height: 0.096)))
        case .hamstrings:    return both(.poly([(0.490, 0.548), (0.382, 0.548), (0.398, 0.686), (0.480, 0.686)]))
        case .calves:        return both(.poly([(0.486, 0.706), (0.402, 0.710), (0.420, 0.806), (0.474, 0.802)]))
        case .soleus:        return both(.poly([(0.478, 0.812), (0.424, 0.814), (0.434, 0.884), (0.470, 0.882)]))
        default:             return []
        }
    }

    /// Profile facing right: the front of the body is the right-hand edge, the
    /// back is the left. Not mirrored — there is only one of each in profile.
    private func sideShapes() -> [MuscleShape] {
        // Facing right: the front of the body is the higher x. Placed against
        // the profile's real anatomy — chest projecting forward, spine and
        // glutes back, calf belly behind the shin.
        switch self {
        case .trapsUpper:    return [.poly([(0.470, 0.196), (0.376, 0.232), (0.416, 0.288), (0.494, 0.244)])]
        case .deltPosterior: return [.ellipse(CGRect(x: 0.434, y: 0.218, width: 0.078, height: 0.078))]
        case .deltLateral:   return [.ellipse(CGRect(x: 0.486, y: 0.212, width: 0.078, height: 0.080))]
        case .deltAnterior:  return [.ellipse(CGRect(x: 0.540, y: 0.216, width: 0.076, height: 0.078))]
        case .chestUpper:    return [.poly([(0.556, 0.248), (0.674, 0.270), (0.672, 0.294), (0.556, 0.276)])]
        case .chestMid:      return [.poly([(0.554, 0.280), (0.674, 0.298), (0.668, 0.326), (0.554, 0.310)])]
        case .chestLower:    return [.poly([(0.552, 0.314), (0.664, 0.330), (0.652, 0.356), (0.552, 0.344)])]
        case .lats:          return [.poly([(0.330, 0.276), (0.452, 0.300), (0.444, 0.412), (0.336, 0.394)])]
        case .triceps:       return [.ellipse(CGRect(x: 0.444, y: 0.312, width: 0.070, height: 0.108))]
        case .biceps:        return [.ellipse(CGRect(x: 0.524, y: 0.312, width: 0.070, height: 0.104))]
        case .forearms:      return [.poly([(0.470, 0.428), (0.578, 0.428), (0.570, 0.542), (0.478, 0.542)])]
        case .absUpper:      return [.roundedRect(CGRect(x: 0.588, y: 0.348, width: 0.072, height: 0.044), 4),
                                     .roundedRect(CGRect(x: 0.584, y: 0.398, width: 0.072, height: 0.042), 4)]
        case .absLower:      return [.roundedRect(CGRect(x: 0.578, y: 0.446, width: 0.068, height: 0.040), 4)]
        case .erectors:      return [.poly([(0.336, 0.352), (0.410, 0.364), (0.412, 0.474), (0.336, 0.462)])]
        case .glutes:        return [.ellipse(CGRect(x: 0.298, y: 0.446, width: 0.132, height: 0.086))]
        case .quads:         return [.poly([(0.520, 0.542), (0.612, 0.548), (0.560, 0.686), (0.494, 0.678)])]
        case .hamstrings:    return [.poly([(0.348, 0.548), (0.446, 0.552), (0.432, 0.686), (0.372, 0.680)])]
        case .calves:        return [.poly([(0.360, 0.716), (0.464, 0.720), (0.462, 0.804), (0.372, 0.796)])]
        case .soleus:        return [.poly([(0.398, 0.816), (0.484, 0.820), (0.482, 0.876), (0.416, 0.872)])]
        default:             return []
        }
    }
}

/// A drawable region on the body map.
enum MuscleShape: Hashable {
    case ellipse(CGRect)
    case roundedRect(CGRect, CGFloat)
    case polygon([CGPoint])

    /// Convenience so polygons can be written as tuple literals.
    static func poly(_ pts: [(CGFloat, CGFloat)]) -> MuscleShape {
        .polygon(pts.map { CGPoint(x: $0.0, y: $0.1) })
    }

    /// Reflection across x = 0.5, for the other side of a bilateral muscle.
    var mirroredHorizontally: MuscleShape {
        switch self {
        case .ellipse(let r):
            return .ellipse(CGRect(x: 1 - r.maxX, y: r.minY, width: r.width, height: r.height))
        case .roundedRect(let r, let c):
            return .roundedRect(CGRect(x: 1 - r.maxX, y: r.minY, width: r.width, height: r.height), c)
        case .polygon(let pts):
            return .polygon(pts.map { CGPoint(x: 1 - $0.x, y: $0.y) })
        }
    }

    /// Every point the shape touches, so tests can assert it stays in frame.
    var boundingPoints: [CGPoint] {
        switch self {
        case .ellipse(let r), .roundedRect(let r, _):
            return [CGPoint(x: r.minX, y: r.minY), CGPoint(x: r.maxX, y: r.maxY)]
        case .polygon(let pts): return pts
        }
    }

    func path(in size: CGSize) -> Path {
        func p(_ pt: CGPoint) -> CGPoint { CGPoint(x: pt.x * size.width, y: pt.y * size.height) }
        switch self {
        case .ellipse(let r):
            return Path(ellipseIn: CGRect(x: r.minX * size.width, y: r.minY * size.height,
                                          width: r.width * size.width, height: r.height * size.height))
        case .roundedRect(let r, let c):
            return Path(roundedRect: CGRect(x: r.minX * size.width, y: r.minY * size.height,
                                            width: r.width * size.width, height: r.height * size.height),
                        cornerRadius: c)
        case .polygon(let pts):
            var path = Path()
            guard let first = pts.first else { return path }
            path.move(to: p(first))
            for pt in pts.dropFirst() { path.addLine(to: p(pt)) }
            path.closeSubpath()
            return path
        }
    }
}
