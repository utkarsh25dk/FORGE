import SwiftUI

struct PersonalRecordsView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.forge) private var forge
    @State private var isExpanded = false

    private var records: [PersonalRecord] {
        appState.userData.personalRecords.values.sorted { $0.weight > $1.weight }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Space.md) {
            Button {
                withAnimation(.easeInOut(duration: 0.25)) { isExpanded.toggle() }
            } label: {
                HStack(spacing: Space.sm) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(forge.accent)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Personal Records").font(.forgeBodySemibold(15)).foregroundStyle(forge.textPrimary)
                        if !isExpanded {
                            Text(records.isEmpty ? "No PRs yet" : "\(records.count) record\(records.count == 1 ? "" : "s")")
                                .font(.forgeCaption())
                                .foregroundStyle(forge.textSecondary)
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

            if isExpanded {
                Group {
                    if records.isEmpty {
                        EmptyStateView(icon: "trophy", title: "No PRs yet", message: "Complete a strength exercise with weight logged to set your first record.")
                    } else {
                        VStack(spacing: 2) {
                            ForEach(records.prefix(10), id: \.exerciseName) { record in
                                HStack {
                                    Image(systemName: "trophy.fill").foregroundStyle(forge.accent).font(.system(size: 14))
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(record.exerciseName).font(.forgeBodyMedium(14)).foregroundStyle(forge.textPrimary)
                                        Text(record.date.formatted(.dateTime.month().day().year())).font(.forgeCaption(11)).foregroundStyle(forge.textTertiary)
                                    }
                                    Spacer()
                                    Text("\(Int(record.weight)) \(appState.userData.unitSystem.weightUnit) × \(record.reps)")
                                        .font(.forgeBodySemibold(14)).foregroundStyle(forge.textPrimary)
                                }
                                .padding(.vertical, 6)
                            }
                        }
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .forgeCard()
    }
}
