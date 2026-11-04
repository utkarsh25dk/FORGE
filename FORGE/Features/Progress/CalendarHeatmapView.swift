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

/// The buckets the calendar sorts a day's work into. Ten categories would make the
/// grid confetti and most of them never appear; these are the distinctions you look
/// for when you ask what you trained, plus a catch-all. Order is the legend's order.
enum TrainingFamily: Int, CaseIterable {
    case upper, lower, full, cardio, mobility, other

    init(_ category: WorkoutCategory) {
        switch category {
        case .upperBody, .core: self = .upper
        case .lowerBody: self = .lower
        case .fullBody: self = .full
        case .cardio, .hiit, .activity, .sports: self = .cardio
        case .flexibility, .recovery: self = .mobility
        default: self = .other
        }
    }

    var label: String {
        switch self {
        case .upper: return "Upper"
        case .lower: return "Lower"
        case .full: return "Full body"
        case .cardio: return "Cardio"
        case .mobility: return "Mobility"
        case .other: return "Other"
        }
    }
}

extension AppState {
    /// The training families on a day, commonest first, capped at three. Capped because
    /// a fourth band in an 11pt square is a line rather than a colour; ordered by count
    /// so the day's main work is the band you read first.
    func dayFamilies(on date: Date) -> [TrainingFamily] {
        let done = entries(on: date).filter { $0.isCompleted && !$0.isWarmUp && !$0.isCoolDown }
        var counts: [TrainingFamily: Int] = [:]
        for entry in done { counts[TrainingFamily(entry.category), default: 0] += 1 }
        return counts
            .sorted { $0.value == $1.value ? $0.key.rawValue < $1.key.rawValue : $0.value > $1.value }
            .prefix(3)
            .map(\.key)
    }

    /// A day's fill: one hard-edged band per family trained, all the same height.
    ///
    /// Equal rather than proportional, on purpose. One leg exercise among five upper-body
    /// ones is a sliver at true scale and invisible at 11pt — and "did I train legs at
    /// all" is the question this grid gets asked. A day you could have trained and didn't
    /// keeps the empty tone, so a gap stays visible; a day that hasn't happened gets
    /// nothing at all.
    func dayFill(_ forge: ForgeColors, for date: Date) -> LinearGradient {
        let families = dayFamilies(on: date)
        guard !families.isEmpty else {
            let empty = dayStatus(for: date) == .none ? Color.clear : forge.contribution[0]
            return LinearGradient(colors: [empty, empty], startPoint: .top, endPoint: .bottom)
        }
        let step = 1.0 / Double(families.count)
        let stops = families.enumerated().flatMap { index, fam -> [Gradient.Stop] in
            let color = forge.family[fam.rawValue]
            return [Gradient.Stop(color: color, location: Double(index) * step),
                    Gradient.Stop(color: color, location: Double(index + 1) * step)]
        }
        return LinearGradient(stops: stops, startPoint: .top, endPoint: .bottom)
    }

    /// Ink for a day's numeral, legible against every band under it. Nil when untrained,
    /// where the caller's own text colour applies.
    func dayInk(_ forge: ForgeColors, for date: Date) -> Color? {
        let families = dayFamilies(on: date)
        guard !families.isEmpty else { return nil }
        return Color.ink(legibleOn: families.map { forge.family[$0.rawValue] })
    }
}

struct CalendarHeatmapView: View {
    @EnvironmentObject private var appState: AppState
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

    private var visibleDays: [Date] {
        let interval: DateInterval?
        switch zoom {
        case .week: interval = cal.dateInterval(of: .weekOfYear, for: anchor)
        case .month: interval = cal.dateInterval(of: .month, for: anchor)
        case .year: interval = cal.dateInterval(of: .year, for: anchor)
        }
        guard let interval else { return [] }
        var days: [Date] = []
        var day = interval.start
        while day < interval.end {
            days.append(day)
            day = cal.date(byAdding: .day, value: 1, to: day) ?? interval.end
        }
        return days
    }

    /// Only the families actually on screen. A key listing work you never do is a key
    /// you stop reading — and with nothing trained in range there is nothing to explain.
    private var visibleFamilies: [TrainingFamily] {
        var seen: Set<TrainingFamily> = []
        for day in visibleDays { seen.formUnion(appState.dayFamilies(on: day)) }
        return TrainingFamily.allCases.filter { seen.contains($0) }
    }

    /// One key for every zoom, because every zoom paints from the same families.
    private var legend: some View {
        let families = visibleFamilies
        return VStack(alignment: .trailing, spacing: 6) {
            ForEach(Array(stride(from: 0, to: families.count, by: 3)), id: \.self) { start in
                HStack(spacing: 12) {
                    ForEach(families[start..<min(start + 3, families.count)], id: \.rawValue) { family in
                        HStack(spacing: 5) {
                            RoundedRectangle(cornerRadius: 2, style: .continuous)
                                .fill(forge.family[family.rawValue])
                                .frame(width: 9, height: 9)
                            Text(family.label)
                                .font(.forgeCaption(11))
                                .foregroundStyle(forge.textSecondary)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
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
        let blank = LinearGradient(colors: [.clear, .clear], startPoint: .top, endPoint: .bottom)
        return RoundedRectangle(cornerRadius: 2, style: .continuous)
            .fill(inYear ? appState.dayFill(forge, for: day) : blank)
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
