import SwiftUI

struct AddCustomExerciseSheet: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    var category: WorkoutCategory
    var subgroup: String

    @State private var name = ""
    @State private var kind: ExerciseKind = .strength
    @State private var equipment = ""

    private let allKinds: [ExerciseKind] = [.strength, .cardio, .hold, .distance, .interval, .session]

    var body: some View {
        NavigationStack {
            Form {
                Section("Exercise") {
                    TextField("e.g. Cable Crossover", text: $name)
                    TextField("Equipment (optional)", text: $equipment)
                }
                Section("Field type") {
                    Picker("Type", selection: $kind) {
                        ForEach(allKinds, id: \.self) { k in
                            Text(k.fieldSummary).tag(k)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }
                Section {
                    Text("This determines which fields show up when you log it — sets/reps/weight for lifts, duration/incline/intensity for cardio, and so on.")
                        .font(.forgeCaption())
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Custom Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func save() {
        let entry = CustomExerciseEntry(
            name: name.trimmingCharacters(in: .whitespaces),
            category: category,
            subgroup: subgroup,
            kind: kind,
            equipment: equipment.trimmingCharacters(in: .whitespaces).isEmpty ? "Custom" : equipment
        )
        appState.addCustomExercise(entry)
        dismiss()
    }
}
