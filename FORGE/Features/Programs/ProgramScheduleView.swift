import SwiftUI

/// The full run of the active program, day by day and grouped by week, so the
/// user can see where they are rather than only what today holds.
struct ProgramScheduleView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.forge) private var forge

    let program: Program

    private var enrollment: ProgramEnrollment? { appState.activeEnrollment }
    private var currentIndex: Int { enrollment?.currentDayIndex ?? 0 }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Space.xl) {
                summary

                ForEach(1...max(1, program.weekCount), id: \.self) { week in
                    weekSection(week)
                }
                Spacer(minLength: 90)
            }
            .padding(Space.lg)
        }
        .scrollIndicators(.hidden)
        .forgeScreenBackground()
        .navigationTitle(program.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var summary: some View {
        VStack(alignment: .leading, spacing: Space.sm) {
            if let e = enrollment {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(forge.raised).frame(height: 6)
                        Capsule().fill(forge.accent)
                            .frame(width: max(0, geo.size.width * e.progress), height: 6)
                    }
                }
                .frame(height: 6)
                Text("\(e.completedDayIndices.count) of \(program.totalDays) days done · day \(min(currentIndex + 1, program.totalDays)) is next")
                    .font(.forgeCaption(12))
                    .foregroundStyle(forge.textSecondary)
            }
        }
    }

    @ViewBuilder private func weekSection(_ week: Int) -> some View {
        let progression = program.weeks[week - 1]
        VStack(alignment: .leading, spacing: Space.md) {
            SectionHeader(title: progression.label)
            Text(progression.note)
                .font(.forgeBody(13))
                .foregroundStyle(forge.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            ForEach(daysIn(week: week)) { day in
                dayRow(day)
            }
        }
    }

    private func daysIn(week: Int) -> [ResolvedProgramDay] {
        let start = (week - 1) * program.daysPerWeek
        return (start..<(start + program.daysPerWeek)).compactMap { program.day(at: $0) }
    }

    @ViewBuilder private func dayRow(_ day: ResolvedProgramDay) -> some View {
        let done = appState.isProgramDayComplete(day.dayIndex)
        let isCurrent = day.dayIndex == currentIndex

        HStack(alignment: .top, spacing: Space.md) {
            statusMark(done: done, isCurrent: isCurrent, isRest: day.isRest)
                .frame(width: 22)

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: Space.sm) {
                    Text("Day \(day.dayNumber) · \(day.isRest ? "Rest" : day.title)")
                        .font(.forgeBodySemibold(15))
                        .foregroundStyle(done ? forge.textSecondary : forge.textPrimary)
                        .strikethrough(done, color: forge.textTertiary)
                    if isCurrent {
                        Text("TODAY")
                            .font(.forgeCaption(10))
                            .foregroundStyle(forge.onAccent)
                            .padding(.horizontal, 6).padding(.vertical, 2)
                            .background(Capsule().fill(forge.accent))
                    }
                }
                if !day.isRest {
                    Text(day.slots.compactMap { $0.template?.name }.joined(separator: " · "))
                        .font(.forgeCaption(12))
                        .foregroundStyle(forge.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .forgeCard(padding: Space.md, cornerRadius: Radius.md)
        .opacity(done ? 0.65 : 1)
    }

    @ViewBuilder private func statusMark(done: Bool, isCurrent: Bool, isRest: Bool) -> some View {
        if done {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(forge.success)
        } else if isCurrent {
            Image(systemName: "circle.inset.filled")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(forge.accent)
        } else {
            Image(systemName: isRest ? "moon.zzz" : "circle")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(forge.textTertiary)
        }
    }
}
