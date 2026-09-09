import Foundation

/// Maps FORGE's muscle taxonomy onto the vendored anatomical path data.
///
/// The two vocabularies don't line up exactly. Where FORGE is finer, several of
/// its muscles share one region — the path data has no separate soleus, so it
/// lights the calf. Where the path data is finer, one FORGE muscle claims
/// several regions: "quads" covers the inner and outer heads as well as the main
/// group, which is why a squat lights the whole thigh rather than a stripe.
extension Muscle {
    var pathSlugs: [BodySlug] {
        switch self {
        case .chestUpper:    return [.upperChest]
        case .chestMid:      return [.chest]
        case .chestLower:    return [.lowerChest]

        // The back data has no separate lat or rhomboid region; both live in
        // the upper back.
        case .lats:          return [.upperBack]
        case .rhomboids:     return [.upperBack]
        case .trapsUpper:    return [.trapezius]
        case .trapsMid:      return [.trapezius]
        case .erectors:      return [.lowerBack]

        case .deltAnterior:  return [.frontDeltoid]
        case .deltLateral:   return [.deltoids]
        case .deltPosterior: return [.deltoids]

        case .biceps:        return [.biceps]
        case .triceps:       return [.triceps]
        case .forearms:      return [.forearm]

        case .absUpper:      return [.upperAbs]
        case .absLower:      return [.lowerAbs]
        case .obliques:      return [.obliques]
        case .serratus:      return [.serratus]

        case .glutes:        return [.gluteal]
        // The gluteus medius is the hip abductor, so it shares that region.
        case .abductors:     return [.gluteal]
        case .adductors:     return [.adductors]
        case .quads:         return [.quadriceps, .innerQuad, .outerQuad]
        case .hamstrings:    return [.hamstring]
        // No separate soleus in the data; both calf muscles light the calf.
        case .calves:        return [.calves]
        case .soleus:        return [.calves]

        // Sit-ups and leg raises recruit these heavily — the form guidance
        // warns about exactly that — so they are worth showing separately.
        case .hipFlexors:    return [.hipFlexors]

        case .cardiovascular: return []
        }
    }
}

/// Regions that form the body outline rather than a trainable muscle. Drawn as
/// neutral structure so the figure is a person rather than a floating group of
/// muscles.
enum BodyStructure {
    static let slugs: Set<BodySlug> = [
        .head, .hair, .neck, .hands, .feet, .knees, .ankles, .tibialis
    ]
}
