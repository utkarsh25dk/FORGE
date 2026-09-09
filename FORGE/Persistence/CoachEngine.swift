import Foundation
import FoundationModels

/// One AI-generated coaching line, structured so the model can't wander off-format.
@Generable
struct CoachTip: Codable {
    @Guide(description: "A short, specific, encouraging coaching message — 1 to 2 sentences, under 220 characters. Reference the user's actual numbers when relevant. No emoji, no generic filler like 'keep it up'.")
    var message: String
    @Guide(description: "The tone that best fits the message given the user's current stats")
    var tone: CoachTone
}

@Generable
enum CoachTone: String, Codable {
    case encouraging
    case celebratory
    case nudge
    case informative
}

enum CoachAvailability: Equatable, Error {
    case ready
    case deviceNotEligible
    case appleIntelligenceOff
    case modelDownloading
    case unavailable
}

/// On-device AI coach: summarizes the user's recent activity into a short prompt and
/// asks Apple's on-device Foundation Models framework for one structured coaching tip.
/// Nothing leaves the device — no network call, no server. Cached once per day per
/// account so it doesn't regenerate (or re-spin the model) every time Home appears.
@MainActor
enum CoachEngine {
    static var availability: CoachAvailability {
        switch SystemLanguageModel.default.availability {
        case .available:
            return .ready
        case .unavailable(.deviceNotEligible):
            return .deviceNotEligible
        case .unavailable(.appleIntelligenceNotEnabled):
            return .appleIntelligenceOff
        case .unavailable(.modelNotReady):
            return .modelDownloading
        case .unavailable:
            return .unavailable
        }
    }

    private static func cacheKey(accountId: String) -> String {
        let day = ISO8601DateFormatter().string(from: Date().startOfDay)
        return "forge.coachTip.\(accountId).\(day)"
    }

    static func cachedTip(accountId: String) -> CoachTip? {
        guard let data = UserDefaults.standard.data(forKey: cacheKey(accountId: accountId)) else { return nil }
        return try? JSONDecoder().decode(CoachTip.self, from: data)
    }

    private static func cache(_ tip: CoachTip, accountId: String) {
        guard let data = try? JSONEncoder().encode(tip) else { return }
        UserDefaults.standard.set(data, forKey: cacheKey(accountId: accountId))
    }

    /// Builds a compact, numbers-only summary of recent activity — no free-form journal
    /// text — so the prompt stays small and the model has nothing to misinterpret.
    static func statsSummary(for appState: AppState) -> String {
        let streak = appState.currentStreak
        let worked = appState.weeklyWorkedDays()
        let goal = appState.userData.weeklyGoal
        let today = appState.checkIn(on: Date())
        let hydration = "\(today.hydrationCount)/\(DailyCheckIn.hydrationGoal) glasses"
        let sleep = today.sleepConfirmed ? "\(String(format: "%.1f", today.sleepHours ?? 0)) hrs logged" : "not logged"
        let total = appState.totalCompletedWorkouts

        var categoryCounts: [WorkoutCategory: Int] = [:]
        var patternCounts: [MovementPattern: Int] = [:]
        var muscleCounts: [Muscle: Int] = [:]
        let cutoff = Calendar.forge.date(byAdding: .day, value: -14, to: Date()) ?? Date()
        var recentCount = 0
        for entry in appState.userData.entries where entry.isCompleted && entry.date >= cutoff && !entry.isWarmUp && !entry.isCoolDown {
            categoryCounts[entry.category, default: 0] += 1
            patternCounts[entry.movementPattern, default: 0] += 1
            for muscle in entry.muscles { muscleCounts[muscle, default: 0] += 1 }
            recentCount += 1
        }
        let topCategory = categoryCounts.max { $0.value < $1.value }?.key.rawValue
        let leastTrainedBrowsable = WorkoutCategory.browsable
            .filter { categoryCounts[$0, default: 0] == 0 }
            .first?.rawValue

        var lines = [
            "Current streak: \(streak) day\(streak == 1 ? "" : "s")",
            "This week: \(worked)/\(goal) workout days toward weekly goal",
            "Missed yesterday: \(appState.missedYesterday ? "yes" : "no")",
            "Today's hydration: \(hydration)",
            "Today's sleep: \(sleep)",
            "Total completed workouts (all time): \(total)",
        ]
        if let topCategory { lines.append("Most-trained category last 14 days: \(topCategory)") }
        if let leastTrainedBrowsable { lines.append("Not trained at all in last 14 days: \(leastTrainedBrowsable)") }

        // Balance signals. Only included once there is enough recent work for them
        // to mean anything — calling a 2-workout fortnight "push-heavy" is noise.
        if recentCount >= 6 {
            let push = patternCounts[.push, default: 0]
            let pull = patternCounts[.pull, default: 0]
            if push + pull >= 4 {
                lines.append("Push exercises: \(push), pull exercises: \(pull) (last 14 days)")
            }

            let posterior = Muscle.allCases.filter(\.isPosteriorChain)
            let posteriorCount = posterior.reduce(0) { $0 + muscleCounts[$1, default: 0] }
            lines.append("Posterior chain (back, hamstrings, glutes, lower back) worked \(posteriorCount) time\(posteriorCount == 1 ? "" : "s") in last 14 days")

            let untrained = Muscle.allCases
                .filter { $0.isSpecificMuscle && muscleCounts[$0, default: 0] == 0 }
                .map(\.name)
            if !untrained.isEmpty {
                lines.append("Muscle groups not trained at all in last 14 days: \(untrained.joined(separator: ", "))")
            }
        }

        return lines.joined(separator: "\n")
    }

    /// Generates (or returns the cached) tip for today. Safe to call every time Home
    /// appears — it's a no-op after the first successful generation of the day.
    static func tip(for appState: AppState) async -> Result<CoachTip, CoachAvailability> {
        guard let accountId = appState.auth.currentAccount?.id else { return .failure(.unavailable) }
        if let cached = cachedTip(accountId: accountId) { return .success(cached) }

        let status = availability
        guard status == .ready else { return .failure(status) }

        let session = LanguageModelSession(
            instructions: """
            You are FORGE's on-device coach, speaking directly to the user in second person. \
            You're given a compact numeric summary of their recent workout, hydration, and sleep activity. \
            Write exactly one short coaching tip grounded in those numbers — celebrate real progress, \
            gently nudge on real gaps, or share one specific, useful observation. If the summary shows a \
            lopsided routine — far more pushing than pulling, a neglected posterior chain, or a muscle \
            group untouched for two weeks — that is usually the most useful thing you can point out. \
            Never invent numbers that weren't given to you. Keep it warm but plain-spoken, not corny.
            """
        )

        do {
            let response = try await session.respond(
                to: "Here is the user's current activity summary:\n\(statsSummary(for: appState))",
                generating: CoachTip.self
            )
            let tip = response.content
            cache(tip, accountId: accountId)
            return .success(tip)
        } catch {
            return .failure(.unavailable)
        }
    }
}
