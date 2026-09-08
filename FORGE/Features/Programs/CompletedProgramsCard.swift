import SwiftUI

/// Programs the user has finished. Renders nothing until there's at least one,
/// so it stays out of the way early on.
struct CompletedProgramsCard: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.forge) private var forge

    var body: some View {
        let finished = appState.finishedEnrollments
        if !finished.isEmpty {
            VStack(alignment: .leading, spacing: Space.md) {
                SectionHeader(title: "Completed programs",
                              subtitle: "\(finished.count) finished")

                ForEach(finished) { enrollment in
                    if let program = enrollment.program {
                        HStack(spacing: Space.md) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(forge.success)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(program.name)
                                    .font(.forgeBodySemibold(15))
                                    .foregroundStyle(forge.textPrimary)
                                Text(subtitle(for: enrollment, program: program))
                                    .font(.forgeCaption(12))
                                    .foregroundStyle(forge.textSecondary)
                            }
                            Spacer(minLength: 0)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .forgeCard(padding: Space.md, cornerRadius: Radius.md)
                    }
                }
            }
        }
    }

    private func subtitle(for enrollment: ProgramEnrollment, program: Program) -> String {
        var parts = ["\(program.totalDays) days"]
        if let done = enrollment.completedAt {
            parts.append("finished \(done.formatted(.dateTime.month().day().year()))")
        }
        return parts.joined(separator: " · ")
    }
}
