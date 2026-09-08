import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.forge) private var forge
    @State private var scrollOffset: CGFloat = 0

    private var collapseProgress: CGFloat {
        min(max(scrollOffset / 70, 0), 1)
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: Space.xl) {
                header
                CoachTipCard()
                TodayProgramCard()
                TodayCard()
                Spacer(minLength: 90)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Space.lg)
        }
        .scrollIndicators(.hidden)
        .onScrollGeometryChange(for: CGFloat.self) { geometry in
            geometry.contentOffset.y
        } action: { _, newValue in
            scrollOffset = newValue
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: Space.sm) {
            Text("\(MotivationContent.greeting()), \(appState.userData.characterName)")
                .font(.forgeHeading(30 - 5 * collapseProgress))
                .foregroundStyle(forge.textPrimary)
            Text(appState.missedYesterday ? MotivationContent.comeback(for: Date()) : MotivationContent.rhyme(for: Date()))
                .font(.forgeBody(15))
                .foregroundStyle(forge.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .opacity(1 - collapseProgress)
                .frame(maxHeight: 60 * (1 - collapseProgress), alignment: .top)
                .clipped()
        }
        .padding(.top, Space.md - (Space.md * collapseProgress * 0.4))
        .animation(.easeOut(duration: 0.15), value: collapseProgress)
    }
}
