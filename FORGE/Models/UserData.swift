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
    var programEnrollments: [ProgramEnrollment] = []

    static func fresh(accountId: String, characterName: String) -> UserData {
        UserData(accountId: accountId, characterName: characterName)
    }

    /// Hand-written so a save file written by an older build still decodes when new
    /// fields are added. Swift's synthesized decoder ignores property defaults and
    /// throws `keyNotFound` for any absent key — and because `Store.loadUserData`
    /// swallows that with `try?`, a single missing key would silently reset the
    /// account to a fresh profile and drop every logged workout. Every field is
    /// decoded with `decodeIfPresent` and falls back to its default instead.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        // accountId / characterName are the only genuinely required keys: without an
        // account id the record can't be matched to an account at all.
        accountId = try c.decode(String.self, forKey: .accountId)
        characterName = try c.decodeIfPresent(String.self, forKey: .characterName) ?? "Guest"
        unitSystem = try c.decodeIfPresent(UnitSystem.self, forKey: .unitSystem) ?? .imperial
        weeklyGoal = try c.decodeIfPresent(Int.self, forKey: .weeklyGoal) ?? 4
        entries = try c.decodeIfPresent([WorkoutEntry].self, forKey: .entries) ?? []
        customExercises = try c.decodeIfPresent([CustomExerciseEntry].self, forKey: .customExercises) ?? []
        templates = try c.decodeIfPresent([DayTemplate].self, forKey: .templates) ?? []
        checkIns = try c.decodeIfPresent([DailyCheckIn].self, forKey: .checkIns) ?? []
        measurements = try c.decodeIfPresent([BodyMeasurementEntry].self, forKey: .measurements) ?? []
        game = try c.decodeIfPresent(GameProfile.self, forKey: .game) ?? GameProfile()
        avoidExerciseIds = try c.decodeIfPresent(Set<String>.self, forKey: .avoidExerciseIds) ?? []
        onboardingComplete = try c.decodeIfPresent(Bool.self, forKey: .onboardingComplete) ?? false
        seenExerciseIds = try c.decodeIfPresent(Set<String>.self, forKey: .seenExerciseIds) ?? []
        personalRecords = try c.decodeIfPresent([String: PersonalRecord].self, forKey: .personalRecords) ?? [:]
        programEnrollments = try c.decodeIfPresent([ProgramEnrollment].self, forKey: .programEnrollments) ?? []
    }

    init(accountId: String, characterName: String) {
        self.accountId = accountId
        self.characterName = characterName
    }
}
