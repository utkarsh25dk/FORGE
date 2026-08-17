import SwiftUI

struct AddWorkoutSheet: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.forge) private var forge
    @Environment(\.dismiss) private var dismiss

    var editingEntry: WorkoutEntry?
    var initialDate: Date
    var initialCategory: WorkoutCategory?

    @State private var name: String = ""
    @State private var category: WorkoutCategory = .other
    @State private var date: Date
    @State private var sets: Int = 3
    @State private var reps: Int = 10
    @State private var weight: Double = 0
    @State private var notes: String = ""

    init(editingEntry: WorkoutEntry? = nil, initialDate: Date = Date(), initialCategory: WorkoutCategory? = nil) {
        self.editingEntry = editingEntry
        self.initialDate = initialDate
        self.initialCategory = initialCategory
        _date = State(initialValue: editingEntry?.date ?? initialDate)
    }

    private var isEditing: Bool { editingEntry != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section("Exercise") {
                    TextField("e.g. Barbell Squat", text: $name)
                        .onChange(of: name) { _, newValue in
                            if editingEntry == nil {
                                category = TrainCategorization.autoCategorize(newValue)
                            }
                        }
                    Picker("Category", selection: $category) {
                        ForEach(WorkoutCategory.browsable) { cat in
                            Text(cat.rawValue).tag(cat)
                        }
                    }
                }

                Section("Sets · Reps · Weight") {
                    Stepper("Sets: \(sets)", value: $sets, in: 1...10)
                    Stepper("Reps: \(reps)", value: $reps, in: 1...50)
                    HStack {
                        Text("Weight (\(appState.userData.unitSystem.weightUnit))")
                        Spacer()
                        TextField("0", value: $weight, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                }

                Section("Schedule") {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }

                Section("Notes") {
                    TextField("Optional notes", text: $notes, axis: .vertical)
                        .lineLimit(2...4)
                }
            }
            .navigationTitle(isEditing ? "Edit Workout" : "Add Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }.disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                if let entry = editingEntry {
                    name = entry.name
                    category = entry.category
                    sets = entry.sets ?? 3
                    reps = entry.reps ?? 10
                    weight = entry.weight ?? 0
                    notes = entry.notes ?? ""
                } else if let initialCategory {
                    category = initialCategory
                }
            }
        }
    }

    private func save() {
        if var entry = editingEntry {
            entry.name = name
            entry.category = category
            entry.date = date.startOfDay
            entry.sets = sets
            entry.reps = reps
            entry.weight = weight
            entry.notes = notes.isEmpty ? nil : notes
            appState.updateEntry(entry)
        } else {
            let entry = WorkoutEntry(
                name: name, category: category, subgroup: nil, kind: .strength, date: date.startOfDay,
                sets: sets, reps: reps, weight: weight, notes: notes.isEmpty ? nil : notes
            )
            appState.addEntry(entry)
        }
        dismiss()
    }
}
