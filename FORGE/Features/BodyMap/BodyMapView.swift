import SwiftUI

/// Front and back body diagrams with the worked muscles lit up.
///
/// The point is specificity: a written list saying "chest" tells you almost
/// nothing, but a diagram showing the upper chest shaded and the lower chest not
/// tells you what an incline press actually does. Primary muscles are filled
/// solid, secondary ones are dimmed, and everything untouched stays neutral.
struct BodyMapView: View {
    @Environment(\.forge) private var forge
    let primary: [Muscle]
    let secondary: [Muscle]
    /// Height of each figure. Both views sit side by side.
    var figureHeight: CGFloat = 260

    var body: some View {
        VStack(spacing: Space.md) {
            HStack(spacing: Space.xl) {
                figure(.front)
                figure(.back)
            }
            legend
        }
    }

    private func figure(_ view: BodyView) -> some View {
        VStack(spacing: 6) {
            ZStack {
                BodySilhouette(view: view)
                    .fill(forge.raised)
                BodySilhouette(view: view)
                    .stroke(forge.surfaceBorder, lineWidth: 1)
                muscleOverlay(view)
            }
            .frame(width: figureHeight * 0.46, height: figureHeight)
            Text(view == .front ? "FRONT" : "BACK")
                .font(.forgeCaption(10))
                .foregroundStyle(forge.textTertiary)
        }
    }

    private func muscleOverlay(_ view: BodyView) -> some View {
        GeometryReader { geo in
            ForEach(Muscle.allCases.filter { $0.bodyView == view }) { muscle in
                let tint = fill(for: muscle)
                ForEach(Array(muscle.regions.enumerated()), id: \.offset) { _, r in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(tint)
                        .frame(width: r.width * geo.size.width,
                               height: r.height * geo.size.height)
                        .position(x: (r.midX) * geo.size.width,
                                  y: (r.midY) * geo.size.height)
                }
            }
        }
    }

    /// Primary is the full accent; secondary is deliberately faint so the
    /// distinction survives a glance rather than needing the legend.
    private func fill(for muscle: Muscle) -> Color {
        if primary.contains(muscle) { return forge.accent }
        if secondary.contains(muscle) { return forge.accent.opacity(0.32) }
        return .clear
    }

    private var legend: some View {
        HStack(spacing: Space.lg) {
            legendDot(forge.accent, "Primary")
            legendDot(forge.accent.opacity(0.32), "Also worked")
        }
    }

    private func legendDot(_ color: Color, _ label: String) -> some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 2).fill(color).frame(width: 12, height: 12)
            Text(label).font(.forgeCaption(11)).foregroundStyle(forge.textTertiary)
        }
    }
}

/// A simple humanoid outline. Built from primitives rather than traced path data
/// so it stays legible at small sizes and readable in source.
struct BodySilhouette: Shape {
    let view: BodyView

    func path(in rect: CGRect) -> Path {
        let w = rect.width, h = rect.height
        func r(_ x: CGFloat, _ y: CGFloat, _ rw: CGFloat, _ rh: CGFloat, _ radius: CGFloat) -> Path {
            Path(roundedRect: CGRect(x: x * w, y: y * h, width: rw * w, height: rh * h),
                 cornerRadius: radius)
        }
        var p = Path()
        p.addPath(Path(ellipseIn: CGRect(x: 0.385 * w, y: 0.030 * h, width: 0.230 * w, height: 0.115 * h)))  // head
        p.addPath(r(0.455, 0.140, 0.090, 0.045, 3))                                                          // neck
        p.addPath(r(0.275, 0.180, 0.450, 0.250, 10))                                                         // torso
        p.addPath(r(0.315, 0.320, 0.370, 0.150, 8))                                                          // waist
        p.addPath(r(0.145, 0.195, 0.135, 0.230, 8))                                                          // upper arm L
        p.addPath(r(0.720, 0.195, 0.135, 0.230, 8))                                                          // upper arm R
        p.addPath(r(0.165, 0.335, 0.110, 0.150, 7))                                                          // forearm L
        p.addPath(r(0.725, 0.335, 0.110, 0.150, 7))                                                          // forearm R
        p.addPath(r(0.310, 0.440, 0.175, 0.250, 10))                                                         // thigh L
        p.addPath(r(0.515, 0.440, 0.175, 0.250, 10))                                                         // thigh R
        p.addPath(r(0.330, 0.665, 0.140, 0.230, 8))                                                          // shin L
        p.addPath(r(0.530, 0.665, 0.140, 0.230, 8))                                                          // shin R
        return p
    }
}
