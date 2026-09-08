import Foundation

// MARK: - Dumbbell inventory

/// Which dumbbells the user actually owns.
///
/// "I have dumbbells" isn't enough to program with — a pair of 5s and a pair of
/// 50s support completely different work. Weights are stored in the unit the
/// user picked them in, because someone with 20 kg bells doesn't think of them
/// as 44 lb ones.
struct DumbbellInventory: Codable, Hashable {
    var unit: WeightUnit = .pounds
    /// Individual dumbbell weights owned, ascending.
    var weights: [Double] = []

    var isEmpty: Bool { weights.isEmpty }
    var heaviest: Double? { weights.max() }
    var lightest: Double? { weights.min() }

    /// Adjustable dumbbells are usually described by their top weight, so a
    /// single very heavy entry is treated as a range rather than one fixed pair.
    var summary: String {
        guard let lo = lightest, let hi = heaviest else { return "None selected" }
        if weights.count == 1 { return "\(fmt(lo)) \(unit.short)" }
        return "\(fmt(lo))–\(fmt(hi)) \(unit.short) · \(weights.count) pairs"
    }

    private func fmt(_ v: Double) -> String {
        v == v.rounded() ? String(Int(v)) : String(format: "%.1f", v)
    }

    /// The options offered in the picker. Common commercial increments rather
    /// than an open number field, which is faster to answer and less error-prone.
    static func options(for unit: WeightUnit) -> [Double] {
        switch unit {
        case .pounds:
            return [2.5, 5, 8, 10, 12, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 70, 80, 90, 100]
        case .kilograms:
            return [1, 2, 2.5, 4, 5, 6, 7.5, 8, 10, 12, 12.5, 15, 17.5, 20, 22.5, 25, 30, 35, 40]
        }
    }
}

enum WeightUnit: String, Codable, CaseIterable, Hashable {
    case pounds, kilograms
    var short: String { self == .pounds ? "lb" : "kg" }
    var label: String { self == .pounds ? "Pounds (lb)" : "Kilograms (kg)" }
}

// MARK: - Training answers

enum TrainingExperience: String, Codable, CaseIterable, Hashable, Identifiable {
    case new, returning, consistent
    var id: String { rawValue }
    var label: String {
        switch self {
        case .new: return "New to this"
        case .returning: return "Coming back after a break"
        case .consistent: return "Training consistently"
        }
    }
    var detail: String {
        switch self {
        case .new: return "Little or no structured training before"
        case .returning: return "You've trained before but not recently"
        case .consistent: return "Training most weeks already"
        }
    }
    var suggestedLevel: ProgramLevel {
        switch self {
        case .new: return .beginner
        case .returning: return .beginner
        case .consistent: return .intermediate
        }
    }
}

enum TrainingGoal: String, Codable, CaseIterable, Hashable, Identifiable {
    case strength, muscle, endurance, general, mobility
    var id: String { rawValue }
    var label: String {
        switch self {
        case .strength: return "Get stronger"
        case .muscle: return "Build muscle"
        case .endurance: return "Improve conditioning"
        case .general: return "General health"
        case .mobility: return "Move better"
        }
    }
    var detail: String {
        switch self {
        case .strength: return "Heavier lifts, lower reps, longer rest"
        case .muscle: return "Moderate reps, more total volume"
        case .endurance: return "Circuits, intervals and steady cardio"
        case .general: return "A balanced mix, nothing extreme"
        case .mobility: return "Range of motion, stretching and control"
        }
    }
    /// Categories a plan for this goal should draw from most.
    var emphasis: [WorkoutCategory] {
        switch self {
        case .strength: return [.upperBody, .lowerBody, .fullBody]
        case .muscle: return [.upperBody, .lowerBody, .core]
        case .endurance: return [.hiit, .cardio, .fullBody]
        case .general: return [.fullBody, .core, .cardio]
        case .mobility: return [.flexibility, .core, .recovery]
        }
    }
}

enum SessionLength: Int, Codable, CaseIterable, Hashable, Identifiable {
    case fifteen = 15, thirty = 30, fortyFive = 45, sixty = 60, ninety = 90
    var id: Int { rawValue }
    var label: String { "\(rawValue) min" }
    /// Roughly how many exercises fit, used when generating a day.
    var exerciseBudget: Int {
        switch self {
        case .fifteen: return 3
        case .thirty: return 4
        case .fortyFive: return 5
        case .sixty: return 6
        case .ninety: return 7
        }
    }
}

// MARK: - Profile

/// Everything the intake collects. Optional throughout so a half-finished
/// intake is a valid state rather than something to guard against everywhere.
struct TrainingProfile: Codable, Hashable {
    var dumbbells: DumbbellInventory = DumbbellInventory()
    var experience: TrainingExperience? = nil
    /// Sessions per week the user manages now — the honest baseline.
    var currentSessionsPerWeek: Int? = nil
    /// Sessions per week they're aiming for.
    var targetSessionsPerWeek: Int? = nil
    var sessionLength: SessionLength? = nil
    var goal: TrainingGoal? = nil
    var completedAt: Date? = nil

    var isComplete: Bool {
        experience != nil && currentSessionsPerWeek != nil
            && targetSessionsPerWeek != nil && sessionLength != nil && goal != nil
    }

    /// How far through the intake the user is, for a progress indicator.
    var answeredCount: Int {
        [experience != nil, currentSessionsPerWeek != nil, targetSessionsPerWeek != nil,
         sessionLength != nil, goal != nil].filter { $0 }.count
    }
    static let questionCount = 5

    /// A target more than two sessions above the current habit is where people
    /// overcommit and quit, so plans are built against a realistic step up
    /// rather than the aspiration.
    var realisticSessionsPerWeek: Int {
        guard let target = targetSessionsPerWeek else { return 3 }
        guard let current = currentSessionsPerWeek else { return target }
        return min(target, current + 2)
    }
}
