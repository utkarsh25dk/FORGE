import Foundation

struct CustomExerciseEntry: Identifiable, Codable, Hashable {
    var id: String = UUID().uuidString
    var name: String
    var category: WorkoutCategory
    var subgroup: String
    var kind: ExerciseKind
    var equipment: String = "Custom"
    var createdAt: Date = Date()

    var asTemplate: ExerciseTemplate {
        ExerciseTemplate(
            id: "custom-\(id)", name: name, category: category, subgroup: subgroup, kind: kind,
            equipment: equipment, tip: "Your custom exercise — logged the way you set it up."
        )
    }
}
