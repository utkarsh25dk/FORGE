import Foundation

enum TrainCategorization {
    /// Matches a freeform exercise name against the library, falling back to keyword heuristics.
    static func autoCategorize(_ name: String) -> WorkoutCategory {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return .other }
        let lower = trimmed.lowercased()

        if let exact = ExerciseLibrary.all.first(where: { $0.name.lowercased() == lower }) {
            return exact.category
        }
        if let partial = ExerciseLibrary.all.first(where: { $0.name.lowercased().contains(lower) || lower.contains($0.name.lowercased()) }) {
            return partial.category
        }

        let keywordMap: [(keywords: [String], category: WorkoutCategory)] = [
            (["run", "jog", "treadmill", "bike", "cycle", "row", "elliptical", "stair"], .cardio),
            (["hike", "walk", "swim", "dance", "kayak"], .activity),
            (["stretch", "yoga", "mobility", "foam roll"], .flexibility),
            (["breath", "nap", "rest", "wind down", "wind-down"], .recovery),
            (["plank", "crunch", "sit-up", "situp", "ab ", "core", "russian twist"], .core),
            (["squat", "lunge", "leg", "calf", "glute", "hamstring", "quad"], .lowerBody),
            (["bench", "press", "curl", "row", "pull-up", "pullup", "chest", "back", "shoulder", "bicep", "tricep", "dip"], .upperBody),
            (["burpee", "circuit", "kettlebell", "deadlift", "clean", "snatch", "thruster"], .fullBody),
            (["hiit", "tabata", "emom", "interval"], .hiit),
            (["basketball", "soccer", "tennis", "boxing", "climb", "wrestl", "bjj", "muay"], .sports),
        ]
        for entry in keywordMap {
            if entry.keywords.contains(where: { lower.contains($0) }) {
                return entry.category
            }
        }
        return .other
    }
}
