import SwiftUI

struct RootView: View {
    @EnvironmentObject private var auth: AuthManager

    var body: some View {
        Group {
            if !auth.isAuthenticated {
                AuthContainerView()
            } else if !auth.isUnlocked {
                BiometricLockView()
            } else {
                AppContainerView(auth: auth)
                    .id(auth.currentAccount?.id)
            }
        }
    }
}

/// Owns the per-account AppState so switching users creates a fresh store.
struct AppContainerView: View {
    @StateObject private var appState: AppState
    @StateObject private var themeManager = ThemeManager()
    @Environment(\.scenePhase) private var scenePhase

    init(auth: AuthManager) {
        _appState = StateObject(wrappedValue: AppState(auth: auth))
    }

    var body: some View {
        Group {
            if appState.userData.onboardingComplete {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .environmentObject(appState)
        .environmentObject(themeManager)
        .withForgeTheme()
        .preferredColorScheme(themeManager.preferredColorScheme)
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                appState.syncPendingWidgetHydration()
                appState.evaluateEveningReminder()
            }
        }
    }
}
