import SwiftUI

struct BadgeDetailSheet: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.forge) private var forge
    @Environment(\.dismiss) private var dismiss

    private var earnedCount: Int { appState.userData.game.earnedBadgeIds.count }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Space.lg) {
                    Text("\(earnedCount) of \(BadgeLibrary.all.count) badges earned")
                        .font(.forgeBodyMedium(14))
                        .foregroundStyle(forge.textSecondary)

                    VStack(spacing: 2) {
                        ForEach(BadgeLibrary.all) { badge in
                            let earned = appState.userData.game.earnedBadgeIds.contains(badge.id)
                            HStack(spacing: Space.md) {
                                ZStack {
                                    Circle()
                                        .fill(forge.raised)
                                        .frame(width: 44, height: 44)
                                    Image(systemName: badge.icon)
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundStyle(earned ? forge.textPrimary : forge.textTertiary)
                                }
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(badge.name)
                                        .font(.forgeBodySemibold(15))
                                        .foregroundStyle(earned ? forge.textPrimary : forge.textTertiary)
                                    Text(badge.description)
                                        .font(.forgeCaption(12))
                                        .foregroundStyle(forge.textSecondary)
                                }
                                Spacer(minLength: 0)
                                Image(systemName: earned ? "checkmark.circle.fill" : "lock.fill")
                                    .foregroundStyle(earned ? forge.textPrimary : forge.textTertiary)
                                    .font(.system(size: earned ? 18 : 14))
                            }
                            .padding(.vertical, Space.sm)
                            .padding(.horizontal, Space.md)
                        }
                    }
                    .forgeCard(padding: 0, cornerRadius: Radius.md)
                }
                .padding(Space.lg)
            }
            .scrollIndicators(.hidden)
            .forgeScreenBackground()
            .navigationTitle("Badges")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } }
            }
        }
        .presentationDetents([.large])
    }
}
