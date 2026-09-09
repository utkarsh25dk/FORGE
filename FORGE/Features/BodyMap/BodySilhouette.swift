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
        if view == .side {
            // A profile head has a face: forehead, brow, nose and chin. An
            // ellipse here is what made the whole figure read as a slab.
            path.move(to: p(0.560, 0.036))
            path.addCurve(to: p(0.624, 0.086), control1: p(0.606, 0.044), control2: p(0.626, 0.062))
            path.addLine(to: p(0.664, 0.098))                                   // nose
            path.addLine(to: p(0.618, 0.108))
            path.addCurve(to: p(0.596, 0.146), control1: p(0.620, 0.126), control2: p(0.614, 0.140))
            path.addCurve(to: p(0.474, 0.152), control1: p(0.560, 0.156), control2: p(0.508, 0.158))
            path.addCurve(to: p(0.396, 0.086), control1: p(0.412, 0.144), control2: p(0.394, 0.124))
            path.addCurve(to: p(0.560, 0.036), control1: p(0.398, 0.050), control2: p(0.474, 0.030))
            path.closeSubpath(); out.append(path); path = Path()
            // Neck sits forward of the spine and angles slightly.
            path.move(to: p(0.442, 0.136))
            path.addLine(to: p(0.560, 0.144))
            path.addLine(to: p(0.578, 0.206))
            path.addLine(to: p(0.418, 0.200))
            path.closeSubpath(); out.append(path); path = Path()
        } else {
            out.append(Path(ellipseIn: CGRect(x: 0.408 * w, y: 0.024 * h, width: 0.184 * w, height: 0.118 * h)))
            out.append(Path(roundedRect: CGRect(x: 0.452 * w, y: 0.124 * h,
                                                width: 0.096 * w, height: 0.062 * h), cornerRadius: 4))
        }

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
            // Facing right. A human profile is roughly a quarter as deep as it
            // is tall through the torso, and the back is an S: thoracic curve
            // out, lumbar curve in, then the glute projecting back again.
            path.move(to: p(0.500, 0.192))
            path.addCurve(to: p(0.716, 0.300), control1: p(0.632, 0.198), control2: p(0.716, 0.240))  // chest out
            path.addCurve(to: p(0.676, 0.404), control1: p(0.716, 0.348), control2: p(0.684, 0.372))  // ribcage
            path.addCurve(to: p(0.652, 0.492), control1: p(0.670, 0.440), control2: p(0.660, 0.466))  // abdomen
            path.addCurve(to: p(0.508, 0.536), control1: p(0.630, 0.522), control2: p(0.576, 0.538))
            path.addCurve(to: p(0.268, 0.494), control1: p(0.402, 0.534), control2: p(0.296, 0.534))  // glute back
            path.addCurve(to: p(0.328, 0.408), control1: p(0.256, 0.454), control2: p(0.322, 0.442))  // lumbar in
            path.addCurve(to: p(0.298, 0.276), control1: p(0.334, 0.372), control2: p(0.290, 0.330))  // thoracic out
            path.addCurve(to: p(0.500, 0.192), control1: p(0.306, 0.230), control2: p(0.388, 0.192))
            path.closeSubpath(); out.append(path); path = Path()

            // Arm hanging beside the torso, seen edge on.
            path.move(to: p(0.470, 0.204))
            path.addCurve(to: p(0.430, 0.306), control1: p(0.418, 0.222), control2: p(0.424, 0.268))
            path.addCurve(to: p(0.456, 0.412), control1: p(0.434, 0.348), control2: p(0.452, 0.384))
            path.addCurve(to: p(0.470, 0.554), control1: p(0.458, 0.462), control2: p(0.462, 0.514))
            path.addLine(to: p(0.582, 0.554))
            path.addCurve(to: p(0.588, 0.412), control1: p(0.590, 0.514), control2: p(0.594, 0.462))
            path.addCurve(to: p(0.618, 0.306), control1: p(0.592, 0.384), control2: p(0.614, 0.348))
            path.addCurve(to: p(0.576, 0.208), control1: p(0.622, 0.268), control2: p(0.626, 0.222))
            path.closeSubpath(); out.append(path); path = Path()

            // Leg: thigh deep front to back, knee pinch, calf belly behind the
            // shin, ankle narrow, and a foot pointing forward.
            path.move(to: p(0.312, 0.500))
            path.addCurve(to: p(0.348, 0.640), control1: p(0.298, 0.548), control2: p(0.330, 0.598))
            path.addCurve(to: p(0.398, 0.706), control1: p(0.360, 0.670), control2: p(0.386, 0.688))
            path.addCurve(to: p(0.336, 0.792), control1: p(0.336, 0.730), control2: p(0.320, 0.760))  // calf back
            path.addCurve(to: p(0.412, 0.884), control1: p(0.350, 0.828), control2: p(0.396, 0.856))
            path.addCurve(to: p(0.396, 0.930), control1: p(0.414, 0.902), control2: p(0.394, 0.912))  // heel
            path.addLine(to: p(0.720, 0.930))
            path.addCurve(to: p(0.520, 0.884), control1: p(0.706, 0.902), control2: p(0.588, 0.892))  // foot forward
            path.addCurve(to: p(0.516, 0.792), control1: p(0.512, 0.856), control2: p(0.510, 0.826))
            path.addCurve(to: p(0.546, 0.706), control1: p(0.522, 0.760), control2: p(0.542, 0.734))
            path.addCurve(to: p(0.628, 0.500), control1: p(0.552, 0.646), control2: p(0.630, 0.560))
            path.closeSubpath(); out.append(path); path = Path()
        }
        return out
    }
}
