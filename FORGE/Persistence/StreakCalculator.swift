import Foundation

/// Pure streak/day-status logic, extracted so both AppState (in-app) and CheckStreakIntent
/// (Siri, runs standalone without a live AppState/AuthManager) share one source of truth.
enum StreakCalculator {
    static func dayStatus(for date: Date, entries: [WorkoutEntry], accountCreatedAt: Date?) -> DayStatus {
        let dayEntries = entries.filter { $0.date.isSameDay(as: date) && !$0.isWarmUp && !$0.isCoolDown }
        let completed = dayEntries.filter { $0.isCompleted }
        if !completed.isEmpty {
            let allRecovery = completed.allSatisfy { $0.category == .recovery }
            return allRecovery ? .rest : .worked
        }
        let today = Date().startOfDay
        if date.startOfDay < today {
            if let createdAt = accountCreatedAt?.startOfDay, date.startOfDay < createdAt {
                return .none
            }
            return .missed
        }
        return .none
    }

    static func currentStreak(entries: [WorkoutEntry], accountCreatedAt: Date?) -> Int {
        var streak = 0
        var day = Date().startOfDay
        if dayStatus(for: day, entries: entries, accountCreatedAt: accountCreatedAt) == .none {
            day = Calendar.forge.date(byAdding: .day, value: -1, to: day)!
        }
        while true {
            let status = dayStatus(for: day, entries: entries, accountCreatedAt: accountCreatedAt)
            if status == .worked || status == .rest {
                streak += 1
                day = Calendar.forge.date(byAdding: .day, value: -1, to: day)!
            } else {
                break
            }
        }
        return streak
    }
}
