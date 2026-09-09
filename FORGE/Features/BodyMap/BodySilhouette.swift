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
        // Head and neck are the same on every view.
        out.append(Path(ellipseIn: CGRect(x: 0.408 * w, y: 0.024 * h, width: 0.184 * w, height: 0.118 * h)))
        out.append(Path(roundedRect: CGRect(x: 0.452 * w, y: 0.124 * h,
                                            width: 0.096 * w, height: 0.062 * h), cornerRadius: 4))
        var path = Path()

        switch view {
        case .front, .back:
            // Athletic build: broad deltoids, a clear V-taper into a narrow
            // waist, then a flare at the hips. Straight-sided boxes read as a
            // mannequin, so every edge here is a curve.
            path.move(to: p(0.500, 0.168))
            path.addCurve(to: p(0.286, 0.216), control1: p(0.404, 0.166), control2: p(0.320, 0.180))
            path.addCurve(to: p(0.336, 0.318), control1: p(0.276, 0.252), control2: p(0.330, 0.284))   // lat flare
            path.addCurve(to: p(0.386, 0.408), control1: p(0.342, 0.356), control2: p(0.380, 0.378))   // waist pinch
            path.addCurve(to: p(0.344, 0.492), control1: p(0.392, 0.442), control2: p(0.348, 0.458))   // hip flare
            path.addLine(to: p(0.656, 0.492))
            path.addCurve(to: p(0.614, 0.408), control1: p(0.652, 0.458), control2: p(0.608, 0.442))
            path.addCurve(to: p(0.664, 0.318), control1: p(0.620, 0.378), control2: p(0.658, 0.356))
            path.addCurve(to: p(0.714, 0.216), control1: p(0.670, 0.284), control2: p(0.724, 0.252))
            path.addCurve(to: p(0.500, 0.168), control1: p(0.680, 0.180), control2: p(0.596, 0.166))
            path.closeSubpath(); out.append(path); path = Path()

            for side: CGFloat in [-1, 1] {
                let s: (CGFloat) -> CGFloat = { 0.5 + side * ($0 - 0.5) }
                // Arm: deltoid cap, biceps belly, taper through the elbow, then
                // a forearm that swells before the wrist.
                path.move(to: p(s(0.300), 0.202))
                path.addCurve(to: p(s(0.222), 0.286), control1: p(s(0.246), 0.208), control2: p(s(0.220), 0.240))
                path.addCurve(to: p(s(0.250), 0.386), control1: p(s(0.224), 0.330), control2: p(s(0.244), 0.360))
                path.addCurve(to: p(s(0.230), 0.470), control1: p(s(0.234), 0.410), control2: p(s(0.226), 0.436))
                path.addCurve(to: p(s(0.256), 0.548), control1: p(s(0.234), 0.508), control2: p(s(0.250), 0.532))
                path.addLine(to: p(s(0.318), 0.546))
                path.addCurve(to: p(s(0.306), 0.470), control1: p(s(0.320), 0.530), control2: p(s(0.304), 0.506))
                path.addCurve(to: p(s(0.322), 0.386), control1: p(s(0.310), 0.436), control2: p(s(0.320), 0.410))
                path.addCurve(to: p(s(0.352), 0.212), control1: p(s(0.330), 0.330), control2: p(s(0.348), 0.246))
                path.closeSubpath(); out.append(path); path = Path()

                // Leg: quad sweep out, knee pinch, calf belly, narrow ankle.
                path.move(to: p(s(0.352), 0.484))
                path.addCurve(to: p(s(0.336), 0.606), control1: p(s(0.330), 0.522), control2: p(s(0.332), 0.566))
                path.addCurve(to: p(s(0.380), 0.706), control1: p(s(0.342), 0.658), control2: p(s(0.374), 0.678))
                path.addCurve(to: p(s(0.368), 0.796), control1: p(s(0.360), 0.740), control2: p(s(0.360), 0.768))
                path.addCurve(to: p(s(0.414), 0.910), control1: p(s(0.392), 0.842), control2: p(s(0.410), 0.878))
                path.addLine(to: p(s(0.478), 0.910))
                path.addCurve(to: p(s(0.462), 0.796), control1: p(s(0.478), 0.878), control2: p(s(0.470), 0.842))
                path.addCurve(to: p(s(0.478), 0.706), control1: p(s(0.470), 0.768), control2: p(s(0.472), 0.740))
                path.addCurve(to: p(s(0.494), 0.484), control1: p(s(0.488), 0.660), control2: p(s(0.496), 0.560))
                path.closeSubpath(); out.append(path); path = Path()
            }

        case .side:
            // Profile facing right: chest and abdomen on the right edge, the
            // spine, lats and glutes on the left. The back is not a straight
            // line — it curves at the lumbar and again over the glute.
            path.move(to: p(0.478, 0.170))
            path.addCurve(to: p(0.606, 0.298), control1: p(0.562, 0.180), control2: p(0.606, 0.238))
            path.addCurve(to: p(0.578, 0.412), control1: p(0.606, 0.344), control2: p(0.582, 0.376))
            path.addCurve(to: p(0.560, 0.500), control1: p(0.574, 0.450), control2: p(0.578, 0.478))
            path.addLine(to: p(0.398, 0.496))
            path.addCurve(to: p(0.386, 0.396), control1: p(0.360, 0.474), control2: p(0.376, 0.430))
            path.addCurve(to: p(0.420, 0.252), control1: p(0.398, 0.348), control2: p(0.392, 0.288))
            path.addCurve(to: p(0.478, 0.170), control1: p(0.432, 0.212), control2: p(0.446, 0.178))
            path.closeSubpath(); out.append(path); path = Path()

            path.move(to: p(0.440, 0.200))
            path.addCurve(to: p(0.424, 0.320), control1: p(0.412, 0.240), control2: p(0.420, 0.286))
            path.addCurve(to: p(0.448, 0.412), control1: p(0.428, 0.356), control2: p(0.444, 0.388))
            path.addCurve(to: p(0.464, 0.546), control1: p(0.450, 0.456), control2: p(0.456, 0.508))
            path.addLine(to: p(0.548, 0.546))
            path.addCurve(to: p(0.556, 0.412), control1: p(0.556, 0.508), control2: p(0.560, 0.456))
            path.addCurve(to: p(0.578, 0.320), control1: p(0.562, 0.388), control2: p(0.576, 0.356))
            path.addCurve(to: p(0.552, 0.204), control1: p(0.582, 0.286), control2: p(0.578, 0.240))
            path.closeSubpath(); out.append(path); path = Path()

            path.move(to: p(0.392, 0.478))
            path.addCurve(to: p(0.394, 0.606), control1: p(0.372, 0.520), control2: p(0.384, 0.566))
            path.addCurve(to: p(0.406, 0.706), control1: p(0.400, 0.652), control2: p(0.400, 0.678))
            path.addCurve(to: p(0.398, 0.802), control1: p(0.394, 0.744), control2: p(0.390, 0.772))
            path.addCurve(to: p(0.416, 0.910), control1: p(0.404, 0.848), control2: p(0.410, 0.884))
            path.addLine(to: p(0.586, 0.910))
            path.addCurve(to: p(0.502, 0.802), control1: p(0.568, 0.868), control2: p(0.508, 0.844))
            path.addCurve(to: p(0.514, 0.706), control1: p(0.498, 0.772), control2: p(0.508, 0.744))
            path.addCurve(to: p(0.522, 0.478), control1: p(0.522, 0.660), control2: p(0.532, 0.560))
            path.closeSubpath(); out.append(path); path = Path()
        }
        return out
    }
}
