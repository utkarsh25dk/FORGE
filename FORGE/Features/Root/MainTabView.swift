import SwiftUI

enum ForgeTab: Int, CaseIterable, Hashable {
    case home, train, suggest, progress, profile

    var title: String {
        switch self {
        case .home: return "Forge"
        case .train: return "Train"
        case .suggest: return "Suggest"
        case .progress: return "Progress"
        case .profile: return "Profile"
        }
    }

    /// Tab symbols are filled, and say so explicitly: the bar renders all five at one
    /// size, so a stroked symbol beside a solid one reads as a rank that isn't there.
    /// Any replacement needs a `.fill` variant — `checklist` and `sparkles` have none.
    var icon: String {
        switch self {
        case .home: return "flame.fill"
        case .train: return "dumbbell.fill"
        case .suggest: return "lightbulb.fill"
        case .progress: return "chart.bar.fill"
        case .profile: return "person.fill"
        }
    }
}

struct MainTabView: View {
    @Environment(\.forge) private var forge
    @EnvironmentObject private var appState: AppState
    @State private var tab: ForgeTab = .home

    var body: some View {
        TabView(selection: $tab) {
            Tab(ForgeTab.home.title, systemImage: ForgeTab.home.icon, value: ForgeTab.home) {
                HomeView().forgeScreenBackground()
            }
            Tab(ForgeTab.train.title, systemImage: ForgeTab.train.icon, value: ForgeTab.train) {
                TrainView().forgeScreenBackground()
            }
            Tab(ForgeTab.suggest.title, systemImage: ForgeTab.suggest.icon, value: ForgeTab.suggest) {
                SuggestView()
            }
            Tab(ForgeTab.progress.title, systemImage: ForgeTab.progress.icon, value: ForgeTab.progress) {
                ProgressDashboardView().forgeScreenBackground()
            }
            Tab(ForgeTab.profile.title, systemImage: ForgeTab.profile.icon, value: ForgeTab.profile) {
                ProfileView().forgeScreenBackground()
            }
        }
        .sensoryFeedback(.selection, trigger: tab)
        .sensoryFeedback(.success, trigger: appState.toast)
        // One accent, set once: it marks the selected tab and every control inside all five screens.
        .tint(forge.accent)
        .overlay(alignment: .bottom) {
            if let toast = appState.toast {
                ForgeToast(message: toast)
                    .padding(.bottom, 90)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
}
