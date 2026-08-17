import SwiftUI

struct TrainView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.forge) private var forge

    @State private var quickStartCategory: WorkoutCategory?
    @State private var showTemplates = false
    @State private var pastExpanded = false

    private var today: Date { Date().startOfDay }
    private var tomorrow: Date { Calendar.forge.date(byAdding: .day, value: 1, to: today)! }
    private var upcomingDates: [Date] {
        (2...6).map { Calendar.forge.date(byAdding: .day, value: $0, to: today)! }
    }
    private var pastDates: [Date] {
        let dates = Set(appState.userData.entries.map { $0.date.startOfDay }).filter { $0 < today }
        return dates.sorted(by: >)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Space.xl) {
                header
                quickStart
                DaySectionView(date: today, label: "Today")
                DaySectionView(date: tomorrow, label: "Tomorrow")
                ForEach(upcomingDates, id: \.self) { date in
                    DaySectionView(date: date, label: date.formatted(.dateTime.weekday(.wide).month().day()))
                }
                pastSection
                Spacer(minLength: 90)
            }
            .padding(Space.lg)
        }
        .scrollIndicators(.hidden)
        .sheet(isPresented: $showTemplates) {
            ApplyTemplateSheet(targetDate: today)
        }
        .sheet(item: $quickStartCategory) { category in
            AddWorkoutSheet(initialDate: today, initialCategory: category)
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Train").font(.forgeHeading(34)).foregroundStyle(forge.fireGradient)
                Text("Ready to workout!").font(.forgeBody(14)).foregroundStyle(forge.textSecondary)
            }
            Spacer()
            Button {
                showTemplates = true
            } label: {
                Image(systemName: "square.stack.3d.up.fill")
                    .foregroundStyle(forge.textSecondary)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
        }
        .padding(.top, Space.md)
    }

    private var quickStart: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Space.md) {
                ForEach(WorkoutCategory.browsable) { category in
                    Button {
                        quickStartCategory = category
                    } label: {
                        VStack(spacing: Space.sm) {
                            CategoryIcon(systemName: category.icon, size: 18)
                            Text(category.rawValue)
                                .font(.forgeCaption(12))
                                .foregroundStyle(forge.textPrimary)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                        }
                        .frame(width: 92, height: 92)
                        .forgeCard(padding: Space.sm, cornerRadius: Radius.md)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var pastSection: some View {
        VStack(alignment: .leading, spacing: Space.sm) {
            Button {
                withAnimation { pastExpanded.toggle() }
            } label: {
                HStack {
                    Text("Past").font(.forgeHeadingMedium(17)).foregroundStyle(forge.textPrimary)
                    Spacer()
                    Image(systemName: pastExpanded ? "chevron.up" : "chevron.down")
                        .foregroundStyle(forge.textSecondary)
                }
                .frame(minHeight: 44)
            }
            .buttonStyle(.plain)

            if pastExpanded {
                if pastDates.isEmpty {
                    Text("No past workouts logged yet.")
                        .font(.forgeCaption())
                        .foregroundStyle(forge.textTertiary)
                } else {
                    ForEach(pastDates, id: \.self) { date in
                        DaySectionView(date: date, label: date.formatted(.dateTime.weekday(.wide).month().day()))
                    }
                }
            }
        }
    }
}
