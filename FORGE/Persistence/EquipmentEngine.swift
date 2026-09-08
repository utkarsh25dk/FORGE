import Foundation

/// Equipment ownership and the availability rules that follow from it.
extension AppState {

    var ownedEquipment: Set<EquipmentGroup> { userData.ownedEquipment }

    /// Whether the user has told us anything yet. Before they have, nothing is
    /// filtered — an empty set means "not set up", not "owns nothing".
    var hasSetUpEquipment: Bool { !userData.ownedEquipment.isEmpty }

    var isFilteringByEquipment: Bool {
        userData.filterByEquipment && hasSetUpEquipment
    }

    /// Everything the user's selections cover, including what those selections
    /// imply — an adjustable bench also counts as a flat bench.
    var effectiveEquipment: Set<EquipmentGroup> {
        var set = userData.ownedEquipment
        for group in userData.ownedEquipment { set.formUnion(group.implies) }
        return set
    }

    func owns(_ group: EquipmentGroup) -> Bool {
        group == .noneNeeded || effectiveEquipment.contains(group)
    }

    func toggleEquipment(_ group: EquipmentGroup) {
        guard group != .noneNeeded else { return }
        if userData.ownedEquipment.contains(group) {
            userData.ownedEquipment.remove(group)
        } else {
            userData.ownedEquipment.insert(group)
        }
    }

    func setEquipmentFilter(_ on: Bool) {
        userData.filterByEquipment = on
    }

    /// Can the user actually do this exercise with what they own? Exercises
    /// needing no equipment are always true, which is what makes a bodyweight-only
    /// setup still useful rather than empty.
    /// Every requirement must be met, not just the primary one — dumbbells alone
    /// don't make an Incline Dumbbell Press possible.
    func canPerform(_ template: ExerciseTemplate) -> Bool {
        template.requiredEquipment.isSubset(of: effectiveEquipment)
    }

    /// Applies the browser filter. Returns everything untouched when the user
    /// hasn't set equipment up or has the filter switched off.
    func applyingEquipmentFilter(_ templates: [ExerciseTemplate]) -> [ExerciseTemplate] {
        guard isFilteringByEquipment else { return templates }
        return templates.filter { canPerform($0) }
    }

    /// How many exercises the current equipment unlocks, for the setup screen.
    func availableExerciseCount(for equipment: Set<EquipmentGroup>) -> Int {
        var effective = equipment
        for group in equipment { effective.formUnion(group.implies) }
        return ExerciseLibrary.all.filter { $0.requiredEquipment.isSubset(of: effective) }.count
    }

    var availableExerciseCount: Int { availableExerciseCount(for: userData.ownedEquipment) }
}
