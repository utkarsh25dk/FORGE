import SwiftUI

struct LevelDetailSheet: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.forge) private var forge
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        let progress = appState.levelProgress
        NavigationStack {
            ScrollView {
                VStack(spacing: Space.xl) {
                    VStack(spacing: Space.sm) {
                        ZStack {
                            Circle().fill(forge.accentGlow).frame(width: 96, height: 96)
                            Text("\(progress.level)")
                                .font(.forgeDisplay(36))
                                .foregroundStyle(forge.accent)
                        }
                        Text("Level \(progress.level)")
                            .font(.forgeHeading(22))
                            .foregroundStyle(forge.textPrimary)
                        Text("\(progress.xpIntoLevel) / \(progress.xpForThisLevel) XP")
                            .font(.forgeBody(14))
                            .foregroundStyle(forge.textSecondary)
                    }
                    .padding(.top, Space.lg)

                    VStack(spacing: Space.sm) {
                        ProgressView(value: progress.progress)
                            .tint(forge.accent)
                        Text("\(progress.xpToNext) XP to level \(progress.level + 1)")
                            .font(.forgeCaption())
                            .foregroundStyle(forge.textSecondary)
                    }
                    .forgeCard()

                    VStack(alignment: .leading, spacing: Space.sm) {
                        Text("How to earn XP").font(.forgeHeadingMedium(16)).foregroundStyle(forge.textPrimary)
                        xpRow("Complete an exercise", LevelSystem.XP.completeExercise)
                        xpRow("Finish a full day's plan", LevelSystem.XP.completeFullDay)
                        xpRow("Hit your hydration goal", LevelSystem.XP.hydrationGoal)
                        xpRow("Log a sleep check-in", LevelSystem.XP.sleepCheckIn)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .forgeCard()

                    VStack(alignment: .leading, spacing: Space.md) {
                        Text("Badges").font(.forgeHeadingMedium(16)).foregroundStyle(forge.textPrimary)
                        BadgeGridView()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(Space.lg)
            }
            .forgeScreenBackground()
            .navigationTitle("Your Progress")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func xpRow(_ label: String, _ xp: Int) -> some View {
        HStack {
            Text(label).font(.forgeBody(14)).foregroundStyle(forge.textSecondary)
            Spacer()
            Text("+\(xp) XP").font(.forgeBodySemibold(14)).foregroundStyle(forge.accent)
        }
    }
}
