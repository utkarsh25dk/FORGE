import SwiftUI

/// Home-screen card for the active program: what today's day is, and one button to
/// pull it into the plan. Renders nothing when no program is running.
struct TodayProgramCard: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.forge) private var forge

    private var day: ResolvedProgramDay? { appState.currentProgramDay }
    private var program: Program? { appState.activeProgram }
    /// Already pulled into today's plan, so the button doesn't duplicate entries.
    private var alreadyApplied: Bool {
        guard let day else { return false }
        return appState.programEntries(on: Date()).contains { $0.programDayIndex == day.dayIndex }
    }

    var body: some View {
        if let program, let day, let enrollment = appState.activeEnrollment {
            VStack(alignment: .leading, spacing: Space.md) {
                HStack(alignment: .firstTextBaseline) {
                    Text(program.name)
                        .font(.forgeHeading(18))
                        .foregroundStyle(forge.textPrimary)
                    Spacer()
                    Text("Day \(day.dayNumber) of \(program.totalDays)")
                        .font(.forgeCaption(12))
                        .foregroundStyle(forge.textSecondary)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(forge.raised).frame(height: 6)
                        Capsule().fill(forge.accent)
                            .frame(width: max(0, geo.size.width * enrollment.progress), height: 6)
                    }
                }
                .frame(height: 6)

                VStack(alignment: .leading, spacing: 4) {
                    Text(day.isRest ? "Rest day" : day.title)
                        .font(.forgeBodySemibold(16))
                        .foregroundStyle(forge.textPrimary)
                    Text(day.isRest
                         ? "Nothing scheduled. Rest is part of the program."
                         : day.slots.compactMap { $0.template?.name }.joined(separator: " · "))
                        .font(.forgeCaption(12))
                        .foregroundStyle(forge.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Text(day.progression.note)
                    .font(.forgeBody(12))
                    .foregroundStyle(forge.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                actionButton(day: day)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .forgeCard()
        }
    }

    @ViewBuilder private func actionButton(day: ResolvedProgramDay) -> some View {
        if day.isRest {
            Button { appState.completeProgramDay(day.dayIndex) } label: {
                Text("Mark rest day done")
                    .font(.forgeBodySemibold(15))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Space.sm + 2)
            }
            .foregroundStyle(forge.textPrimary)
            .forgeGlassSecondary()
        } else if alreadyApplied {
            HStack(spacing: 6) {
                Image(systemName: "checkmark.circle.fill").font(.system(size: 13, weight: .semibold))
                Text("Added to today's plan").font(.forgeBodyMedium(14))
            }
            .foregroundStyle(forge.success)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Space.sm + 2)
        } else {
            Button { appState.applyProgramDay(day) } label: {
                Text("Add today's session")
                    .font(.forgeBodySemibold(15))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Space.sm + 2)
            }
            .foregroundStyle(forge.onAccent)
            .background(RoundedRectangle(cornerRadius: Radius.md).fill(forge.accent))
        }
    }
}
