import SwiftUI

struct MonthCalendarView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.forge) private var forge
    var month: Date
    var onSelectDay: (Date) -> Void

    private var cal: Calendar { Calendar.forge }
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

    private var daysInGrid: [Date?] {
        guard let monthInterval = cal.dateInterval(of: .month, for: month) else { return [] }
        let firstWeekday = cal.component(.weekday, from: monthInterval.start)
        let leading = Array<Date?>(repeating: nil, count: firstWeekday - 1)
        var days: [Date?] = leading
        var day = monthInterval.start
        while day < monthInterval.end {
            days.append(day)
            day = cal.date(byAdding: .day, value: 1, to: day)!
        }
        return days
    }

    var body: some View {
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(Array(daysInGrid.enumerated()), id: \.offset) { _, day in
                if let day {
                    dayCell(day)
                } else {
                    Color.clear.frame(height: 40)
                }
            }
        }
    }

    /// Consecutive days sharing a status join into one bar, so a run reads as its
    /// length. Within a run the fill still steps with each day's volume, which is why
    /// joining by status rather than by colour matters: the bar stays whole while its
    /// shade varies across it.
    private func dayCell(_ day: Date) -> some View {
        let status = appState.dayStatus(for: day)
        let weekday = cal.component(.weekday, from: day)
        let prevStatus = appState.dayStatus(for: cal.date(byAdding: .day, value: -1, to: day)!)
        let nextStatus = appState.dayStatus(for: cal.date(byAdding: .day, value: 1, to: day)!)
        let joinLeft = weekday != 1 && status != .none && prevStatus == status
        let joinRight = weekday != 7 && status != .none && nextStatus == status
        let radius: CGFloat = 8
        let isToday = day.isSameDay(as: Date())
        let fill = appState.contributionFill(forge, for: day)
        let level = appState.contributionLevel(for: day)

        return Button {
            onSelectDay(day)
        } label: {
            Text("\(cal.component(.day, from: day))")
                .font(.forgeCaption(13))
                .foregroundStyle(level > 0 ? fill.readableForeground : (status == .none ? forge.textSecondary : forge.textPrimary))
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(
                    UnevenRoundedRectangle(
                        topLeadingRadius: joinLeft ? 0 : radius,
                        bottomLeadingRadius: joinLeft ? 0 : radius,
                        bottomTrailingRadius: joinRight ? 0 : radius,
                        topTrailingRadius: joinRight ? 0 : radius
                    )
                    .fill(fill)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: radius)
                        .stroke(isToday ? forge.accent : Color.clear, lineWidth: 1.5)
                )
        }
        .buttonStyle(.plain)
    }
}
