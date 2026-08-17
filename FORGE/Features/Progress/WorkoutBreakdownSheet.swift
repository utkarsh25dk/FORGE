import SwiftUI

private struct CategoryCount: Identifiable {
    let id: WorkoutCategory
    let category: WorkoutCategory
    let count: Int
}

struct WorkoutBreakdownSheet: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.forge) private var forge
    @Environment(\.dismiss) private var dismiss
    var date: Date

    private var breakdown: [CategoryCount] {
        let completed = appState.entries(on: date).filter { $0.isCompleted && !$0.isWarmUp && !$0.isCoolDown }
        var counts: [WorkoutCategory: Int] = [:]
        for e in completed { counts[e.category, default: 0] += 1 }
        return counts.map { CategoryCount(id: $0.key, category: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
    }

    private var total: Int { breakdown.reduce(0) { $0 + $1.count } }

    var body: some View {
        NavigationStack {
            Group {
                if breakdown.isEmpty {
                    EmptyStateView(icon: "chart.bar", title: "Nothing logged", message: "No completed exercises on this day.")
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: Space.md) {
                            Text("\(total) exercise\(total == 1 ? "" : "s") completed")
                                .font(.forgeBodyMedium(14))
                                .foregroundStyle(forge.textSecondary)

                            VStack(spacing: 2) {
                                ForEach(breakdown) { item in
                                    HStack(spacing: Space.md) {
                                        CategoryIcon(systemName: item.category.icon, size: 14)
                                        Text(item.category.rawValue)
                                            .font(.forgeBodySemibold(15))
                                            .foregroundStyle(forge.textPrimary)
                                        Spacer(minLength: 0)
                                        Text("\(item.count)")
                                            .font(.forgeBodySemibold(15))
                                            .foregroundStyle(forge.textSecondary)
                                            .monospacedDigit()
                                    }
                                    .padding(.vertical, Space.sm)
                                    .padding(.horizontal, Space.md)
                                }
                            }
                            .forgeCard(padding: 0, cornerRadius: Radius.md)
                        }
                        .padding(Space.lg)
                    }
                    .scrollIndicators(.hidden)
                }
            }
            .forgeScreenBackground()
            .navigationTitle(date.formatted(.dateTime.weekday(.wide).month().day()))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } }
            }
        }
        .presentationDetents([.medium])
    }
}
