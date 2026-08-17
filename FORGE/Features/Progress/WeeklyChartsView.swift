import SwiftUI
import Charts

private struct DayMetric: Identifiable {
    let id = UUID()
    let day: Date
    let value: Double
    let isMissed: Bool
}

struct WeeklyChartsView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.forge) private var forge

    var zoom: CalendarZoom
    var anchor: Date

    @State private var isExpanded = false
    @State private var selectedWorkoutDay: Date?
    @State private var breakdownDay: IdentifiableDate?

    @State private var selectedSleepDay: Date?
    @State private var sleepDetailDay: IdentifiableDate?

    @State private var selectedWaterDay: Date?
    @State private var waterDetailDay: IdentifiableDate?

    private var cal: Calendar { Calendar.forge }

    // MARK: - Period calculation

    private func daysIn(month: Date) -> [Date] {
        guard let interval = cal.dateInterval(of: .month, for: month) else { return [] }
        var days: [Date] = []
        var d = interval.start
        while d < interval.end {
            days.append(d)
            d = cal.date(byAdding: .day, value: 1, to: d)!
        }
        return days
    }

    /// Today is always the last point plotted — future dates are never shown, even as zeros.
    private var todayStart: Date { Date().startOfDay }

    private func elapsedDaysIn(month: Date) -> [Date] {
        daysIn(month: month).filter { $0 <= todayStart }
    }

    private var periodDays: [Date] {
        switch zoom {
        case .week:
            let start = cal.dateInterval(of: .weekOfYear, for: anchor)?.start ?? anchor
            return (0..<7).map { cal.date(byAdding: .day, value: $0, to: start)! }.filter { $0 <= todayStart }
        case .month:
            return elapsedDaysIn(month: anchor)
        case .year:
            return []
        }
    }

    private var periodMonths: [Date] {
        guard let yearInterval = cal.dateInterval(of: .year, for: anchor) else { return [] }
        return (0..<12).map { cal.date(byAdding: .month, value: $0, to: yearInterval.start)! }
            .filter { $0 <= todayStart }
    }

    private var isInteractive: Bool { zoom != .year }
    private var xUnit: Calendar.Component { zoom == .year ? .month : .day }

    // MARK: - Data series

    private var workoutData: [DayMetric] {
        if zoom == .year {
            return periodMonths.map { monthStart in
                let total = elapsedDaysIn(month: monthStart).reduce(0) { sum, day in
                    sum + appState.entries(on: day).filter { $0.isCompleted && !$0.isWarmUp && !$0.isCoolDown }.count
                }
                return DayMetric(day: monthStart, value: Double(total), isMissed: false)
            }
        }
        return periodDays.map { day in
            let count = appState.entries(on: day).filter { $0.isCompleted && !$0.isWarmUp && !$0.isCoolDown }.count
            return DayMetric(day: day, value: Double(count), isMissed: appState.dayStatus(for: day) == .missed)
        }
    }

    private var sleepData: [DayMetric] {
        if zoom == .year {
            return periodMonths.map { monthStart in
                let values = elapsedDaysIn(month: monthStart).compactMap { appState.checkIn(on: $0).sleepHours }
                let avg = values.isEmpty ? 0 : values.reduce(0, +) / Double(values.count)
                return DayMetric(day: monthStart, value: avg, isMissed: false)
            }
        }
        return periodDays.map { day in
            DayMetric(day: day, value: appState.checkIn(on: day).sleepHours ?? 0, isMissed: appState.dayStatus(for: day) == .missed)
        }
    }

    private var hydrationData: [DayMetric] {
        if zoom == .year {
            return periodMonths.map { monthStart in
                let days = elapsedDaysIn(month: monthStart)
                let values = days.map { Double(appState.checkIn(on: $0).hydrationCount) }
                let avg = values.isEmpty ? 0 : values.reduce(0, +) / Double(values.count)
                return DayMetric(day: monthStart, value: avg, isMissed: false)
            }
        }
        return periodDays.map { day in
            DayMetric(day: day, value: Double(appState.checkIn(on: day).hydrationCount), isMissed: appState.dayStatus(for: day) == .missed)
        }
    }

    private var workoutYDomain: ClosedRange<Double> {
        let maxValue = workoutData.map(\.value).max() ?? 0
        return 0...max(4, maxValue + 1)
    }

    private var sleepColor: Color { forge.dataSleep }
    private var hydrationColor: Color { forge.dataHydration }
    private var missedColor: Color { DayStatus.missed.color(forge) ?? forge.textTertiary }

    private var sectionTitle: String {
        switch zoom {
        case .week: return "This Week"
        case .month: return "This Month"
        case .year: return "This Year"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Space.lg) {
            toggleButton

            if isExpanded {
                chartsContent
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .forgeCard()
        .sheet(item: $breakdownDay) { day in
            WorkoutBreakdownSheet(date: day.date)
        }
        .sheet(item: $sleepDetailDay) { day in
            SleepDetailSheet(date: day.date)
        }
        .sheet(item: $waterDetailDay) { day in
            HydrationDetailSheet(date: day.date)
        }
    }

    private var toggleButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.25)) { isExpanded.toggle() }
        } label: {
            HStack(spacing: Space.sm) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(forge.accent)
                VStack(alignment: .leading, spacing: 2) {
                    Text(sectionTitle).font(.forgeBodySemibold(15)).foregroundStyle(forge.textPrimary)
                    if !isExpanded {
                        Text("Tap to view trends").font(.forgeCaption()).foregroundStyle(forge.textSecondary)
                    }
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.down")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(forge.textTertiary)
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var chartsContent: some View {
        VStack(alignment: .leading, spacing: Space.xl) {
            VStack(alignment: .leading, spacing: Space.sm) {
                chartHeader("Workouts completed")
                Chart(workoutData) { item in
                    LineMark(x: .value("Period", item.day, unit: xUnit), y: .value("Workouts", item.value))
                        .foregroundStyle(forge.accent)
                        .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                        .interpolationMethod(.catmullRom)
                    PointMark(x: .value("Period", item.day, unit: xUnit), y: .value("Workouts", item.value))
                        .foregroundStyle(item.isMissed ? missedColor : forge.accent)
                        .symbolSize(45)
                        .annotation(position: .top) { pointLabel(item.value, decimals: 0) }
                }
                .chartXSelection(value: $selectedWorkoutDay)
                .chartXAxis { periodAxisMarks() }
                .chartYScale(domain: workoutYDomain)
                .chartYAxis { AxisMarks(position: .leading, values: .automatic(desiredCount: 3)) }
                .frame(height: 140)
                .onChange(of: selectedWorkoutDay) { _, newValue in
                    guard isInteractive, let newValue else { return }
                    breakdownDay = IdentifiableDate(newValue.startOfDay)
                }
            }

            VStack(alignment: .leading, spacing: Space.sm) {
                chartHeader("Water intake")
                Chart(hydrationData) { item in
                    LineMark(x: .value("Period", item.day, unit: xUnit), y: .value("Glasses", item.value))
                        .foregroundStyle(hydrationColor)
                        .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                        .interpolationMethod(.catmullRom)
                    PointMark(x: .value("Period", item.day, unit: xUnit), y: .value("Glasses", item.value))
                        .foregroundStyle(item.isMissed ? missedColor : hydrationColor)
                        .symbolSize(45)
                        .annotation(position: .top) { pointLabel(item.value, decimals: zoom == .year ? 1 : 0) }
                    RuleMark(y: .value("Goal", DailyCheckIn.hydrationGoal))
                        .foregroundStyle(forge.textTertiary.opacity(0.5))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [3, 3]))
                }
                .chartXSelection(value: $selectedWaterDay)
                .chartXAxis { periodAxisMarks() }
                .chartYScale(domain: 0...(DailyCheckIn.hydrationGoal))
                .chartYAxis { AxisMarks(position: .leading, values: .automatic(desiredCount: 3)) }
                .frame(height: 140)
                .onChange(of: selectedWaterDay) { _, newValue in
                    guard isInteractive, let newValue else { return }
                    waterDetailDay = IdentifiableDate(newValue.startOfDay)
                }
            }

            VStack(alignment: .leading, spacing: Space.sm) {
                chartHeader("Sleep (hrs)")
                Chart(sleepData) { item in
                    LineMark(x: .value("Period", item.day, unit: xUnit), y: .value("Hours", item.value))
                        .foregroundStyle(sleepColor)
                        .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                        .interpolationMethod(.catmullRom)
                    PointMark(x: .value("Period", item.day, unit: xUnit), y: .value("Hours", item.value))
                        .foregroundStyle(item.isMissed ? missedColor : sleepColor)
                        .symbolSize(45)
                        .annotation(position: .top) { pointLabel(item.value, decimals: 1) }
                }
                .chartXSelection(value: $selectedSleepDay)
                .chartXAxis { periodAxisMarks() }
                .chartYScale(domain: 0...12)
                .chartYAxis { AxisMarks(position: .leading, values: .automatic(desiredCount: 3)) }
                .frame(height: 140)
                .onChange(of: selectedSleepDay) { _, newValue in
                    guard isInteractive, let newValue else { return }
                    sleepDetailDay = IdentifiableDate(newValue.startOfDay)
                }
            }
        }
    }

    @ViewBuilder
    private func pointLabel(_ value: Double, decimals: Int) -> some View {
        if zoom != .month && value > 0 {
            Text(decimals == 0 ? "\(Int(value))" : String(format: "%.\(decimals)f", value))
                .font(.forgeCaption(9))
                .foregroundStyle(forge.textSecondary)
        }
    }

    @AxisContentBuilder
    private func periodAxisMarks() -> some AxisContent {
        switch zoom {
        case .week:
            AxisMarks(values: .stride(by: .day)) { AxisValueLabel(format: .dateTime.weekday(.narrow)) }
        case .month:
            AxisMarks(values: .stride(by: .day, count: 5)) { AxisValueLabel(format: .dateTime.day()) }
        case .year:
            AxisMarks(values: .stride(by: .month)) { AxisValueLabel(format: .dateTime.month(.narrow)) }
        }
    }

    private func chartHeader(_ title: String) -> some View {
        HStack {
            Text(title).font(.forgeBodyMedium(14)).foregroundStyle(forge.textSecondary)
            Spacer(minLength: 0)
            if isInteractive {
                Text("Tap a point for details").font(.forgeCaption(11)).foregroundStyle(forge.textTertiary)
            }
        }
    }
}
