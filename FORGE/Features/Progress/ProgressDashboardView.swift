import SwiftUI

struct ProgressDashboardView: View {
    @Environment(\.forge) private var forge
    @State private var zoom: CalendarZoom = .week
    @State private var anchor = Date()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Space.lg) {
                Text("Progress").font(.forgeHeading(34)).foregroundStyle(forge.textPrimary).padding(.top, Space.md)
                CalendarHeatmapView(zoom: $zoom, anchor: $anchor)
                WeeklyChartsView(zoom: zoom, anchor: anchor)
                PersonalRecordsView()
                BodyMeasurementsView()
                Spacer(minLength: 90)
            }
            .padding(Space.lg)
        }
        .scrollIndicators(.hidden)
    }
}
