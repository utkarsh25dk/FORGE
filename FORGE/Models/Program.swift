import Foundation

// MARK: - Level

enum ProgramLevel: String, Codable, CaseIterable, Hashable {
    case beginner, intermediate, advanced

    var label: String {
        switch self {
        case .beginner: return "Beginner"
        case .intermediate: return "Intermediate"
        case .advanced: return "Advanced"
        }
    }

    var icon: String {
        switch self {
        case .beginner: return "circle.righthalf.filled"
        case .intermediate: return "circle.grid.2x2.fill"
        case .advanced: return "flame.fill"
        }
    }
}

// MARK: - Slot

/// One prescribed exercise inside a program day. References an `ExerciseLibrary`
/// template by id; any field left `nil` falls back to that template's own default,
/// so a program only spells out what it actually changes.
struct ProgramSlot: Hashable {
    let exerciseId: String
    var sets: Int? = nil
    var reps: Int? = nil
    var holdSec: Int? = nil
    var durationMin: Int? = nil

    var template: ExerciseTemplate? { ExerciseLibrary.byId(exerciseId) }
}

// MARK: - Day

struct ProgramDay: Hashable {
    let title: String
    /// `nil` on rest days, which carry no slots.
    let focus: WorkoutCategory?
    var slots: [ProgramSlot] = []

    var isRest: Bool { slots.isEmpty }
}

// MARK: - Progression

/// How one week differs from the program's base week. Deltas are additive and
/// applied to every slot in the week — the mechanism behind "week 2 adds a set".
struct WeekProgression: Hashable {
    let label: String
    let note: String
    var setsDelta: Int = 0
    var repsDelta: Int = 0
    var holdDeltaSec: Int = 0
    var durationDeltaMin: Int = 0
}

// MARK: - Program

/// A multi-week training plan, authored as one base week plus a progression rule
/// per week. A 4-week program is therefore 7 authored days, not 28 — and the
/// progression stays legible instead of being buried in duplicated day data.
struct Program: Identifiable, Hashable {
    let id: String
    let name: String
    let tagline: String
    let summary: String
    let level: ProgramLevel
    let equipment: String
    /// Exactly one week of days; repeated once per entry in `weeks`.
    let weekPattern: [ProgramDay]
    let weeks: [WeekProgression]

    var daysPerWeek: Int { weekPattern.count }
    var totalDays: Int { weekPattern.count * weeks.count }
    var trainingDaysPerWeek: Int { weekPattern.filter { !$0.isRest }.count }
    var weekCount: Int { weeks.count }

    /// Reads better than a bare "None" in the equipment caption.
    var equipmentLabel: String {
        equipment.caseInsensitiveCompare("none") == .orderedSame ? "No equipment" : equipment
    }

    /// Resolves the day at a zero-based index into the full run, applying that
    /// week's progression deltas. Returns `nil` past the end of the program.
    func day(at index: Int) -> ResolvedProgramDay? {
        guard index >= 0, index < totalDays, !weekPattern.isEmpty else { return nil }
        let weekIndex = index / weekPattern.count
        let dayIndex = index % weekPattern.count
        guard weekIndex < weeks.count else { return nil }

        let base = weekPattern[dayIndex]
        let progression = weeks[weekIndex]

        let slots = base.slots.map { slot -> ProgramSlot in
            guard let template = slot.template else { return slot }
            var resolved = slot
            // Only nudge a dimension the exercise actually uses, and never below 1.
            if let s = slot.sets ?? template.sets {
                resolved.sets = max(1, s + progression.setsDelta)
            }
            if let r = slot.reps ?? template.reps {
                resolved.reps = max(1, r + progression.repsDelta)
            }
            if let h = slot.holdSec ?? template.holdSec {
                resolved.holdSec = max(5, h + progression.holdDeltaSec)
            }
            if let d = slot.durationMin ?? template.durationMin {
                resolved.durationMin = max(1, d + progression.durationDeltaMin)
            }
            return resolved
        }

        return ResolvedProgramDay(
            dayIndex: index,
            weekNumber: weekIndex + 1,
            dayOfWeek: dayIndex + 1,
            title: base.title,
            focus: base.focus,
            slots: slots,
            progression: progression
        )
    }
}

/// A program day with its week's progression already folded in.
struct ResolvedProgramDay: Hashable, Identifiable {
    let dayIndex: Int
    let weekNumber: Int
    let dayOfWeek: Int
    let title: String
    let focus: WorkoutCategory?
    let slots: [ProgramSlot]
    let progression: WeekProgression

    var id: Int { dayIndex }
    var isRest: Bool { slots.isEmpty }
    var dayNumber: Int { dayIndex + 1 }
}

// MARK: - Enrollment

/// A user's run through a program. Persisted in `UserData`; day completion is
/// tracked by index so it survives the user shifting days around.
struct ProgramEnrollment: Codable, Hashable, Identifiable {
    var id: UUID = UUID()
    var programId: String
    var startDate: Date
    var completedDayIndices: Set<Int> = []
    var isActive: Bool = true
    var completedAt: Date? = nil

    var program: Program? { ProgramLibrary.byId(programId) }

    /// The day the user is currently on — the lowest index not yet completed.
    var currentDayIndex: Int {
        guard let total = program?.totalDays else { return 0 }
        for i in 0..<total where !completedDayIndices.contains(i) { return i }
        return total
    }

    var isFinished: Bool {
        guard let total = program?.totalDays else { return false }
        return completedDayIndices.count >= total
    }

    var progress: Double {
        guard let total = program?.totalDays, total > 0 else { return 0 }
        return Double(completedDayIndices.count) / Double(total)
    }
}
