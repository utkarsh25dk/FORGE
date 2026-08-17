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

    var icon: String {
        switch self {
        case .home: return "flame.fill"
        case .train: return "checklist"
        case .suggest: return "sparkles"
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
                HomeView().forgeScreenBackground().tint(forge.accent)
            }
            Tab(ForgeTab.train.title, systemImage: ForgeTab.train.icon, value: ForgeTab.train) {
                TrainView().forgeScreenBackground().tint(forge.accent)
            }
            Tab(ForgeTab.suggest.title, systemImage: ForgeTab.suggest.icon, value: ForgeTab.suggest) {
                SuggestView().tint(forge.accent)
            }
            Tab(ForgeTab.progress.title, systemImage: ForgeTab.progress.icon, value: ForgeTab.progress) {
                ProgressDashboardView().forgeScreenBackground().tint(forge.accent)
            }
            Tab(ForgeTab.profile.title, systemImage: ForgeTab.profile.icon, value: ForgeTab.profile) {
                ProfileView().forgeScreenBackground().tint(forge.accent)
            }
        }
        .sensoryFeedback(.selection, trigger: tab)
        .sensoryFeedback(.success, trigger: appState.toast)
        .tint(Color(hex: "FF5C2E"))
        .overlay(alignment: .bottom) {
            if let toast = appState.toast {
                ForgeToast(message: toast)
                    .padding(.bottom, 90)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
}
