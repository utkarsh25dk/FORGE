import SwiftUI
import Charts

private struct ExerciseGroup: Identifiable {
    let id: String
    let name: String
    let count: Int
    let lastDate: Date
    let lastStat: String
}

private struct CategoryGroup: Identifiable {
    let id: WorkoutCategory
    let category: WorkoutCategory
    let exercises: [ExerciseGroup]
    let totalCount: Int
}

struct TotalWorkoutsDetailSheet: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.forge) private var forge
    @Environment(\.dismiss) private var dismiss
    @State private var expandedCategories: Set<WorkoutCategory> = []

    private var completed: [WorkoutEntry] {
        appState.userData.entries.filter { $0.isCompleted && !$0.isWarmUp && !$0.isCoolDown }
    }

    private var groups: [CategoryGroup] {
        var byCategory: [WorkoutCategory: [WorkoutEntry]] = [:]
        for e in completed { byCategory[e.category, default: []].append(e) }
        return byCategory
            .map { category, entries -> CategoryGroup in
                var byName: [String: [WorkoutEntry]] = [:]
                for e in entries { byName[e.name, default: []].append(e) }
                let exercises = byName
                    .map { name, group -> ExerciseGroup in
                        let latest = group.max { $0.date < $1.date }!
                        return ExerciseGroup(id: name, name: name, count: group.count, lastDate: latest.date, lastStat: statLabel(latest))
                    }
                    .sorted { $0.lastDate > $1.lastDate }
                return CategoryGroup(id: category, category: category, exercises: exercises, totalCount: entries.count)
            }
            .sorted { $0.totalCount > $1.totalCount }
    }

    /// Fixed, category-keyed colors — never positional — so the same category always gets
    /// the same color regardless of sort order or which categories happen to be present.
    private func color(for category: WorkoutCategory) -> Color {
        switch category {
        case .upperBody: return Color(hex: "C58CFF")
        case .lowerBody: return Color(hex: "FF6B5C")
        case .fullBody: return Color(hex: "FFB03C")
        case .core: return Color(hex: "9AD65C")
        case .cardio: return Color(hex: "5CA8FF")
        case .hiit: return Color(hex: "FF5CB0")
        case .flexibility: return Color(hex: "5CE0D8")
        case .recovery: return Color(hex: "FA5F4A")
        case .activity: return Color(hex: "FF9166")
        case .sports: return Color(hex: "8CA0FF")
        case .warmUp, .coolDown, .other: return Color(hex: "9BA69C")
        }
    }

    private var breakdownChart: some View {
        HStack(spacing: Space.xl) {
            Chart {
                ForEach(groups) { group in
                    SectorMark(angle: .value("Count", group.totalCount), innerRadius: .ratio(0.6), angularInset: 1.5)
                        .foregroundStyle(color(for: group.category))
                }
            }
            .frame(width: 120, height: 120)

            VStack(alignment: .leading, spacing: 6) {
                ForEach(groups.prefix(6)) { group in
                    HStack(spacing: 6) {
                        Circle().fill(color(for: group.category)).frame(width: 8, height: 8)
                        Text(group.category.rawValue).font(.forgeCaption(12)).foregroundStyle(forge.textPrimary)
                        Spacer()
                        Text("\(Int(Double(group.totalCount) / Double(max(completed.count, 1)) * 100))%")
                            .font(.forgeCaption(12)).foregroundStyle(forge.textSecondary)
                    }
                }
            }
        }
        .forgeCard()
    }

    private func statLabel(_ entry: WorkoutEntry) -> String {
        let unit = appState.userData.unitSystem
        switch entry.kind {
        case .strength:
            guard let w = entry.weight, let r = entry.reps else { return "—" }
            return "\(entry.sets ?? 1)×\(r) @ \(Int(w)) \(unit.weightUnit)"
        case .cardio, .session:
            var parts: [String] = []
            if let d = entry.durationMin { parts.append("\(d) min") }
            if let i = entry.intensity { parts.append("RPE \(i)") }
            return parts.isEmpty ? "—" : parts.joined(separator: " · ")
        case .interval:
            var parts: [String] = []
            if let r = entry.rounds { parts.append("\(r) rounds") }
            if let i = entry.intensity { parts.append("RPE \(i)") }
            return parts.isEmpty ? "—" : parts.joined(separator: " · ")
        case .hold:
            guard let s = entry.holdSec else { return "—" }
            return "\(s)s hold"
        case .distance:
            guard let dist = entry.distanceMiles else { return "—" }
            return "\(String(format: "%.1f", dist)) \(unit.distanceUnit)"
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if completed.isEmpty {
                    EmptyStateView(icon: "checkmark.seal", title: "No workouts yet", message: "Complete an exercise to see it here.")
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: Space.xl) {
                            breakdownChart

                            Text("\(completed.count) workout\(completed.count == 1 ? "" : "s") completed across \(groups.count) categories")
                                .font(.forgeBodyMedium(14))
                                .foregroundStyle(forge.textSecondary)

                            ForEach(groups) { group in
                                let isExpanded = expandedCategories.contains(group.category)
                                VStack(alignment: .leading, spacing: Space.sm) {
                                    Button {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            if isExpanded {
                                                expandedCategories.remove(group.category)
                                            } else {
                                                expandedCategories.insert(group.category)
                                            }
                                        }
                                    } label: {
                                        HStack(spacing: Space.sm) {
                                            CategoryIcon(systemName: group.category.icon, size: 16)
                                            Text(group.category.rawValue)
                                                .font(.forgeBodySemibold(16))
                                                .foregroundStyle(forge.textPrimary)
                                            Spacer(minLength: 0)
                                            Text("\(group.totalCount)")
                                                .font(.forgeCaption())
                                                .foregroundStyle(forge.textSecondary)
                                            Image(systemName: "chevron.down")
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundStyle(forge.textTertiary)
                                                .rotationEffect(.degrees(isExpanded ? 180 : 0))
                                        }
                                        .contentShape(Rectangle())
                                    }
                                    .buttonStyle(.plain)

                                    if isExpanded {
                                        VStack(spacing: 2) {
                                            ForEach(group.exercises) { ex in
                                                HStack(alignment: .top) {
                                                    VStack(alignment: .leading, spacing: 2) {
                                                        Text(ex.name).font(.forgeBodyMedium(14)).foregroundStyle(forge.textPrimary)
                                                        Text("\(ex.count)× · last \(ex.lastDate.formatted(.dateTime.month().day().year()))")
                                                            .font(.forgeCaption(11))
                                                            .foregroundStyle(forge.textTertiary)
                                                    }
                                                    Spacer(minLength: Space.md)
                                                    Text(ex.lastStat)
                                                        .font(.forgeCaption(12))
                                                        .foregroundStyle(forge.textSecondary)
                                                        .multilineTextAlignment(.trailing)
                                                }
                                                .padding(.vertical, Space.sm)
                                                .padding(.horizontal, Space.md)
                                            }
                                        }
                                        .forgeCard(padding: 0, cornerRadius: Radius.md)
                                        .transition(.opacity.combined(with: .move(edge: .top)))
                                    }
                                }
                            }
                        }
                        .padding(Space.lg)
                    }
                    .scrollIndicators(.hidden)
                }
            }
            .forgeScreenBackground()
            .navigationTitle("Total Workouts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } }
            }
        }
        .presentationDetents([.large])
    }
}
