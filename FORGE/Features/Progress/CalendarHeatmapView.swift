import SwiftUI

struct IdentifiableDate: Identifiable {
    let date: Date
    var id: TimeInterval { date.timeIntervalSince1970 }
    init(_ date: Date) { self.date = date }
}

enum CalendarZoom: String, CaseIterable, Identifiable {
    case week = "Week"
    case month = "Month"
    case year = "Year"
    var id: String { rawValue }
}

extension AppState {
    /// A day's training volume on the contribution ramp's 0...4.
    ///
    /// Status said only whether a day happened. Volume says how much, which is the
    /// one thing a wall of squares can show that a wall of ticks cannot — and it is
    /// what makes a heavy week look different from a week you showed up and left.
    /// Warm-ups and cool-downs are excluded: they pad a session without being one.
    func contributionLevel(for date: Date) -> Int {
        let count = entries(on: date).filter { $0.isCompleted && !$0.isWarmUp && !$0.isCoolDown }.count
        switch count {
        case 0: return 0
        case 1...2: return 1
        case 3...4: return 2
        case 5...6: return 3
        default: return 4
        }
    }

    /// The ramp colour for a day. A day you could have trained and didn't gets the
    /// ramp's empty tone, so a gap is a visible thing rather than a hole; a day that
    /// hasn't happened yet, or predates the account, gets nothing at all.
    func contributionFill(_ forge: ForgeColors, for date: Date) -> Color {
        let level = contributionLevel(for: date)
        guard level == 0 else { return forge.contribution[level] }
        return dayStatus(for: date) == .none ? .clear : forge.contribution[0]
    }
}

struct CalendarHeatmapView: View {
    @Environment(\.forge) private var forge

    @Binding var zoom: CalendarZoom
    @Binding var anchor: Date
    @State private var selectedDay: IdentifiableDate?

    private var cal: Calendar { Calendar.forge }

    private var weekStart: Date {
        cal.dateInterval(of: .weekOfYear, for: anchor)?.start ?? anchor
    }

    private var title: String {
        switch zoom {
        case .week:
            let end = cal.date(byAdding: .day, value: 6, to: weekStart) ?? weekStart
            return "\(weekStart.formatted(.dateTime.month(.abbreviated).day())) – \(end.formatted(.dateTime.month(.abbreviated).day())), \(end.formatted(.dateTime.year()))"
        case .month:
            return anchor.formatted(.dateTime.month(.wide).year())
        case .year:
            return anchor.formatted(.dateTime.year())
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Space.md) {
            HStack {
                Text(title)
                    .font(.forgeHeadingMedium(17))
                    .foregroundStyle(forge.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Spacer(minLength: Space.sm)
                Button { shift(-1) } label: { Image(systemName: "chevron.left") }
                    .buttonStyle(.plain)
                    .frame(width: 28, height: 28)
                Button { shift(1) } label: { Image(systemName: "chevron.right") }
                    .buttonStyle(.plain)
                    .frame(width: 28, height: 28)
            }
            .foregroundStyle(forge.textSecondary)

            Picker("", selection: $zoom) {
                ForEach(CalendarZoom.allCases) { z in Text(z.rawValue).tag(z) }
            }
            .pickerStyle(.segmented)

            switch zoom {
            case .week:
                WeekCalendarView(weekStart: weekStart) { selectedDay = IdentifiableDate($0) }
            case .month:
                weekdayHeader
                MonthCalendarView(month: anchor) { selectedDay = IdentifiableDate($0) }
            case .year:
                ContributionGrid(year: anchor) { selectedDay = IdentifiableDate($0) }
            }

            legend
        }
        .forgeCard()
        .sheet(item: $selectedDay) { day in
            DayDetailSheet(date: day.date)
        }
    }

    private var weekdayHeader: some View {
        HStack {
            ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { d in
                Text(d).font(.forgeCaption(11)).foregroundStyle(forge.textTertiary).frame(maxWidth: .infinity)
            }
        }
    }

    /// One key for every zoom, because every zoom now paints from the same ramp.
    /// It reads as a scale rather than a list of names, which is what the ramp is.
    private var legend: some View {
        HStack(spacing: 6) {
            Spacer(minLength: 0)
            Text("Less").font(.forgeCaption(11)).foregroundStyle(forge.textSecondary)
            ForEach(0..<5, id: \.self) { level in
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .fill(forge.contribution[level])
                    .frame(width: 11, height: 11)
            }
            Text("More").font(.forgeCaption(11)).foregroundStyle(forge.textSecondary)
        }
        .padding(.top, Space.xs)
    }

    private func shift(_ delta: Int) {
        let component: Calendar.Component = zoom == .week ? .weekOfYear : (zoom == .month ? .month : .year)
        anchor = cal.date(byAdding: component, value: delta, to: anchor) ?? anchor
    }
}

/// A year as one wall of squares: a column per week, a row per weekday, intensity by
/// how much was done. Twelve mini month-grids showed the same days and let you compare
/// none of them — the point of this shape is that a year is legible in one look.
private struct ContributionGrid: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.forge) private var forge
    var year: Date
    var onSelectDay: (Date) -> Void

    private var cal: Calendar { Calendar.forge }
    private let cell: CGFloat = 11
    private let gap: CGFloat = 3

    /// Weeks as columns, each starting on the same weekday — that alignment is what
    /// makes a row scannable. The grid starts on the Sunday on or before Jan 1, so the
    /// first column may reach back into December; those days render empty.
    private var weeks: [[Date]] {
        guard let yearInterval = cal.dateInterval(of: .year, for: year) else { return [] }
        var day = cal.dateInterval(of: .weekOfYear, for: yearInterval.start)?.start ?? yearInterval.start
        var out: [[Date]] = []
        while day < yearInterval.end {
            var week: [Date] = []
            for _ in 0..<7 {
                week.append(day)
                day = cal.date(byAdding: .day, value: 1, to: day)!
            }
            out.append(week)
        }
        return out
    }

    /// Label a column when its month differs from the column before it.
    private func monthLabel(at index: Int) -> String? {
        guard let first = weeks[safe: index]?.first else { return nil }
        let month = cal.component(.month, from: first)
        if index == 0 { return nil }
        guard let prev = weeks[safe: index - 1]?.first else { return nil }
        guard cal.component(.month, from: prev) != month else { return nil }
        return first.formatted(.dateTime.month(.abbreviated))
    }

    var body: some View {
        // The weekday column sits OUTSIDE the scroll view. Inside it, anchoring to the
        // trailing edge scrolls the labels off-screen along with the oldest weeks, and
        // a row of squares with nothing naming it is just a row of squares.
        HStack(alignment: .top, spacing: gap) {
            weekdayLabels
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(alignment: .leading, spacing: gap) {
                    monthHeader
                    HStack(spacing: gap) {
                        ForEach(weeks.indices, id: \.self) { w in
                            VStack(spacing: gap) {
                                ForEach(0..<7, id: \.self) { d in
                                    cellView(weeks[w][d])
                                }
                            }
                        }
                    }
                }
                .padding(.vertical, 2)
            }
            .defaultScrollAnchor(.trailing)
        }
    }

    /// Mon, Wed and Fri only — seven labels would out-weigh the squares they label.
    private var weekdayLabels: some View {
        VStack(spacing: gap) {
            Color.clear.frame(height: 13)
            ForEach(0..<7, id: \.self) { row in
                Group {
                    switch row {
                    case 1: Text("Mon")
                    case 3: Text("Wed")
                    case 5: Text("Fri")
                    default: Text("")
                    }
                }
                .font(.forgeCaption(10))
                .foregroundStyle(forge.textTertiary)
                .frame(height: cell, alignment: .center)
            }
        }
        .frame(width: 28, alignment: .leading)
    }

    private var monthHeader: some View {
        HStack(spacing: gap) {
            ForEach(weeks.indices, id: \.self) { i in
                Text(monthLabel(at: i) ?? "")
                    .font(.forgeCaption(10))
                    .foregroundStyle(forge.textSecondary)
                    .fixedSize()
                    .frame(width: cell, height: 13, alignment: .leading)
            }
        }
    }

    private func cellView(_ day: Date) -> some View {
        let inYear = cal.isDate(day, equalTo: year, toGranularity: .year)
        let isToday = day.isSameDay(as: Date())
        return RoundedRectangle(cornerRadius: 2, style: .continuous)
            .fill(inYear ? appState.contributionFill(forge, for: day) : .clear)
            .frame(width: cell, height: cell)
            .overlay(
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .stroke(isToday ? forge.accent : .clear, lineWidth: 1.5)
            )
            .contentShape(Rectangle())
            .onTapGesture { if inYear { onSelectDay(day) } }
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
