import SwiftUI

struct MonthCalendarView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.forge) private var forge
    var month: Date
    var compact: Bool = false
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
        VStack(alignment: .leading, spacing: 6) {
            if compact {
                Text(month.formatted(.dateTime.month(.abbreviated)))
                    .font(.forgeCaption(11))
                    .foregroundStyle(forge.textSecondary)
            }
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(Array(daysInGrid.enumerated()), id: \.offset) { _, day in
                    if let day {
                        dayCell(day)
                    } else {
                        Color.clear.frame(height: compact ? 14 : 40)
                    }
                }
            }
        }
    }

    private func dayCell(_ day: Date) -> some View {
        if compact {
            return AnyView(compactDayCell(day))
        }
        let status = appState.dayStatus(for: day)
        let weekday = cal.component(.weekday, from: day)
        let prevStatus = appState.dayStatus(for: cal.date(byAdding: .day, value: -1, to: day)!)
        let nextStatus = appState.dayStatus(for: cal.date(byAdding: .day, value: 1, to: day)!)
        let joinLeft = weekday != 1 && status != .none && prevStatus == status
        let joinRight = weekday != 7 && status != .none && nextStatus == status
        let radius: CGFloat = 8
        let isToday = day.isSameDay(as: Date())

        return AnyView(Button {
            onSelectDay(day)
        } label: {
            Text("\(cal.component(.day, from: day))")
                .font(.forgeCaption(13))
                .foregroundStyle(status == .none ? forge.textSecondary : forge.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(
                    UnevenRoundedRectangle(
                        topLeadingRadius: joinLeft ? 0 : radius,
                        bottomLeadingRadius: joinLeft ? 0 : radius,
                        bottomTrailingRadius: joinRight ? 0 : radius,
                        topTrailingRadius: joinRight ? 0 : radius
                    )
                    .fill(status.color?.opacity(0.35) ?? Color.clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: radius)
                        .stroke(isToday ? forge.accent : Color.clear, lineWidth: 1.5)
                )
        }
        .buttonStyle(.plain))
    }

    /// Year-view cell: a faint, uniform grid square with a small color dot for status —
    /// avoids the joined color-block look which reads as noise at this scale.
    private func compactDayCell(_ day: Date) -> some View {
        let status = appState.dayStatus(for: day)
        let isToday = day.isSameDay(as: Date())
        return Button {
            onSelectDay(day)
        } label: {
            RoundedRectangle(cornerRadius: 3)
                .stroke(forge.textTertiary.opacity(0.14), lineWidth: 0.75)
                .background(
                    RoundedRectangle(cornerRadius: 3)
                        .fill(isToday ? forge.accent.opacity(0.12) : Color.clear)
                )
                .overlay {
                    if let color = status.color {
                        Circle()
                            .fill(color)
                            .frame(width: 7, height: 7)
                    }
                }
                .frame(height: 14)
        }
        .buttonStyle(.plain)
    }
}
