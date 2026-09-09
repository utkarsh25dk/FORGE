import SwiftUI

/// Front, back and side body diagrams with the worked muscles lit up.
///
/// The point is specificity: a written list saying "chest" tells you almost
/// nothing, but seeing the upper chest shaded and the lower chest not tells you
/// what an incline press actually does. The side view earns its place by showing
/// the front chain against the back chain in one glance — an imbalance that the
/// front and back views can only show separately.
struct BodyMapView: View {
    @Environment(\.forge) private var forge
    let primary: [Muscle]
    let secondary: [Muscle]
    var figureHeight: CGFloat = 196

    var body: some View {
        VStack(spacing: Space.md) {
            HStack(alignment: .top, spacing: Space.lg) {
                ForEach(BodyView.allCases, id: \.self) { figure($0) }
            }
            legend
        }
    }

    private func figure(_ view: BodyView) -> some View {
        VStack(spacing: 6) {
            ZStack {
                BodySilhouette(view: view).fill(forge.raised)
                muscleOverlay(view)
                BodySilhouette(view: view).stroke(forge.surfaceBorder, lineWidth: 1)
            }
            .frame(width: figureHeight * view.widthRatio, height: figureHeight)
            Text(view.label)
                .font(.forgeCaption(10))
                .foregroundStyle(worked(view) ? forge.textSecondary : forge.textTertiary)
        }
    }

    /// Whether this view shows anything at all, so an empty figure can be
    /// labelled quietly rather than looking broken.
    private func worked(_ view: BodyView) -> Bool {
        (primary + secondary).contains { !$0.shapes(for: view).isEmpty }
    }

    private func muscleOverlay(_ view: BodyView) -> some View {
        GeometryReader { geo in
            ZStack {
                // Definition layer: every muscle outlined, worked or not, so the
                // figure reads as a body with anatomy rather than a blank shape.
                // Outlines rather than fills — overlapping translucent fills
                // compounded into bright patches at the hips and shoulders.
                ForEach(Muscle.allCases) { muscle in
                    ForEach(Array(muscle.shapes(for: view).enumerated()), id: \.offset) { _, shape in
                        shape.path(in: geo.size)
                            .stroke(forge.textTertiary.opacity(0.45), lineWidth: 0.7)
                    }
                }
                // Highlight layer.
                ForEach(Muscle.allCases) { muscle in
                    let tint = fill(for: muscle)
                    if tint != .clear {
                        ForEach(Array(muscle.shapes(for: view).enumerated()), id: \.offset) { _, shape in
                            shape.path(in: geo.size).fill(tint)
                        }
                    }
                }
            }
        }
    }

    /// Primary is full accent; secondary is deliberately faint so the difference
    /// survives a glance without reading the legend.
    private func fill(for muscle: Muscle) -> Color {
        if primary.contains(muscle) { return forge.accent }
        if secondary.contains(muscle) { return forge.accent.opacity(0.34) }
        return .clear
    }

    private var legend: some View {
        HStack(spacing: Space.lg) {
            legendDot(forge.accent, "Primary")
            legendDot(forge.accent.opacity(0.34), "Also worked")
        }
    }

    private func legendDot(_ color: Color, _ label: String) -> some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 2).fill(color).frame(width: 11, height: 11)
            Text(label).font(.forgeCaption(11)).foregroundStyle(forge.textTertiary)
        }
    }
}
