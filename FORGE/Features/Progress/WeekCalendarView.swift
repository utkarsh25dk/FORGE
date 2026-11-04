import SwiftUI

struct WeekCalendarView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.forge) private var forge
    var weekStart: Date
    var onSelectDay: (Date) -> Void

    private var cal: Calendar { Calendar.forge }
    private var days: [Date] { (0..<7).map { cal.date(byAdding: .day, value: $0, to: weekStart)! } }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(days.enumerated()), id: \.offset) { index, day in
                dayCell(day, at: index)
            }
        }
    }

    /// Consecutive days sharing a status render as one unbroken bar rather than separate
    /// pills, so a streak reads as a single line whose length *is* its length. The month
    /// grid already joins runs this way; this keeps the two calendars speaking one language.
    /// Runs stop at the week's edges because a week is all this view shows.
    private func dayCell(_ day: Date, at index: Int) -> some View {
        let status = appState.dayStatus(for: day)
        let isToday = day.isSameDay(as: Date())
        let joinsLeft = index > 0 && status != .none && appState.dayStatus(for: days[index - 1]) == status
        let joinsRight = index < days.count - 1 && status != .none && appState.dayStatus(for: days[index + 1]) == status
        let radius: CGFloat = 19
        let fill = appState.dayFill(forge, for: day)
        let ink = appState.dayInk(forge, for: day)

        return Button {
            onSelectDay(day)
        } label: {
            VStack(spacing: 6) {
                Text(day.formatted(.dateTime.weekday(.narrow)))
                    .font(.forgeCaption(11))
                    .foregroundStyle(forge.textTertiary)
                Text("\(cal.component(.day, from: day))")
                    .font(.forgeBodySemibold(15))
                    .foregroundStyle(ink ?? forge.textPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 38)
                    .background(
                        UnevenRoundedRectangle(
                            topLeadingRadius: joinsLeft ? 0 : radius,
                            bottomLeadingRadius: joinsLeft ? 0 : radius,
                            bottomTrailingRadius: joinsRight ? 0 : radius,
                            topTrailingRadius: joinsRight ? 0 : radius
                        )
                        .fill(fill)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: radius)
                            .stroke(isToday ? forge.accent : Color.clear, lineWidth: 1.5)
                    )
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}
