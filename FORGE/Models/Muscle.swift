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
    var widthRatio: CGFloat { self == .side ? 0.44 : 0.50 }
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
        case .chestUpper:   return both(.poly([(0.498, 0.216), (0.386, 0.226), (0.376, 0.246), (0.498, 0.242)]))
        case .chestMid:     return both(.poly([(0.498, 0.244), (0.374, 0.250), (0.372, 0.274), (0.498, 0.272)]))
        case .chestLower:   return both(.poly([(0.498, 0.276), (0.372, 0.276), (0.384, 0.300), (0.498, 0.296)]))
        case .deltAnterior: return both(.ellipse(CGRect(x: 0.318, y: 0.190, width: 0.062, height: 0.058)))
        case .deltLateral:  return both(.ellipse(CGRect(x: 0.294, y: 0.202, width: 0.050, height: 0.062)))
        case .biceps:       return both(.ellipse(CGRect(x: 0.298, y: 0.272, width: 0.048, height: 0.084)))
        case .forearms:     return both(.poly([(0.298, 0.396), (0.344, 0.394), (0.338, 0.494), (0.302, 0.496)]))
        case .absUpper:     return [.roundedRect(CGRect(x: 0.454, y: 0.300, width: 0.092, height: 0.034), 3),
                                    .roundedRect(CGRect(x: 0.454, y: 0.338, width: 0.092, height: 0.034), 3)]
        case .absLower:     return [.roundedRect(CGRect(x: 0.458, y: 0.376, width: 0.084, height: 0.032), 3),
                                    .roundedRect(CGRect(x: 0.464, y: 0.412, width: 0.072, height: 0.030), 3)]
        case .obliques:     return both(.poly([(0.448, 0.306), (0.412, 0.316), (0.418, 0.410), (0.450, 0.424)]))
        case .abductors:    return both(.ellipse(CGRect(x: 0.372, y: 0.428, width: 0.052, height: 0.062)))
        case .adductors:    return both(.poly([(0.492, 0.492), (0.446, 0.500), (0.452, 0.588), (0.492, 0.576)]))
        case .quads:        return both(.poly([(0.488, 0.504), (0.392, 0.512), (0.408, 0.696), (0.478, 0.692)]))
        default:            return []
        }
    }

    private func backShapes(_ both: (MuscleShape) -> [MuscleShape]) -> [MuscleShape] {
        switch self {
        case .trapsUpper:    return [.poly([(0.500, 0.182), (0.382, 0.212), (0.500, 0.248), (0.618, 0.212)])]
        case .deltPosterior: return both(.ellipse(CGRect(x: 0.316, y: 0.192, width: 0.062, height: 0.060)))
        case .deltLateral:   return both(.ellipse(CGRect(x: 0.294, y: 0.204, width: 0.048, height: 0.058)))
        case .trapsMid:      return [.poly([(0.500, 0.240), (0.418, 0.254), (0.500, 0.318), (0.582, 0.254)])]
        case .rhomboids:     return both(.poly([(0.496, 0.250), (0.436, 0.262), (0.442, 0.304), (0.496, 0.298)]))
        case .lats:          return both(.poly([(0.492, 0.264), (0.378, 0.258), (0.394, 0.348), (0.474, 0.376)]))
        case .triceps:       return both(.ellipse(CGRect(x: 0.298, y: 0.270, width: 0.048, height: 0.088)))
        case .erectors:      return both(.poly([(0.498, 0.332), (0.462, 0.336), (0.468, 0.452), (0.498, 0.448)]))
        case .glutes:        return both(.ellipse(CGRect(x: 0.386, y: 0.428, width: 0.098, height: 0.076)))
        case .hamstrings:    return both(.poly([(0.486, 0.526), (0.394, 0.530), (0.410, 0.700), (0.474, 0.696)]))
        case .calves:        return both(.poly([(0.482, 0.748), (0.406, 0.752), (0.418, 0.846), (0.470, 0.842)]))
        case .soleus:        return both(.poly([(0.474, 0.856), (0.418, 0.858), (0.428, 0.926), (0.464, 0.924)]))
        default:             return []
        }
    }

    /// Facing right: the front of the body is the higher x.
    private func sideShapes() -> [MuscleShape] {
        switch self {
        case .trapsUpper:    return [.poly([(0.478, 0.186), (0.398, 0.216), (0.432, 0.266), (0.500, 0.228)])]
        case .deltPosterior: return [.ellipse(CGRect(x: 0.446, y: 0.204, width: 0.062, height: 0.064))]
        case .deltLateral:   return [.ellipse(CGRect(x: 0.490, y: 0.200, width: 0.062, height: 0.066))]
        case .deltAnterior:  return [.ellipse(CGRect(x: 0.534, y: 0.204, width: 0.060, height: 0.064))]
        case .chestUpper:    return [.poly([(0.552, 0.232), (0.638, 0.250), (0.636, 0.270), (0.552, 0.256)])]
        case .chestMid:      return [.poly([(0.550, 0.260), (0.638, 0.276), (0.634, 0.300), (0.550, 0.288)])]
        case .chestLower:    return [.poly([(0.548, 0.292), (0.630, 0.306), (0.620, 0.330), (0.548, 0.320)])]
        case .lats:          return [.poly([(0.372, 0.262), (0.462, 0.282), (0.456, 0.390), (0.378, 0.374)])]
        case .triceps:       return [.ellipse(CGRect(x: 0.456, y: 0.294, width: 0.056, height: 0.092))]
        case .biceps:        return [.ellipse(CGRect(x: 0.522, y: 0.294, width: 0.056, height: 0.090))]
        case .forearms:      return [.poly([(0.478, 0.400), (0.560, 0.400), (0.554, 0.508), (0.484, 0.508)])]
        case .absUpper:      return [.roundedRect(CGRect(x: 0.566, y: 0.328, width: 0.056, height: 0.038), 3),
                                     .roundedRect(CGRect(x: 0.562, y: 0.372, width: 0.056, height: 0.036), 3)]
        case .absLower:      return [.roundedRect(CGRect(x: 0.558, y: 0.416, width: 0.052, height: 0.034), 3)]
        case .erectors:      return [.poly([(0.376, 0.336), (0.438, 0.346), (0.440, 0.448), (0.376, 0.438)])]
        case .glutes:        return [.ellipse(CGRect(x: 0.340, y: 0.430, width: 0.116, height: 0.074))]
        case .quads:         return [.poly([(0.524, 0.520), (0.594, 0.526), (0.552, 0.694), (0.498, 0.688)])]
        case .hamstrings:    return [.poly([(0.376, 0.526), (0.456, 0.530), (0.444, 0.694), (0.396, 0.688)])]
        case .calves:        return [.poly([(0.382, 0.752), (0.464, 0.756), (0.462, 0.842), (0.394, 0.836)])]
        case .soleus:        return [.poly([(0.412, 0.856), (0.484, 0.858), (0.482, 0.922), (0.428, 0.918)])]
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
