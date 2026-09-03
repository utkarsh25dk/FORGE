import Foundation

/// Program enrollment, scheduling and day-completion, kept out of `AppState` proper
/// so the core state object stays readable.
extension AppState {

    // MARK: - Enrollment

    /// The one program the user is currently running, if any.
    var activeEnrollment: ProgramEnrollment? {
        userData.programEnrollments.first { $0.isActive && !$0.isFinished }
    }

    var activeProgram: Program? { activeEnrollment?.program }

    var finishedEnrollments: [ProgramEnrollment] {
        userData.programEnrollments.filter { $0.isFinished }.sorted { ($0.completedAt ?? .distantPast) > ($1.completedAt ?? .distantPast) }
    }

    func isEnrolled(in program: Program) -> Bool {
        activeEnrollment?.programId == program.id
    }

    /// Starts a program today. Only one runs at a time — starting a new one
    /// retires whatever was active, since two competing schedules help nobody.
    func enroll(in program: Program) {
        for i in userData.programEnrollments.indices where userData.programEnrollments[i].isActive {
            userData.programEnrollments[i].isActive = false
        }
        let enrollment = ProgramEnrollment(programId: program.id, startDate: Date().startOfDay)
        userData.programEnrollments.append(enrollment)
        showProgramToast("Started \(program.name)")
    }

    func leaveProgram() {
        guard let active = activeEnrollment else { return }
        for i in userData.programEnrollments.indices where userData.programEnrollments[i].id == active.id {
            userData.programEnrollments[i].isActive = false
        }
        showProgramToast("Left \(active.program?.name ?? "program")")
    }

    // MARK: - Today

    /// The day the user is up to. Deliberately driven by how many days they've
    /// finished rather than by the calendar — miss a week and you resume where you
    /// stopped instead of being marked six days behind.
    var currentProgramDay: ResolvedProgramDay? {
        guard let e = activeEnrollment, let p = e.program else { return nil }
        return p.day(at: e.currentDayIndex)
    }

    func isProgramDayComplete(_ index: Int) -> Bool {
        activeEnrollment?.completedDayIndices.contains(index) ?? false
    }

    /// Days already applied to the given date, used to stop a double-apply.
    func programEntries(on date: Date) -> [WorkoutEntry] {
        entries(on: date).filter { $0.programDayIndex != nil }
    }

    // MARK: - Applying a day

    /// Turns a resolved program day into real `WorkoutEntry` rows on `date`, so the
    /// rest of the app — Train, Live Workout, streaks, XP — treats it as any other
    /// planned day.
    @discardableResult
    func applyProgramDay(_ day: ResolvedProgramDay, to date: Date = Date()) -> Int {
        guard !day.isRest else { return 0 }
        var added = 0
        for slot in day.slots {
            guard let t = slot.template else { continue }
            var entry = WorkoutEntry(name: t.name, category: t.category, subgroup: t.subgroup, kind: t.kind, date: date.startOfDay)
            entry.programDayIndex = day.dayIndex
            switch t.kind {
            case .strength:
                entry.sets = slot.sets ?? t.sets
                entry.reps = slot.reps ?? t.reps
            case .cardio:
                entry.durationMin = slot.durationMin ?? t.durationMin
                entry.inclinePercent = t.inclinePercent
                entry.intensity = t.intensity
            case .hold:
                entry.sets = slot.sets ?? t.sets
                entry.holdSec = slot.holdSec ?? t.holdSec
            case .distance:
                entry.distanceMiles = t.distanceMiles
                entry.durationMin = slot.durationMin ?? t.durationMin
            case .interval:
                entry.rounds = t.rounds
                entry.workSec = t.workSec
                entry.restSec = t.restSec
                entry.intensity = t.intensity
            case .session:
                entry.durationMin = slot.durationMin ?? t.durationMin
                entry.intensity = t.intensity
            }
            userData.entries.append(entry)
            added += 1
        }
        ensureBookends(for: date)
        showProgramToast("Added \(day.title) — day \(day.dayNumber)")
        return added
    }

    // MARK: - Completion

    /// Marks a rest day done. Training days complete themselves once every entry
    /// applied from them is ticked off (see `syncProgramCompletion`).
    func completeProgramDay(_ index: Int) {
        guard let active = activeEnrollment,
              let i = userData.programEnrollments.firstIndex(where: { $0.id == active.id }),
              !userData.programEnrollments[i].completedDayIndices.contains(index) else { return }

        userData.programEnrollments[i].completedDayIndices.insert(index)

        if userData.programEnrollments[i].isFinished {
            userData.programEnrollments[i].completedAt = Date()
            userData.programEnrollments[i].isActive = false
            showProgramToast("\(active.program?.name ?? "Program") complete")
        }
    }

    /// Called after an entry is toggled: if every entry applied from a program day
    /// is now complete, tick that day off.
    func syncProgramCompletion(for date: Date) {
        guard activeEnrollment != nil else { return }
        let byDay = Dictionary(grouping: programEntries(on: date)) { $0.programDayIndex ?? -1 }
        for (dayIndex, dayEntries) in byDay where dayIndex >= 0 {
            if dayEntries.allSatisfy({ $0.isCompleted }) {
                completeProgramDay(dayIndex)
            }
        }
    }

    // MARK: - Toast

    /// `showToast` is private to AppState; programs route through `notify` instead.
    private func showProgramToast(_ message: String) { notify(message) }
}
