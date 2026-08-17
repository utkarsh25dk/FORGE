import SwiftUI

struct BadgeGridView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.forge) private var forge

    private let columns = [GridItem(.adaptive(minimum: 84, maximum: 110), spacing: Space.md)]

    var body: some View {
        LazyVGrid(columns: columns, spacing: Space.md) {
            ForEach(BadgeLibrary.all) { badge in
                let earned = appState.userData.game.earnedBadgeIds.contains(badge.id)
                VStack(spacing: 6) {
                    ZStack {
                        Circle()
                            .fill(earned ? AnyShapeStyle(forge.accentSoft) : AnyShapeStyle(forge.raised))
                            .frame(width: 56, height: 56)
                        Image(systemName: badge.icon)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(earned ? forge.accent : forge.textTertiary)
                    }
                    Text(badge.name)
                        .font(.forgeCaption(11))
                        .foregroundStyle(earned ? forge.textPrimary : forge.textTertiary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
                .opacity(earned ? 1 : 0.55)
            }
        }
    }
}
