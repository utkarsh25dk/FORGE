import SwiftUI

/// Rendered off-screen to a UIImage for sharing — not shown directly in the UI.
struct WeeklyRecapCard: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.forge) private var forge

    private var weekWorked: Int { appState.weeklyWorkedDays() }
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

    /// Three things: the streak, how the week compares, and the shape of the week.
    ///
    /// A weekly-goal ring and a lifetime total used to sit under the graph. Both were
    /// real numbers, and that was the problem — a card with four numbers on it has no
    /// headline, and the streak is the headline. What is left is one figure, the
    /// sentence that puts it in context, and the seven days behind it.
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                Text("FORGE").font(.forgeDisplay(34)).foregroundStyle(forge.textPrimary)
                Text(weekRange).font(.forgeCaption(16)).foregroundStyle(forge.textSecondary)
            }
            .padding(.top, 84)

            Spacer(minLength: 0)

            VStack(spacing: 16) {
                HStack(spacing: 10) {
                    Image(systemName: "flame.fill").font(.system(size: 48)).foregroundStyle(forge.fireGradient)
                    Text("\(streak)").font(.forgeDisplay(80)).foregroundStyle(forge.fireGradient)
                }
                Text(streak == 1 ? "day streak" : "days streak").font(.forgeBody(19)).foregroundStyle(forge.textSecondary)
                weekComparisonPill
            }

            weekGraph
                .padding(.top, 72)

            Spacer(minLength: 0)

            Text("Every rep feeds the fire.")
                .font(.forgeCaption(15))
                .foregroundStyle(forge.textTertiary)
                .padding(.bottom, 72)
        }
        .frame(width: 1080, height: 1080)
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
            HStack(alignment: .bottom, spacing: 28) {
                ForEach(weekDays, id: \.date) { day in
                    VStack(spacing: 10) {
                        RoundedRectangle(cornerRadius: 13)
                            .fill(barColor(for: day.status))
                            .frame(width: 64, height: barHeight(for: day.status))
                        Text(day.date.formatted(.dateTime.weekday(.narrow)))
                            .font(.forgeCaption(15))
                            .fontWeight(day.isToday ? .bold : .regular)
                            .foregroundStyle(day.isToday ? forge.textPrimary : forge.textTertiary)
                    }
                    .frame(width: 64, alignment: .bottom)
                }
            }
            .frame(height: 190, alignment: .bottom)

            HStack(spacing: 18) {
                legendDot(color: DayStatus.worked.color(forge) ?? forge.textPrimary, label: "Worked")
                legendDot(color: DayStatus.rest.color(forge) ?? forge.textTertiary, label: "Rest")
                legendDot(color: DayStatus.missed.color(forge) ?? forge.textTertiary.opacity(0.5), label: "Missed")
            }
        }
        .padding(.horizontal, 60)
    }

    private func legendDot(color: Color, label: String) -> some View {
        HStack(spacing: 5) {
            Circle().fill(color).frame(width: 9, height: 9)
            Text(label).font(.forgeCaption(13)).foregroundStyle(forge.textTertiary)
        }
    }

    private func barColor(for status: DayStatus) -> Color {
        status.color(forge) ?? forge.textTertiary.opacity(0.2)
    }

    private func barHeight(for status: DayStatus) -> CGFloat {
        switch status {
        case .worked: return 150
        case .rest: return 95
        case .missed: return 44
        case .none: return 14
        }
    }
}
