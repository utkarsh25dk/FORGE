import SwiftUI

/// Front and back anatomical diagrams with the worked muscles lit up.
///
/// The figure is drawn from traced anatomical path data (see MuscleMapVendor)
/// rather than shapes assembled by hand. The earlier hand-drawn version could
/// place a region roughly where a muscle belongs but never looked like a body;
/// this is the same silhouette an anatomy chart uses.
struct BodyMapView: View {
    @Environment(\.forge) private var forge
    let primary: [Muscle]
    let secondary: [Muscle]
    var figureHeight: CGFloat = 260

    private var primarySlugs: Set<BodySlug> { Set(primary.flatMap(\.pathSlugs)) }
    private var secondarySlugs: Set<BodySlug> { Set(secondary.flatMap(\.pathSlugs)) }

    var body: some View {
        VStack(spacing: Space.md) {
            HStack(alignment: .top, spacing: Space.xl) {
                figure(.front, MaleFrontPaths.paths)
                figure(.back, MaleBackPaths.paths)
            }
            legend
        }
    }

    private func figure(_ view: BodyView, _ paths: [BodyPartPathData]) -> some View {
        VStack(spacing: 6) {
            AnatomicalFigure(paths: paths,
                             viewBox: view == .front ? BodyViewBox.maleFront : BodyViewBox.maleBack,
                             primary: primarySlugs,
                             secondary: secondarySlugs,
                             base: forge.raised,
                             structure: forge.raised.opacity(0.55),
                             outline: forge.surfaceBorder,
                             accent: forge.accent)
                .frame(width: figureHeight * 0.52, height: figureHeight)
            Text(view.label)
                .font(.forgeCaption(10))
                .foregroundStyle(forge.textTertiary)
        }
    }

    private var legend: some View {
        HStack(spacing: Space.lg) {
            legendDot(forge.accent, "Primary")
            legendDot(forge.accent.opacity(0.38), "Also worked")
        }
    }

    private func legendDot(_ color: Color, _ label: String) -> some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 2).fill(color).frame(width: 11, height: 11)
            Text(label).font(.forgeCaption(11)).foregroundStyle(forge.textTertiary)
        }
    }
}

/// Renders one view's path data, scaled to fit and tinted per muscle.
struct AnatomicalFigure: View {
    let paths: [BodyPartPathData]
    /// Both figures are authored in one shared coordinate space — the back body
    /// sits at x 718 — so the box's origin has to be subtracted or the back view
    /// draws entirely off-frame.
    let viewBox: BodyViewBox
    let primary: Set<BodySlug>
    let secondary: Set<BodySlug>
    let base: Color
    let structure: Color
    let outline: Color
    let accent: Color

    var body: some View {
        GeometryReader { geo in
            // Uniform scale so the figure keeps its proportions in any frame.
            let box = viewBox.rect
            let scale = min(geo.size.width / box.width, geo.size.height / box.height)
            let offsetX = (geo.size.width - box.width * scale) / 2 - box.minX * scale
            let offsetY = (geo.size.height - box.height * scale) / 2 - box.minY * scale

            ZStack {
                ForEach(Array(paths.enumerated()), id: \.offset) { _, part in
                    ForEach(Array(part.allPaths.enumerated()), id: \.offset) { _, svg in
                        let p = PathBuilder.buildPath(from: svg, scale: scale,
                                                      offsetX: offsetX, offsetY: offsetY)
                        p.fill(fill(for: part.slug))
                        p.stroke(outline, lineWidth: 0.5)
                    }
                }
            }
        }
    }

    private func fill(for slug: BodySlug) -> Color {
        if primary.contains(slug) { return accent }
        if secondary.contains(slug) { return accent.opacity(0.38) }
        return BodyStructure.slugs.contains(slug) ? structure : base
    }
}
