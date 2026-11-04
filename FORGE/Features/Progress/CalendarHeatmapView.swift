import SwiftUI

extension DayStatus {
    /// Calendar fills are neutral on purpose: the only colour in the calendar is the
    /// accent ring on today, so the eye goes there first and nowhere else. The three
    /// statuses separate by weight rather than hue.
    ///
    /// Worked is heaviest because it is what the calendar is for. Missed sits clearly
    /// above rest — a lapse is information you want, and a run of them should read as
    /// plainly as a streak does. Rest is quietest: it is the absence of a decision.
    ///
    /// Hue carried this before. Weight is the weaker signal of the two, which is the
    /// price of a single-accent calendar; the spacing below is chosen so the three
    /// stay apart in both themes.
    ///
    /// `emphasis` scales the fill for marks too small to read at the base weight —
    /// the year grid's dots and the legend's swatches.
    func calendarFill(_ forge: ForgeColors, emphasis: Double = 1) -> Color? {
        let weight: Double
        switch self {
        case .worked: weight = 0.32
        case .missed: weight = 0.18
        case .rest:   weight = 0.10
        case .none:   return nil
        }
        return forge.textPrimary.opacity(min(weight * emphasis, 1))
    }
}

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
                yearGrid
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

    private var yearGrid: some View {
        let months = (0..<12).map { cal.date(byAdding: .month, value: $0, to: cal.date(from: cal.dateComponents([.year], from: anchor))!)! }
        let columns = [GridItem(.flexible(), spacing: Space.md), GridItem(.flexible(), spacing: Space.md), GridItem(.flexible(), spacing: Space.md)]
        return LazyVGrid(columns: columns, spacing: Space.lg) {
            ForEach(months, id: \.self) { m in
                MonthCalendarView(month: m, compact: true) { selectedDay = IdentifiableDate($0) }
            }
        }
    }

    private var legend: some View {
        HStack(spacing: Space.lg) {
            legendItem(color: DayStatus.worked.calendarFill(forge, emphasis: 1.8), label: "Worked out")
            legendItem(color: DayStatus.rest.calendarFill(forge, emphasis: 1.8), label: "Rest")
            legendItem(color: DayStatus.missed.calendarFill(forge, emphasis: 1.8), label: "Missed")
        }
        .padding(.top, Space.xs)
    }

    private func legendItem(color: Color?, label: String) -> some View {
        HStack(spacing: 6) {
            Capsule().fill(color ?? .clear).frame(width: 16, height: 6)
            Text(label).font(.forgeCaption(11)).foregroundStyle(forge.textSecondary)
        }
    }

    private func shift(_ delta: Int) {
        let component: Calendar.Component = zoom == .week ? .weekOfYear : (zoom == .month ? .month : .year)
        anchor = cal.date(byAdding: component, value: delta, to: anchor) ?? anchor
    }
}
