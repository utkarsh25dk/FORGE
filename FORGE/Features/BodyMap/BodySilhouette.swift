import SwiftUI

/// A human outline drawn with curves. Built per view rather than one shape
/// rotated, because a profile is a genuinely different silhouette.
struct BodySilhouette: Shape {
    let view: BodyView

    func path(in rect: CGRect) -> Path {
        var combined = Path()
        for part in parts(in: rect) { combined.addPath(part) }
        return combined
    }

    /// The silhouette as separate closed shapes rather than one path.
    ///
    /// The parts overlap — an arm sits over the torso, a deltoid straddles both —
    /// and merging them into a single path makes overlap depend on winding
    /// direction, which cancelled the side view's torso against its arm. Kept
    /// separate, a point is on the body if any part contains it, which is what
    /// "inside the figure" actually means.
    func parts(in rect: CGRect) -> [Path] {
        let w = rect.width, h = rect.height
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * w, y: y * h) }

        var out: [Path] = []
        var path = Path()

        // Classic eight-head proportions: head 1/8 of total height, crotch at
        // the halfway point, knee at 3/4. The previous figure had a head over a
        // tenth of its height and limbs half again too thick, which is what made
        // it read as heavy rather than trained.
        if view == .side {
            path.move(to: p(0.552, 0.026))
            path.addCurve(to: p(0.606, 0.072), control1: p(0.594, 0.032), control2: p(0.608, 0.050))
            path.addLine(to: p(0.640, 0.084))                                    // nose
            path.addLine(to: p(0.602, 0.093))
            path.addCurve(to: p(0.584, 0.126), control1: p(0.604, 0.108), control2: p(0.598, 0.120))
            path.addCurve(to: p(0.482, 0.132), control1: p(0.552, 0.135), control2: p(0.510, 0.137))
            path.addCurve(to: p(0.420, 0.074), control1: p(0.428, 0.126), control2: p(0.418, 0.106))
            path.addCurve(to: p(0.552, 0.026), control1: p(0.422, 0.044), control2: p(0.482, 0.022))
            path.closeSubpath(); out.append(path); path = Path()
            path.move(to: p(0.462, 0.120))
            path.addLine(to: p(0.556, 0.126))
            path.addLine(to: p(0.570, 0.188))
            path.addLine(to: p(0.442, 0.184))
            path.closeSubpath(); out.append(path); path = Path()
        } else {
            out.append(Path(ellipseIn: CGRect(x: 0.436 * w, y: 0.014 * h,
                                              width: 0.128 * w, height: 0.126 * h)))
            out.append(Path(roundedRect: CGRect(x: 0.470 * w, y: 0.126 * h,
                                                width: 0.060 * w, height: 0.062 * h), cornerRadius: 3))
        }

        switch view {
        case .front, .back:
            // Torso: deltoid line, taper through the lats to a narrow waist,
            // modest flare at the hips. Lean, not blocky.
            path.move(to: p(0.500, 0.176))
            path.addCurve(to: p(0.316, 0.212), control1: p(0.416, 0.174), control2: p(0.344, 0.184))
            path.addCurve(to: p(0.352, 0.310), control1: p(0.306, 0.248), control2: p(0.346, 0.278))
            path.addCurve(to: p(0.386, 0.396), control1: p(0.358, 0.348), control2: p(0.382, 0.368))
            path.addCurve(to: p(0.352, 0.486), control1: p(0.390, 0.430), control2: p(0.356, 0.452))
            path.addLine(to: p(0.648, 0.486))
            path.addCurve(to: p(0.614, 0.396), control1: p(0.644, 0.452), control2: p(0.610, 0.430))
            path.addCurve(to: p(0.648, 0.310), control1: p(0.618, 0.368), control2: p(0.642, 0.348))
            path.addCurve(to: p(0.684, 0.212), control1: p(0.654, 0.278), control2: p(0.694, 0.248))
            path.addCurve(to: p(0.500, 0.176), control1: p(0.656, 0.184), control2: p(0.584, 0.174))
            path.closeSubpath(); out.append(path); path = Path()

            for side: CGFloat in [-1, 1] {
                let s: (CGFloat) -> CGFloat = { 0.5 + side * ($0 - 0.5) }
                // Arm: slim. Deltoid, a modest biceps belly, then a forearm
                // narrowing to the wrist, and a hand.
                path.move(to: p(s(0.330), 0.196))
                path.addCurve(to: p(s(0.276), 0.276), control1: p(s(0.288), 0.202), control2: p(s(0.274), 0.234))
                path.addCurve(to: p(s(0.290), 0.386), control1: p(s(0.278), 0.322), control2: p(s(0.288), 0.358))
                path.addCurve(to: p(s(0.282), 0.470), control1: p(s(0.284), 0.412), control2: p(s(0.280), 0.440))
                path.addCurve(to: p(s(0.296), 0.556), control1: p(s(0.284), 0.508), control2: p(s(0.292), 0.536))
                path.addCurve(to: p(s(0.306), 0.622), control1: p(s(0.284), 0.588), control2: p(s(0.292), 0.612))
                path.addLine(to: p(s(0.352), 0.620))
                path.addCurve(to: p(s(0.348), 0.556), control1: p(s(0.362), 0.610), control2: p(s(0.358), 0.586))
                path.addCurve(to: p(s(0.342), 0.470), control1: p(s(0.352), 0.536), control2: p(s(0.344), 0.508))
                path.addCurve(to: p(s(0.352), 0.386), control1: p(s(0.344), 0.440), control2: p(s(0.348), 0.412))
                path.addCurve(to: p(s(0.372), 0.206), control1: p(s(0.356), 0.352), control2: p(s(0.368), 0.240))
                path.closeSubpath(); out.append(path); path = Path()

                // Leg: half the figure. Thigh tapers to the knee at 3/4 height,
                // calf swells, ankle narrows, foot at the base.
                path.move(to: p(s(0.356), 0.478))
                path.addCurve(to: p(s(0.372), 0.616), control1: p(s(0.344), 0.522), control2: p(s(0.362), 0.574))
                path.addCurve(to: p(s(0.406), 0.734), control1: p(s(0.380), 0.664), control2: p(s(0.402), 0.706))
                path.addCurve(to: p(s(0.392), 0.828), control1: p(s(0.388), 0.766), control2: p(s(0.384), 0.800))
                path.addCurve(to: p(s(0.424), 0.944), control1: p(s(0.402), 0.870), control2: p(s(0.418), 0.914))
                path.addCurve(to: p(s(0.410), 0.984), control1: p(s(0.426), 0.962), control2: p(s(0.406), 0.968))
                path.addLine(to: p(s(0.492), 0.984))
                path.addCurve(to: p(s(0.470), 0.944), control1: p(s(0.492), 0.966), control2: p(s(0.474), 0.962))
                path.addCurve(to: p(s(0.462), 0.828), control1: p(s(0.470), 0.914), control2: p(s(0.468), 0.870))
                path.addCurve(to: p(s(0.470), 0.734), control1: p(s(0.464), 0.800), control2: p(s(0.470), 0.766))
                path.addCurve(to: p(s(0.492), 0.478), control1: p(s(0.478), 0.680), control2: p(s(0.494), 0.560))
                path.closeSubpath(); out.append(path); path = Path()
            }

        case .side:
            path.move(to: p(0.500, 0.180))
            path.addCurve(to: p(0.672, 0.288), control1: p(0.606, 0.186), control2: p(0.672, 0.228))
            path.addCurve(to: p(0.644, 0.394), control1: p(0.672, 0.336), control2: p(0.650, 0.362))
            path.addCurve(to: p(0.624, 0.486), control1: p(0.640, 0.430), control2: p(0.632, 0.458))
            path.addCurve(to: p(0.506, 0.526), control1: p(0.606, 0.514), control2: p(0.564, 0.528))
            path.addCurve(to: p(0.312, 0.486), control1: p(0.418, 0.524), control2: p(0.336, 0.522))
            path.addCurve(to: p(0.362, 0.398), control1: p(0.300, 0.448), control2: p(0.356, 0.430))
            path.addCurve(to: p(0.338, 0.268), control1: p(0.368, 0.362), control2: p(0.330, 0.320))
            path.addCurve(to: p(0.500, 0.180), control1: p(0.346, 0.222), control2: p(0.412, 0.180))
            path.closeSubpath(); out.append(path); path = Path()

            path.move(to: p(0.478, 0.194))
            path.addCurve(to: p(0.444, 0.290), control1: p(0.436, 0.210), control2: p(0.440, 0.254))
            path.addCurve(to: p(0.466, 0.392), control1: p(0.448, 0.330), control2: p(0.462, 0.366))
            path.addCurve(to: p(0.478, 0.560), control1: p(0.468, 0.444), control2: p(0.472, 0.518))
            path.addCurve(to: p(0.486, 0.624), control1: p(0.470, 0.592), control2: p(0.474, 0.614))
            path.addLine(to: p(0.556, 0.624))
            path.addCurve(to: p(0.560, 0.560), control1: p(0.566, 0.612), control2: p(0.566, 0.592))
            path.addCurve(to: p(0.566, 0.392), control1: p(0.566, 0.518), control2: p(0.570, 0.444))
            path.addCurve(to: p(0.588, 0.290), control1: p(0.570, 0.366), control2: p(0.584, 0.330))
            path.addCurve(to: p(0.554, 0.196), control1: p(0.592, 0.254), control2: p(0.596, 0.210))
            path.closeSubpath(); out.append(path); path = Path()

            path.move(to: p(0.348, 0.490))
            path.addCurve(to: p(0.378, 0.626), control1: p(0.334, 0.534), control2: p(0.362, 0.584))
            path.addCurve(to: p(0.418, 0.734), control1: p(0.388, 0.668), control2: p(0.410, 0.708))
            path.addCurve(to: p(0.366, 0.824), control1: p(0.366, 0.756), control2: p(0.352, 0.788))
            path.addCurve(to: p(0.428, 0.930), control1: p(0.378, 0.860), control2: p(0.414, 0.898))
            path.addCurve(to: p(0.416, 0.984), control1: p(0.430, 0.950), control2: p(0.414, 0.964))
            path.addLine(to: p(0.688, 0.984))
            path.addCurve(to: p(0.516, 0.930), control1: p(0.676, 0.958), control2: p(0.574, 0.940))
            path.addCurve(to: p(0.512, 0.824), control1: p(0.508, 0.898), control2: p(0.506, 0.858))
            path.addCurve(to: p(0.538, 0.734), control1: p(0.518, 0.790), control2: p(0.534, 0.760))
            path.addCurve(to: p(0.606, 0.490), control1: p(0.544, 0.678), control2: p(0.608, 0.550))
            path.closeSubpath(); out.append(path); path = Path()
        }
        return out
    }
}
