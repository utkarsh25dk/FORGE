import SwiftUI

struct WorkoutRow: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.forge) private var forge
    var entry: WorkoutEntry
    var onEdit: () -> Void

    var body: some View {
        HStack(spacing: Space.sm) {
            Button {
                appState.toggleComplete(entry)
            } label: {
                Image(systemName: entry.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundStyle(entry.isCompleted ? forge.accent : forge.textTertiary)
                    .symbolEffect(.bounce, value: entry.isCompleted)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .sensoryFeedback(.selection, trigger: entry.isCompleted)

            Button(action: onEdit) {
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        if entry.isWarmUp { Image(systemName: "flame").font(.system(size: 11)).foregroundStyle(forge.warning) }
                        if entry.isCoolDown { Image(systemName: "snowflake").font(.system(size: 11)).foregroundStyle(forge.textSecondary) }
                        Text(entry.name)
                            .font(.forgeBodySemibold(15))
                            .foregroundStyle(entry.isCompleted ? forge.textSecondary : forge.textPrimary)
                            .strikethrough(entry.isCompleted)
                    }
                    Text(WorkoutEntryDisplay.summary(entry, unit: appState.userData.unitSystem))
                        .font(.forgeCaption())
                        .foregroundStyle(forge.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)

            if !entry.isWarmUp && !entry.isCoolDown {
                Button {
                    appState.deleteEntry(entry)
                } label: {
                    Image(systemName: "xmark.circle.fill")
                }
                .buttonStyle(ForgeDestructiveIconButtonStyle())
            }
        }
        .padding(.vertical, Space.xs)
    }
}
