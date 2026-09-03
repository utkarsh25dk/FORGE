import SwiftUI

struct ProgramDetailSheet: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.forge) private var forge
    @Environment(\.dismiss) private var dismiss
    let program: Program

    @State private var expandedWeek: Int? = 1
    @State private var confirmLeave = false

    private var isActive: Bool { appState.isEnrolled(in: program) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Space.xl) {
                    header
                    Text(program.summary)
                        .font(.forgeBody(14))
                        .foregroundStyle(forge.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(3)

                    VStack(alignment: .leading, spacing: Space.md) {
                        SectionHeader(title: "How it progresses")
                        ForEach(Array(program.weeks.enumerated()), id: \.offset) { i, week in
                            weekRow(index: i, week: week)
                        }
                    }

                    VStack(alignment: .leading, spacing: Space.md) {
                        SectionHeader(title: "A week looks like")
                        ForEach(Array(program.weekPattern.enumerated()), id: \.offset) { i, day in
                            dayRow(index: i, day: day)
                        }
                    }

                    actionButton
                    Spacer(minLength: Space.xl)
                }
                .padding(Space.lg)
            }
            .scrollIndicators(.hidden)
            .forgeScreenBackground()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }.foregroundStyle(forge.textSecondary)
                }
            }
            .alert("Leave \(program.name)?", isPresented: $confirmLeave) {
                Button("Leave", role: .destructive) { appState.leaveProgram(); dismiss() }
                Button("Stay", role: .cancel) {}
            } message: {
                Text("Your logged workouts stay. You'll lose your place in the program.")
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: Space.sm) {
            Text(program.name).font(.forgeHeading(30)).foregroundStyle(forge.textPrimary)
            Text(program.tagline).font(.forgeBody(14)).foregroundStyle(forge.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: Space.sm) {
                ForgeChip(label: "\(program.totalDays) days", systemImage: "calendar")
                ForgeChip(label: program.level.label, systemImage: program.level.icon)
            }
            Text("\(program.trainingDaysPerWeek) training days a week · \(program.equipmentLabel)")
                .font(.forgeCaption(12))
                .foregroundStyle(forge.textTertiary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func weekRow(index: Int, week: WeekProgression) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(week.label).font(.forgeBodySemibold(15)).foregroundStyle(forge.textPrimary)
            Text(week.note)
                .font(.forgeBody(13)).foregroundStyle(forge.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .forgeCard(padding: Space.md, cornerRadius: Radius.md)
    }

    private func dayRow(index: Int, day: ProgramDay) -> some View {
        HStack(spacing: Space.md) {
            Text("\(index + 1)")
                .font(.forgeNumeric(14))
                .foregroundStyle(day.isRest ? forge.textTertiary : forge.accent)
                .frame(width: 22)
            VStack(alignment: .leading, spacing: 2) {
                Text(day.title)
                    .font(.forgeBodySemibold(15))
                    .foregroundStyle(day.isRest ? forge.textSecondary : forge.textPrimary)
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
    }

    @ViewBuilder private var actionButton: some View {
        if isActive {
            Button { confirmLeave = true } label: {
                Text("Leave program")
                    .font(.forgeBodySemibold(16))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Space.md)
            }
            .foregroundStyle(forge.danger)
            .forgeGlassSecondary()
        } else {
            Button {
                appState.enroll(in: program)
                dismiss()
            } label: {
                Text(appState.activeEnrollment == nil ? "Start program" : "Switch to this program")
                    .font(.forgeBodySemibold(16))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Space.md)
            }
            .foregroundStyle(forge.onAccent)
            .background(RoundedRectangle(cornerRadius: Radius.md).fill(forge.accent))
        }
    }
}
