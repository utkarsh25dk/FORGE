import SwiftUI

@main
struct FORGEApp: App {
    @StateObject private var auth = AuthManager()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(auth)
                .withForgeTheme()
                .dynamicTypeSize(.large)
        }
    }
}
