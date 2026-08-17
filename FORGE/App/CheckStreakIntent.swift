import AppIntents

struct CheckStreakIntent: AppIntent {
    static var title: LocalizedStringResource = "Check My Streak"
    static var description = IntentDescription("Reports your current FORGE streak.")

    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard let rememberedId = UserDefaults.standard.string(forKey: "forge.rememberedAccountId"),
              let account = Store.loadAccounts().first(where: { $0.id == rememberedId }),
              let userData = Store.loadUserData(accountId: account.id) else {
            return .result(dialog: "Sign in to FORGE to start a streak.")
        }

        let streak = StreakCalculator.currentStreak(entries: userData.entries, accountCreatedAt: account.createdAt)

        let dialog: String
        switch streak {
        case 0:
            let today = StreakCalculator.dayStatus(for: Date(), entries: userData.entries, accountCreatedAt: account.createdAt)
            dialog = today == .none ? "No streak yet — log a workout or rest day today to start one." : "Your streak is at zero. Log today's workout to start a new one."
        case 1:
            dialog = "You're on a 1 day streak. Keep it going."
        default:
            dialog = "You're on a \(streak) day streak. Keep it going."
        }
        return .result(dialog: IntentDialog(stringLiteral: dialog))
    }
}
