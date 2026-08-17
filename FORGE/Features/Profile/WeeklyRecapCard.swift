import SwiftUI

/// Rendered off-screen to a UIImage for sharing — not shown directly in the UI.
struct WeeklyRecapCard: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.forge) private var forge

    private var weekWorked: Int { appState.weeklyWorkedDays() }
    private var weeklyGoal: Int { appState.userData.weeklyGoal }
    private var streak: Int { appState.currentStreak }

    private var weekInterval: DateInterval {
        Calendar.forge.dateInterval(of: .weekOfYear, for: Date()) ?? DateInterval(start: Date(), duration: 0)
    }

    private var weekRange: String {
        let end = Calendar.forge.date(byAdding: .day, value: 6, to: weekInterval.start) ?? weekInterval.start
        return "\(weekInterval.start.formatted(.dateTime.month(.abbreviated).day())) – \(end.formatted(.dateTime.month(.abbreviated).day())), \(end.formatted(.dateTime.year()))"
    }

    private var weekDays: [(date: Date, status: DayStatus, isToday: Bool)] {
        let cal = Calendar.forge
        let today = Date().startOfDay
        var days: [(Date, DayStatus, Bool)] = []
        var day = weekInterval.start
        for _ in 0..<7 {
            days.append((day, appState.dayStatus(for: day), cal.isDate(day, inSameDayAs: today)))
            day = cal.date(byAdding: .day, value: 1, to: day)!
        }
        return days
    }

    private var lastWeekWorked: Int {
        let lastWeekDate = Calendar.forge.date(byAdding: .weekOfYear, value: -1, to: Date()) ?? Date()
        return appState.weeklyWorkedDays(containing: lastWeekDate)
    }

    private var weekCategoryBreakdown: [(category: WorkoutCategory, count: Int)] {
        let entries = appState.userData.entries.filter {
            $0.isCompleted && !$0.isWarmUp && !$0.isCoolDown && $0.date >= weekInterval.start && $0.date < weekInterval.end
        }
        var counts: [WorkoutCategory: Int] = [:]
        for e in entries { counts[e.category, default: 0] += 1 }
        return counts.sorted { $0.value > $1.value }.map { (category: $0.key, count: $0.value) }
    }

    private var weekPRs: [PersonalRecord] {
        appState.userData.personalRecords.values
            .filter { $0.date >= weekInterval.start && $0.date < weekInterval.end }
            .sorted { $0.date > $1.date }
    }

    private var weightUnit: String { appState.userData.unitSystem.weightUnit }

    var body: some View {
        VStack(spacing: 26) {
            VStack(spacing: 6) {
                Text("FORGE").font(.forgeDisplay(30)).foregroundStyle(forge.fireGradient)
                Text(weekRange).font(.forgeCaption(15)).foregroundStyle(forge.textSecondary)
            }
            .padding(.top, 56)

            VStack(spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: "flame.fill").font(.system(size: 38)).foregroundStyle(forge.fireGradient)
                    Text("\(streak)").font(.forgeDisplay(60)).foregroundStyle(forge.fireGradient)
                }
                Text(streak == 1 ? "day streak" : "day streak").font(.forgeBody(17)).foregroundStyle(forge.textSecondary)
                weekComparisonPill
            }

            weekGraph

            HStack(spacing: 56) {
                VStack(spacing: 8) {
                    ZStack {
                        ProgressRing(progress: appState.weeklyProgress, lineWidth: 10, ringColor: forge.accent)
                            .frame(width: 92, height: 92)
                        Text("\(weekWorked)/\(weeklyGoal)").font(.forgeHeading(19)).foregroundStyle(forge.textPrimary)
                    }
                    Text("weekly goal").font(.forgeCaption(13)).foregroundStyle(forge.textSecondary)
                }
                VStack(spacing: 8) {
                    Text("\(appState.totalCompletedWorkouts)")
                        .font(.forgeDisplay(38))
                        .foregroundStyle(forge.textPrimary)
                        .frame(height: 92)
                        .frame(maxWidth: .infinity)
                    Text("total workouts").font(.forgeCaption(13)).foregroundStyle(forge.textSecondary)
                }
            }
            .padding(.horizontal, 60)

            if !weekCategoryBreakdown.isEmpty {
                VStack(alignment: .leading, spacing: 14) {
                    ForEach(weekCategoryBreakdown.prefix(4), id: \.category) { item in
                        HStack(spacing: 12) {
                            CategoryIcon(systemName: item.category.icon, size: 15)
                            Text(item.category.rawValue).font(.forgeBodyMedium(15)).foregroundStyle(forge.textPrimary)
                            Spacer(minLength: 0)
                            Text("\(item.count)").font(.forgeBodySemibold(15)).foregroundStyle(forge.textSecondary)
                        }
                    }
                }
                .padding(.horizontal, 70)
            }

            if !weekPRs.isEmpty {
                prSection
            }

            Spacer(minLength: 0)

            Text("Every rep feeds the fire.")
                .font(.forgeCaption(14))
                .foregroundStyle(forge.textTertiary)
                .padding(.bottom, 44)
        }
        .frame(width: 1080, height: 1620)
        .background(forge.backgroundGradient)
    }

    private var weekComparisonPill: some View {
        let delta = weekWorked - lastWeekWorked
        let text: String
        let icon: String
        switch true {
        case delta > 0:
            text = "\(delta) more workout\(delta == 1 ? "" : "s") than last week"
            icon = "arrow.up.right"
        case delta < 0:
            text = "\(weekWorked) this week — building back up"
            icon = "arrow.up.forward"
        default:
            text = "Matched last week's pace"
            icon = "equal"
        }
        return HStack(spacing: 6) {
            Image(systemName: icon).font(.system(size: 11, weight: .bold))
            Text(text).font(.forgeCaption(13))
        }
        .foregroundStyle(forge.accent)
        .padding(.horizontal, 14)
        .padding(.vertical, 7)
        .background(Capsule().fill(forge.accentSoft))
    }

    private var weekGraph: some View {
        VStack(spacing: 14) {
            HStack(alignment: .bottom, spacing: 16) {
                ForEach(weekDays, id: \.date) { day in
                    VStack(spacing: 10) {
                        RoundedRectangle(cornerRadius: 7)
                            .fill(barColor(for: day.status))
                            .frame(width: 32, height: barHeight(for: day.status))
                        Text(day.date.formatted(.dateTime.weekday(.narrow)))
                            .font(.forgeCaption(13))
                            .fontWeight(day.isToday ? .bold : .regular)
                            .foregroundStyle(day.isToday ? forge.textPrimary : forge.textTertiary)
                    }
                    .frame(width: 32, alignment: .bottom)
                }
            }
            .frame(height: 118, alignment: .bottom)

            HStack(spacing: 18) {
                legendDot(color: DayStatus.worked.color ?? forge.accent, label: "Worked")
                legendDot(color: DayStatus.rest.color ?? forge.warning, label: "Rest")
                legendDot(color: DayStatus.missed.color ?? forge.danger, label: "Missed")
            }
        }
        .padding(.horizontal, 60)
    }

    private func legendDot(color: Color, label: String) -> some View {
        HStack(spacing: 5) {
            Circle().fill(color).frame(width: 7, height: 7)
            Text(label).font(.forgeCaption(11)).foregroundStyle(forge.textTertiary)
        }
    }

    private func barColor(for status: DayStatus) -> Color {
        status.color ?? forge.textTertiary.opacity(0.25)
    }

    private func barHeight(for status: DayStatus) -> CGFloat {
        switch status {
        case .worked: return 88
        case .rest: return 56
        case .missed: return 26
        case .none: return 8
        }
    }

    private var prSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "trophy.fill").font(.system(size: 15)).foregroundStyle(forge.fireGradient)
                Text("New PRs This Week").font(.forgeBodySemibold(15)).foregroundStyle(forge.textPrimary)
            }
            ForEach(weekPRs.prefix(3), id: \.exerciseName) { pr in
                HStack(spacing: 12) {
                    Text(pr.exerciseName).font(.forgeBodyMedium(15)).foregroundStyle(forge.textPrimary)
                    Spacer(minLength: 0)
                    Text("\(Int(pr.weight)) \(weightUnit) × \(pr.reps)")
                        .font(.forgeBodySemibold(15))
                        .foregroundStyle(forge.accent)
                }
            }
        }
        .padding(.horizontal, 70)
    }
}
