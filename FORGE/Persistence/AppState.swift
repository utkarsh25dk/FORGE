import Foundation
import SwiftUI
import WidgetKit

enum DayStatus {
    case worked, rest, missed, none

    /// Distinct hue per status so the calendar reads at a glance. "Today" still
    /// gets its own accent ring on top of this fill, applied at the call site.
    func color(_ forge: ForgeColors) -> Color? {
        switch self {
        case .worked: return forge.dayWorked
        case .rest: return forge.dayRest
        case .missed: return forge.danger
        case .none: return nil
        }
    }
}

@MainActor
final class AppState: ObservableObject {
    @Published var userData: UserData {
        didSet {
            Store.saveUserData(userData)
            updateWidgetSnapshot()
        }
    }
    @Published var toast: String? = nil

    let auth: AuthManager

    init(auth: AuthManager) {
        self.auth = auth
        if let account = auth.currentAccount, let loaded = Store.loadUserData(accountId: account.id) {
            userData = loaded
        } else if let account = auth.currentAccount {
            userData = .fresh(accountId: account.id, characterName: account.displayName)
        } else {
            userData = .fresh(accountId: "guest", characterName: "Guest")
        }
        syncPendingWidgetHydration()
        updateWidgetSnapshot()
    }

    func reload() {
        guard let account = auth.currentAccount else { return }
        userData = Store.loadUserData(accountId: account.id) ?? .fresh(accountId: account.id, characterName: account.displayName)
    }

    // MARK: - Widget

    private func updateWidgetSnapshot() {
        let today = checkIn(on: Date())
        let snapshot = WidgetSnapshot(
            streak: currentStreak,
            weeklyWorked: weeklyWorkedDays(),
            weeklyGoal: userData.weeklyGoal,
            hydrationCount: today.hydrationCount,
            hydrationGoal: DailyCheckIn.hydrationGoal,
            sleepQuality: today.sleepQuality,
            sleepHours: today.sleepHours,
            sleepConfirmed: today.sleepConfirmed,
            pendingHydrationTaps: 0,
            updatedAt: Date()
        )
        WidgetBridge.write(snapshot)
        WidgetCenter.shared.reloadAllTimelines()
    }

    /// Folds glasses tapped in from the widget's "+" button (queued in the App Group while this
    /// app wasn't running) into a real check-in. Call before anything else can trigger a snapshot
    /// rewrite, or the pending count gets cleared without ever being applied.
    func syncPendingWidgetHydration() {
        let snapshot = WidgetBridge.read()
        guard snapshot.pendingHydrationTaps > 0 else { return }
        let newCount = min(DailyCheckIn.hydrationGoal, checkIn(on: Date()).hydrationCount + snapshot.pendingHydrationTaps)
        setHydration(newCount, on: Date())
    }

    func notify(_ message: String) {
        showToast(message)
    }

    private func showToast(_ message: String) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            toast = message
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) { [weak self] in
            guard let self, self.toast == message else { return }
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                self.toast = nil
            }
        }
    }

    // MARK: - Entries

    func entries(on date: Date) -> [WorkoutEntry] {
        userData.entries.filter { $0.date.isSameDay(as: date) }
    }

    func sortedEntries(on date: Date) -> [WorkoutEntry] {
        entries(on: date).sorted { a, b in
            if a.isWarmUp != b.isWarmUp { return a.isWarmUp }
            if a.isCoolDown != b.isCoolDown { return b.isCoolDown }
            return a.createdAt < b.createdAt
        }
    }

    @discardableResult
    func addEntry(_ entry: WorkoutEntry) -> WorkoutEntry {
        userData.entries.append(entry)
        if !entry.isWarmUp && !entry.isCoolDown {
            ensureBookends(for: entry.date)
        }
        markExerciseSeen(slug(for: entry.name))
        return entry
    }

    func ensureBookends(for date: Date) {
        let dayEntries = entries(on: date)
        if !dayEntries.contains(where: { $0.isWarmUp }) {
            userData.entries.append(WorkoutEntry(
                name: "Warm-Up", category: .warmUp, subgroup: nil, kind: .session, date: date,
                durationMin: 5, intensity: 3, isWarmUp: true
            ))
        }
        if !dayEntries.contains(where: { $0.isCoolDown }) {
            userData.entries.append(WorkoutEntry(
                name: "Cool-Down", category: .coolDown, subgroup: nil, kind: .session, date: date,
                durationMin: 5, intensity: 2, isCoolDown: true
            ))
        }
    }

    func updateEntry(_ entry: WorkoutEntry) {
        guard let idx = userData.entries.firstIndex(where: { $0.id == entry.id }) else { return }
        userData.entries[idx] = entry
    }

    func deleteEntry(_ entry: WorkoutEntry) {
        userData.entries.removeAll { $0.id == entry.id }
    }

    func logSet(_ set: LoggedSet, for entry: WorkoutEntry) {
        guard let idx = userData.entries.firstIndex(where: { $0.id == entry.id }) else { return }
        userData.entries[idx].loggedSets.append(set)
    }

    func markComplete(_ entry: WorkoutEntry) {
        guard let idx = userData.entries.firstIndex(where: { $0.id == entry.id }), !userData.entries[idx].isCompleted else { return }
        toggleComplete(userData.entries[idx])
    }

    func toggleComplete(_ entry: WorkoutEntry) {
        guard let idx = userData.entries.firstIndex(where: { $0.id == entry.id }) else { return }
        let wasAllCompleteBefore = isDayFullyComplete(entry.date)
        let wasCompleted = userData.entries[idx].isCompleted
        userData.entries[idx].isCompleted.toggle()

        if !wasCompleted && userData.entries[idx].isCompleted {
            grantXP(LevelSystem.XP.completeExercise)
            recordPRIfNeeded(userData.entries[idx])
            if !wasAllCompleteBefore && isDayFullyComplete(entry.date) {
                grantXP(LevelSystem.XP.completeFullDay)
                showToast("Day complete! Bonus XP earned.")
            }
        }
        recomputeBadges()
        evaluateEveningReminder(on: entry.date)
    }

    private func isDayFullyComplete(_ date: Date) -> Bool {
        let dayEntries = entries(on: date)
        guard !dayEntries.isEmpty else { return false }
        return dayEntries.allSatisfy { $0.isCompleted }
    }

    // MARK: - Copy day / templates

    func copyDay(from source: Date, to target: Date) {
        let sourceEntries = entries(on: source).filter { !$0.isWarmUp && !$0.isCoolDown }
        for e in sourceEntries {
            var copy = e
            copy.id = UUID()
            copy.date = target
            copy.isCompleted = false
            copy.loggedSets = []
            copy.createdAt = Date()
            userData.entries.append(copy)
        }
        ensureBookends(for: target)
        showToast("Copied to \(target.formatted(.dateTime.month().day()))")
    }

    func saveTemplate(name: String, from date: Date) {
        let dayEntries = entries(on: date).filter { !$0.isWarmUp && !$0.isCoolDown }
        guard !dayEntries.isEmpty else { return }
        let template = DayTemplate(name: name, entries: dayEntries)
        userData.templates.append(template)
        showToast("Saved template \"\(name)\"")
    }

    func applyTemplate(_ template: DayTemplate, to date: Date) {
        for e in template.entries {
            var copy = e
            copy.id = UUID()
            copy.date = date
            copy.isCompleted = false
            copy.loggedSets = []
            copy.createdAt = Date()
            userData.entries.append(copy)
        }
        ensureBookends(for: date)
        showToast("Applied \"\(template.name)\"")
    }

    func deleteTemplate(_ template: DayTemplate) {
        userData.templates.removeAll { $0.id == template.id }
    }

    // MARK: - Check-ins

    func checkIn(on date: Date) -> DailyCheckIn {
        userData.checkIns.first { $0.date.isSameDay(as: date) } ?? DailyCheckIn(date: date.startOfDay)
    }

    private func upsertCheckIn(_ checkIn: DailyCheckIn) {
        if let idx = userData.checkIns.firstIndex(where: { $0.date.isSameDay(as: checkIn.date) }) {
            userData.checkIns[idx] = checkIn
        } else {
            userData.checkIns.append(checkIn)
        }
    }

    func setHydration(_ count: Int, on date: Date = Date()) {
        var c = checkIn(on: date)
        let wasGoalMet = c.hydrationCount >= DailyCheckIn.hydrationGoal
        c.hydrationCount = max(0, min(count, DailyCheckIn.hydrationGoal))
        upsertCheckIn(c)
        if !wasGoalMet && c.hydrationCount >= DailyCheckIn.hydrationGoal {
            grantXP(LevelSystem.XP.hydrationGoal)
        }
        evaluateEveningReminder(on: date)
    }

    func confirmSleep(quality: Int, hours: Double, on date: Date = Date()) {
        var c = checkIn(on: date)
        let alreadyConfirmed = c.sleepConfirmed
        c.sleepQuality = quality
        c.sleepHours = hours
        c.sleepConfirmed = true
        upsertCheckIn(c)
        if !alreadyConfirmed {
            grantXP(LevelSystem.XP.sleepCheckIn)
        }
        recomputeBadges()
        evaluateEveningReminder(on: date)
    }

    /// Cancels/reschedules the evening nudge based on today's hydration + sleep state.
    /// No-op for edits to past days — the reminder only ever concerns "today."
    func evaluateEveningReminder(on date: Date = Date()) {
        guard date.isSameDay(as: Date()) else { return }
        let today = checkIn(on: date)
        ReminderScheduler.evaluate(
            hydrationDone: today.hydrationCount >= DailyCheckIn.hydrationGoal,
            sleepDone: today.sleepConfirmed,
            workoutLoggedToday: dayStatus(for: date) != .none
        )
    }

    // MARK: - Measurements

    func addMeasurement(_ entry: BodyMeasurementEntry) {
        userData.measurements.append(entry)
        userData.measurements.sort { $0.date < $1.date }
    }

    func deleteMeasurement(_ entry: BodyMeasurementEntry) {
        userData.measurements.removeAll { $0.id == entry.id }
    }

    // MARK: - Avoid list

    func toggleAvoid(_ exerciseId: String) {
        if userData.avoidExerciseIds.contains(exerciseId) {
            userData.avoidExerciseIds.remove(exerciseId)
        } else {
            userData.avoidExerciseIds.insert(exerciseId)
        }
    }

    // MARK: - Custom exercises

    func customExercises(category: WorkoutCategory, subgroup: String) -> [CustomExerciseEntry] {
        userData.customExercises
            .filter { $0.category == category && $0.subgroup == subgroup }
            .sorted { $0.createdAt < $1.createdAt }
    }

    func addCustomExercise(_ entry: CustomExerciseEntry) {
        userData.customExercises.append(entry)
        notify("Added \(entry.name) to \(entry.subgroup)")
    }

    func deleteCustomExercise(_ entry: CustomExerciseEntry) {
        userData.customExercises.removeAll { $0.id == entry.id }
    }

    // MARK: - Suggest helpers

    func slug(for name: String) -> String {
        name.lowercased().replacingOccurrences(of: " ", with: "-")
    }

    func markExerciseSeen(_ id: String) {
        userData.seenExerciseIds.insert(id)
    }

    func isNewForYou(_ template: ExerciseTemplate) -> Bool {
        !userData.seenExerciseIds.contains(template.id)
    }

    func restWarning(for template: ExerciseTemplate) -> String? {
        guard template.kind == .strength else { return nil }
        let yesterday = Calendar.forge.date(byAdding: .day, value: -1, to: Date())!
        let recentSameSubgroup = userData.entries.filter {
            $0.subgroup == template.subgroup && $0.isCompleted &&
            ($0.date.isSameDay(as: Date()) || $0.date.isSameDay(as: yesterday))
        }
        if !recentSameSubgroup.isEmpty {
            return "You trained \(template.subgroup) recently — consider a lighter session or rest."
        }
        return nil
    }

    func progressionSuggestion(for template: ExerciseTemplate) -> String? {
        let past = userData.entries
            .filter { $0.name == template.name && $0.isCompleted }
            .sorted { $0.date > $1.date }
        guard let last = past.first else { return nil }
        switch template.kind {
        case .strength:
            guard let w = last.weight, let r = last.reps else { return nil }
            let unit = userData.unitSystem.weightUnit
            let nextWeight = w + (userData.unitSystem == .imperial ? 5 : 2)
            return "Last time: \(last.sets ?? 0)×\(r) @ \(Int(w)) \(unit). Try \(Int(nextWeight)) \(unit) today."
        case .cardio, .session:
            guard let d = last.durationMin else { return nil }
            return "Last time: \(d) min. Try \(d + 5) min today."
        case .hold:
            guard let s = last.holdSec else { return nil }
            return "Last time: \(s)s hold. Try \(s + 10)s today."
        case .distance:
            guard let dist = last.distanceMiles else { return nil }
            let unit = userData.unitSystem.distanceUnit
            return "Last time: \(String(format: "%.1f", dist)) \(unit). Try \(String(format: "%.1f", dist + 0.25)) \(unit) today."
        case .interval:
            guard let r = last.rounds else { return nil }
            return "Last time: \(r) rounds. Try \(r + 1) rounds today."
        }
    }

    private func recordPRIfNeeded(_ entry: WorkoutEntry) {
        guard entry.kind == .strength, let weight = entry.weight, let reps = entry.reps else { return }
        let existing = userData.personalRecords[entry.name]
        if existing == nil || weight > existing!.weight {
            userData.personalRecords[entry.name] = PersonalRecord(exerciseName: entry.name, weight: weight, reps: reps, date: entry.date)
        }
    }

    // MARK: - Day status / streaks

    func dayStatus(for date: Date) -> DayStatus {
        StreakCalculator.dayStatus(for: date, entries: userData.entries, accountCreatedAt: auth.currentAccount?.createdAt)
    }

    var currentStreak: Int {
        StreakCalculator.currentStreak(entries: userData.entries, accountCreatedAt: auth.currentAccount?.createdAt)
    }

    var missedYesterday: Bool {
        let yesterday = Calendar.forge.date(byAdding: .day, value: -1, to: Date().startOfDay)!
        return dayStatus(for: yesterday) == .missed
    }

    func weeklyWorkedDays(containing date: Date = Date()) -> Int {
        guard let week = Calendar.forge.dateInterval(of: .weekOfYear, for: date) else { return 0 }
        var count = 0
        var day = week.start
        while day < week.end {
            if dayStatus(for: day) == .worked { count += 1 }
            day = Calendar.forge.date(byAdding: .day, value: 1, to: day)!
        }
        return count
    }

    var weeklyProgress: Double {
        guard userData.weeklyGoal > 0 else { return 0 }
        return min(1, Double(weeklyWorkedDays()) / Double(userData.weeklyGoal))
    }

    private func weeklyGoalHitCount() -> Int {
        guard let firstDate = userData.entries.map({ $0.date }).min() else { return 0 }
        var count = 0
        var weekStart = Calendar.forge.dateInterval(of: .weekOfYear, for: firstDate)?.start ?? firstDate
        let now = Date()
        while weekStart <= now {
            if weeklyWorkedDays(containing: weekStart) >= userData.weeklyGoal { count += 1 }
            weekStart = Calendar.forge.date(byAdding: .weekOfYear, value: 1, to: weekStart)!
        }
        return count
    }

    var totalCompletedWorkouts: Int {
        userData.entries.filter { $0.isCompleted && !$0.isWarmUp && !$0.isCoolDown }.count
    }

    // MARK: - Gamification

    var levelProgress: LevelProgress { LevelSystem.progress(forXP: userData.game.xp) }

    private func grantXP(_ amount: Int) {
        userData.game.xp += amount
    }

    func recomputeBadges() {
        let level = levelProgress.level
        let streak = currentStreak
        let total = totalCompletedWorkouts
        let weeklyHits = weeklyGoalHitCount()
        for badge in BadgeLibrary.all where !userData.game.earnedBadgeIds.contains(badge.id) {
            let met: Bool
            switch badge.requirement {
            case .streak(let n): met = streak >= n
            case .totalWorkouts(let n): met = total >= n
            case .weeklyGoalHits(let n): met = weeklyHits >= n
            case .level(let n): met = level >= n
            }
            if met {
                userData.game.earnedBadgeIds.insert(badge.id)
                showToast("Badge earned: \(badge.name)")
            }
        }
    }

    // MARK: - Export / Import

    func exportJSON() -> Data? { Store.exportData(userData) }

    func importJSON(_ data: Data) -> Bool {
        guard var imported = Store.importData(data) else { return false }
        imported.accountId = userData.accountId
        userData = imported
        return true
    }
}
