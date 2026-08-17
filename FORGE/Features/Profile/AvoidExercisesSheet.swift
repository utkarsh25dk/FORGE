import SwiftUI

struct AvoidExercisesSheet: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.forge) private var forge
    @Environment(\.dismiss) private var dismiss
    @State private var query = ""

    private var filtered: [ExerciseTemplate] {
        guard !query.isEmpty else { return ExerciseLibrary.all }
        return ExerciseLibrary.all.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filtered) { template in
                    let avoided = appState.userData.avoidExerciseIds.contains(template.id)
                    Button {
                        appState.toggleAvoid(template.id)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(template.name).font(.forgeBodyMedium(15)).foregroundStyle(forge.textPrimary)
                                Text("\(template.category.rawValue) · \(template.subgroup)").font(.forgeCaption(11)).foregroundStyle(forge.textSecondary)
                            }
                            Spacer()
                            Image(systemName: avoided ? "minus.circle.fill" : "minus.circle")
                                .foregroundStyle(avoided ? forge.danger : forge.textTertiary)
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .forgeScreenBackground()
            .searchable(text: $query, prompt: "Search exercises")
            .navigationTitle("Exercises to Avoid")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } }
            }
        }
    }
}
