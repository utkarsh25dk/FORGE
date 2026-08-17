import AppIntents

struct ForgeShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddWaterIntent(),
            phrases: [
                "Log water in \(.applicationName)",
                "Add a glass of water in \(.applicationName)",
                "Log a glass of water with \(.applicationName)",
            ],
            shortTitle: "Log Water",
            systemImageName: "drop.fill"
        )
        AppShortcut(
            intent: CheckStreakIntent(),
            phrases: [
                "What's my streak in \(.applicationName)",
                "Check my streak in \(.applicationName)",
                "Ask \(.applicationName) for my streak",
            ],
            shortTitle: "Check Streak",
            systemImageName: "flame.fill"
        )
    }
}
