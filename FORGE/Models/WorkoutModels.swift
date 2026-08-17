import Foundation

enum WorkoutCategory: String, Codable, CaseIterable, Identifiable, Hashable {
    case upperBody = "Upper Body"
    case lowerBody = "Lower Body"
    case fullBody = "Full Body"
    case core = "Core"
    case cardio = "Cardio"
    case hiit = "HIIT"
    case flexibility = "Flexibility & Mobility"
    case recovery = "Recovery"
    case activity = "Activity"
    case sports = "Sports"
    case warmUp = "Warm-Up"
    case coolDown = "Cool-Down"
    case other = "Other"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .upperBody: return "figure.strengthtraining.traditional"
        case .lowerBody: return "figure.strengthtraining.functional"
        case .fullBody: return "figure.mixed.cardio"
        case .core: return "figure.core.training"
        case .cardio: return "figure.run"
        case .hiit: return "bolt.fill"
        case .flexibility: return "figure.flexibility"
        case .recovery: return "leaf.fill"
        case .activity: return "figure.hiking"
        case .sports: return "sportscourt.fill"
        case .warmUp: return "flame"
        case .coolDown: return "snowflake"
        case .other: return "square.grid.2x2"
        }
    }

    /// Categories that appear as quick-start / suggest tiles (excludes bookend categories).
    static var browsable: [WorkoutCategory] {
        [.upperBody, .lowerBody, .fullBody, .core, .cardio, .hiit, .flexibility, .recovery, .activity, .sports]
    }
}

enum ExerciseKind: String, Codable {
    case strength   // sets, reps, weight
    case cardio     // duration, incline, intensity
    case hold       // hold time (sec), sets
    case distance   // distance, duration
    case interval   // rounds, work sec, rest sec, intensity
    case session    // duration, intensity

    var fieldSummary: String {
        switch self {
        case .strength: return "Sets · Reps · Weight"
        case .cardio: return "Duration · Incline · Intensity"
        case .hold: return "Hold Time · Sets"
        case .distance: return "Distance · Duration"
        case .interval: return "Rounds · Work/Rest · Intensity"
        case .session: return "Duration · Intensity"
        }
    }
}

struct LoggedSet: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var reps: Int
    var weight: Double
    var completedAt: Date = Date()
}

struct WorkoutEntry: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var category: WorkoutCategory
    var subgroup: String?
    var kind: ExerciseKind
    var date: Date

    // strength
    var sets: Int?
    var reps: Int?
    var weight: Double?        // canonical lbs

    // cardio
    var durationMin: Int?
    var inclinePercent: Int?
    var intensity: Int?        // 1-10 RPE, also used by interval/session

    // hold
    var holdSec: Int?

    // distance
    var distanceMiles: Double?

    // interval
    var rounds: Int?
    var workSec: Int?
    var restSec: Int?

    var isCompleted: Bool = false
    var isWarmUp: Bool = false
    var isCoolDown: Bool = false
    var notes: String?
    var loggedSets: [LoggedSet] = []
    var createdAt: Date = Date()

    var dayKey: DateComponents {
        Calendar.forge.dateComponents([.year, .month, .day], from: date)
    }
}

struct DayTemplate: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var entries: [WorkoutEntry]
    var createdAt: Date = Date()
}

extension Calendar {
    static let forge: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = 1
        return cal
    }()
}

extension Date {
    var startOfDay: Date { Calendar.forge.startOfDay(for: self) }
    func isSameDay(as other: Date) -> Bool { Calendar.forge.isDate(self, inSameDayAs: other) }
}
