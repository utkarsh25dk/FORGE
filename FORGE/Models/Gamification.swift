import Foundation

struct GameProfile: Codable, Hashable {
    var xp: Int = 0
    var earnedBadgeIds: Set<String> = []
}

struct LevelProgress {
    let level: Int
    let xpIntoLevel: Int
    let xpForThisLevel: Int
    let totalXP: Int

    var progress: Double {
        xpForThisLevel == 0 ? 0 : Double(xpIntoLevel) / Double(xpForThisLevel)
    }
    var xpToNext: Int { max(0, xpForThisLevel - xpIntoLevel) }
}

enum LevelSystem {
    /// XP required to advance from `level` to `level + 1`.
    static func xpRequirement(forLevel level: Int) -> Int {
        100 + (level - 1) * 40
    }

    static func progress(forXP totalXP: Int) -> LevelProgress {
        var level = 1
        var remaining = totalXP
        while remaining >= xpRequirement(forLevel: level) {
            remaining -= xpRequirement(forLevel: level)
            level += 1
        }
        return LevelProgress(level: level, xpIntoLevel: remaining, xpForThisLevel: xpRequirement(forLevel: level), totalXP: totalXP)
    }

    enum XP {
        static let completeExercise = 10
        static let completeFullDay = 25
        static let hydrationGoal = 5
        static let sleepCheckIn = 15
        static let streakDayBonus = 8
    }
}

enum BadgeRequirement: Hashable {
    case streak(Int)
    case totalWorkouts(Int)
    case weeklyGoalHits(Int)
    case level(Int)
}

struct Badge: Identifiable, Hashable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let requirement: BadgeRequirement
}

enum BadgeLibrary {
    static let all: [Badge] = [
        Badge(id: "first-step", name: "First Step", description: "Log your very first workout.", icon: "flag.fill", requirement: .totalWorkouts(1)),
        Badge(id: "streak-3", name: "Warming Up", description: "Reach a 3-day streak.", icon: "flame", requirement: .streak(3)),
        Badge(id: "streak-7", name: "Locked In", description: "Reach a 7-day streak.", icon: "flame.fill", requirement: .streak(7)),
        Badge(id: "streak-30", name: "Unbreakable", description: "Reach a 30-day streak.", icon: "bolt.fill", requirement: .streak(30)),
        Badge(id: "workouts-10", name: "Getting Serious", description: "Log 10 total workouts.", icon: "10.circle.fill", requirement: .totalWorkouts(10)),
        Badge(id: "workouts-50", name: "Half Century", description: "Log 50 total workouts.", icon: "50.circle.fill", requirement: .totalWorkouts(50)),
        Badge(id: "workouts-100", name: "Centurion", description: "Log 100 total workouts.", icon: "100.circle.fill", requirement: .totalWorkouts(100)),
        Badge(id: "weekly-4", name: "Goal Getter", description: "Hit your weekly goal 4 times.", icon: "target", requirement: .weeklyGoalHits(4)),
        Badge(id: "weekly-12", name: "Consistency Machine", description: "Hit your weekly goal 12 times.", icon: "checkmark.seal.fill", requirement: .weeklyGoalHits(12)),
        Badge(id: "level-5", name: "Rising Fast", description: "Reach level 5.", icon: "arrow.up.circle.fill", requirement: .level(5)),
        Badge(id: "level-10", name: "Forged", description: "Reach level 10.", icon: "star.circle.fill", requirement: .level(10)),
        Badge(id: "level-20", name: "Elite Form", description: "Reach level 20.", icon: "crown.fill", requirement: .level(20)),
    ]

    static func byId(_ id: String) -> Badge? { all.first { $0.id == id } }
}
