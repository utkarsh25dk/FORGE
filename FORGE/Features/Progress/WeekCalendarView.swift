import SwiftUI

struct WeekCalendarView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.forge) private var forge
    var weekStart: Date
    var onSelectDay: (Date) -> Void

    private var cal: Calendar { Calendar.forge }
    private var days: [Date] { (0..<7).map { cal.date(byAdding: .day, value: $0, to: weekStart)! } }

    var body: some View {
        HStack(spacing: 6) {
            ForEach(days, id: \.self) { day in
                dayCell(day)
            }
        }
    }

    private func dayCell(_ day: Date) -> some View {
        let status = appState.dayStatus(for: day)
        let isToday = day.isSameDay(as: Date())
        return Button {
            onSelectDay(day)
        } label: {
            VStack(spacing: 6) {
                Text(day.formatted(.dateTime.weekday(.narrow)))
                    .font(.forgeCaption(11))
                    .foregroundStyle(forge.textTertiary)
                Text("\(cal.component(.day, from: day))")
                    .font(.forgeBodySemibold(15))
                    .foregroundStyle(forge.textPrimary)
                    .frame(width: 38, height: 38)
                    .background(Circle().fill(status.color(forge)?.opacity(0.35) ?? Color.clear))
                    .overlay(Circle().stroke(isToday ? forge.accent : Color.clear, lineWidth: 1.5))
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}
