import Foundation

struct PersonalRecord: Codable, Hashable {
    var exerciseName: String
    var weight: Double
    var reps: Int
    var date: Date
}

struct UserData: Codable {
    var accountId: String
    var characterName: String
    var unitSystem: UnitSystem = .imperial
    var weeklyGoal: Int = 4
    var entries: [WorkoutEntry] = []
    var customExercises: [CustomExerciseEntry] = []
    var templates: [DayTemplate] = []
    var checkIns: [DailyCheckIn] = []
    var measurements: [BodyMeasurementEntry] = []
    var game: GameProfile = GameProfile()
    var avoidExerciseIds: Set<String> = []
    var onboardingComplete: Bool = false
    var seenExerciseIds: Set<String> = []
    var personalRecords: [String: PersonalRecord] = [:]

    static func fresh(accountId: String, characterName: String) -> UserData {
        UserData(accountId: accountId, characterName: characterName)
    }
}
