import Foundation

/// Builds a program from the intake answers and the equipment the user owns.
///
/// The three built-in programs are fixed: they assume equipment you may not have
/// and a schedule that may not fit. This produces one shaped to the answers —
/// same `Program` type, so everything downstream (schedule view, home card,
/// progression, completion) works unchanged.
enum ProgramGenerator {

    /// Days of the week pattern, chosen so training days are spread out rather
    /// than stacked. Index 0 is day one of the week.
    private static func trainingDayPattern(sessions: Int) -> [Bool] {
        switch max(1, min(6, sessions)) {
        case 1: return [true, false, false, false, false, false, false]
        case 2: return [true, false, false, true, false, false, false]
        case 3: return [true, false, true, false, true, false, false]
        case 4: return [true, true, false, true, true, false, false]
        case 5: return [true, true, false, true, true, true, false]
        default: return [true, true, true, false, true, true, false]
        }
    }

    /// Rotates through the goal's emphasis categories so consecutive training
    /// days hit different things.
    private static func focusRotation(for goal: TrainingGoal, sessions: Int) -> [WorkoutCategory] {
        let emphasis = goal.emphasis
        guard !emphasis.isEmpty else { return [.fullBody] }
        return (0..<max(1, sessions)).map { emphasis[$0 % emphasis.count] }
    }

    /// Picks exercises for one day: only what the user can actually do, at or
    /// below their level, spread across subgroups so a day isn't five variations
    /// of the same movement.
    private static func pickExercises(
        category: WorkoutCategory,
        budget: Int,
        level: ProgramLevel,
        available: Set<EquipmentGroup>,
        avoid: Set<String>,
        alreadyUsed: inout Set<String>
    ) -> [ProgramSlot] {
        let allowedLevels: Set<ProgramLevel> = level == .beginner
            ? [.beginner]
            : (level == .intermediate ? [.beginner, .intermediate] : [.beginner, .intermediate, .advanced])

        var bySubgroup: [String: [ExerciseTemplate]] = [:]
        for t in ExerciseLibrary.all where t.category == category {
            guard t.requiredEquipment.isSubset(of: available),
                  allowedLevels.contains(t.level),
                  !avoid.contains(t.id) else { continue }
            bySubgroup[t.subgroup, default: []].append(t)
        }

        var picked: [ExerciseTemplate] = []
        // One pass per subgroup first, so coverage beats depth.
        for subgroup in ExerciseLibrary.subgroups(for: category) {
            guard picked.count < budget else { break }
            guard let candidates = bySubgroup[subgroup], !candidates.isEmpty else { continue }
            if let choice = candidates.first(where: { !alreadyUsed.contains($0.id) }) ?? candidates.first {
                picked.append(choice)
                alreadyUsed.insert(choice.id)
            }
        }
        // Then top up from anywhere in the category if there's room left.
        if picked.count < budget {
            let rest = bySubgroup.values.flatMap { $0 }
                .filter { t in !picked.contains(where: { $0.id == t.id }) }
                .sorted { $0.id < $1.id }
            for t in rest where picked.count < budget {
                picked.append(t)
                alreadyUsed.insert(t.id)
            }
        }
        return picked.map { ProgramSlot(exerciseId: $0.id) }
    }

    /// Builds the program. Returns nil only when the profile is unanswered.
    static func generate(profile: TrainingProfile,
                         equipment: Set<EquipmentGroup>,
                         avoid: Set<String> = []) -> Program? {
        guard let goal = profile.goal,
              let experience = profile.experience,
              let length = profile.sessionLength else { return nil }

        var effective = equipment
        for g in equipment { effective.formUnion(g.implies) }

        let sessions = profile.realisticSessionsPerWeek
        let pattern = trainingDayPattern(sessions: sessions)
        let focuses = focusRotation(for: goal, sessions: sessions)
        let level = experience.suggestedLevel
        let budget = length.exerciseBudget

        var used: Set<String> = []
        var days: [ProgramDay] = []
        var focusIndex = 0

        for isTrainingDay in pattern {
            guard isTrainingDay else {
                days.append(ProgramDay(title: "Rest", focus: nil, slots: []))
                continue
            }
            let focus = focuses[focusIndex % focuses.count]
            focusIndex += 1
            let slots = pickExercises(category: focus, budget: budget, level: level,
                                      available: effective, avoid: avoid, alreadyUsed: &used)
            // A category with nothing available shouldn't produce an empty day
            // that silently reads as a rest day.
            if slots.isEmpty {
                var fallbackUsed = used
                let fallback = pickExercises(category: .fullBody, budget: budget, level: level,
                                             available: effective, avoid: avoid, alreadyUsed: &fallbackUsed)
                used = fallbackUsed
                days.append(ProgramDay(title: fallback.isEmpty ? "Rest" : "Full Body",
                                       focus: fallback.isEmpty ? nil : .fullBody,
                                       slots: fallback))
            } else {
                days.append(ProgramDay(title: focus.rawValue, focus: focus, slots: slots))
            }
        }

        return Program(
            id: "generated-\(goal.rawValue)-\(sessions)",
            name: "Your \(goal.label) Plan".replacingOccurrences(of: "Get stronger", with: "Strength"),
            tagline: "\(sessions) days a week · \(length.label) · built from your setup",
            summary: summary(profile: profile, goal: goal, sessions: sessions, length: length, level: level),
            level: level,
            equipment: equipmentSummary(effective),
            weekPattern: days,
            weeks: weeks(for: goal, experience: experience)
        )
    }

    private static func summary(profile: TrainingProfile, goal: TrainingGoal,
                                sessions: Int, length: SessionLength, level: ProgramLevel) -> String {
        var text = "Built from what you told us: \(goal.label.lowercased()), \(length.label) a session, "
        text += "using only the equipment you have. "
        if let target = profile.targetSessionsPerWeek, target > sessions {
            text += "You said you're aiming for \(target) days a week and currently manage "
            text += "\(profile.currentSessionsPerWeek ?? 0). This starts at \(sessions), because adding more than "
            text += "two sessions a week at once is where most people quit. Get \(sessions) consistent first, "
            text += "then rebuild the plan and it'll step up. "
        } else {
            text += "That's \(sessions) days a week, which matches what you said you can hold down. "
        }
        text += "Every exercise here is one you can actually do with what you own — nothing is listed "
        text += "that needs a bench you don't have."
        return text
    }

    private static func equipmentSummary(_ equipment: Set<EquipmentGroup>) -> String {
        let owned = EquipmentGroup.selectable.filter { equipment.contains($0) }
        return owned.isEmpty ? "No equipment" : owned.map(\.label).joined(separator: ", ")
    }

    /// Four weeks of progression, weighted toward what the goal actually needs.
    private static func weeks(for goal: TrainingGoal, experience: TrainingExperience) -> [WeekProgression] {
        switch goal {
        case .strength:
            return [
                WeekProgression(label: "Week 1 — Baseline", note: "Find working weights you can finish every set with."),
                WeekProgression(label: "Week 2 — Add a set", note: "Same weights, one more set per exercise.", setsDelta: 1),
                WeekProgression(label: "Week 3 — Slow it down", note: "Three counts on the lowering half of every rep.", setsDelta: 1, repsDelta: -2),
                WeekProgression(label: "Week 4 — Peak", note: "Heaviest week. If a day falls apart, drop a set and finish it.", setsDelta: 2),
            ]
        case .muscle:
            return [
                WeekProgression(label: "Week 1 — Baseline", note: "Moderate weights, clean form, note where each set ends."),
                WeekProgression(label: "Week 2 — More reps", note: "Same weights, two more reps per set.", repsDelta: 2),
                WeekProgression(label: "Week 3 — More volume", note: "An extra set on everything.", setsDelta: 1, repsDelta: 2),
                WeekProgression(label: "Week 4 — Peak", note: "The most total work of the block.", setsDelta: 1, repsDelta: 4),
            ]
        case .endurance:
            return [
                WeekProgression(label: "Week 1 — Baseline", note: "Finish every session without redlining."),
                WeekProgression(label: "Week 2 — Longer", note: "A few minutes more per session.", durationDeltaMin: 3),
                WeekProgression(label: "Week 3 — Denser", note: "More work in the same time.", repsDelta: 3, durationDeltaMin: 3),
                WeekProgression(label: "Week 4 — Peak", note: "Hardest week. Back off if sleep or appetite go.", setsDelta: 1, repsDelta: 3, durationDeltaMin: 5),
            ]
        case .general:
            return [
                WeekProgression(label: "Week 1 — Learn the shape", note: "Get through every day once. Chase attendance, not difficulty."),
                WeekProgression(label: "Week 2 — Settle in", note: "Same days, slightly more of each.", repsDelta: 2),
                WeekProgression(label: "Week 3 — Build", note: "One more set where it feels manageable.", setsDelta: 1, repsDelta: 2),
                WeekProgression(label: "Week 4 — Consolidate", note: "Repeat week 3 and make it feel routine.", setsDelta: 1, repsDelta: 2),
            ]
        case .mobility:
            return [
                WeekProgression(label: "Week 1 — Find the range", note: "Stop where the stretch first shows up."),
                WeekProgression(label: "Week 2 — Hold longer", note: "Ten more seconds on every hold.", holdDeltaSec: 10),
                WeekProgression(label: "Week 3 — Settle in", note: "Twenty seconds longer than week 1.", holdDeltaSec: 20),
                WeekProgression(label: "Week 4 — Deepen", note: "This is where connective tissue actually changes.", holdDeltaSec: 30, durationDeltaMin: 2),
            ]
        }
    }
}
