import SwiftUI

struct ExerciseListView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.forge) private var forge
    var category: WorkoutCategory
    var subgroup: String

    @State private var selected: ExerciseTemplate?
    @State private var showAddCustom = false

    private var libraryExercises: [ExerciseTemplate] {
        ExerciseLibrary.exercises(category: category, subgroup: subgroup)
            .filter { !appState.userData.avoidExerciseIds.contains($0.id) }
    }
    private var customEntries: [CustomExerciseEntry] {
        appState.customExercises(category: category, subgroup: subgroup)
    }
    private var hiddenCount: Int {
        ExerciseLibrary.exercises(category: category, subgroup: subgroup).count - libraryExercises.count
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Space.md) {
                ForEach(libraryExercises) { template in
                    exerciseRow(template, isCustom: false)
                }
                if !customEntries.isEmpty {
                    Text("Your Additions")
                        .font(.forgeCaption())
                        .foregroundStyle(forge.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, Space.sm)
                    ForEach(customEntries) { entry in
                        exerciseRow(entry.asTemplate, isCustom: true, customEntry: entry)
                    }
                }
                if hiddenCount > 0 {
                    Text("\(hiddenCount) exercise(s) hidden — on your avoid list.")
                        .font(.forgeCaption())
                        .foregroundStyle(forge.textTertiary)
                }

                Button {
                    showAddCustom = true
                } label: {
                    Label("Add Your Own Exercise", systemImage: "plus.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .forgeGlassSecondary()
                .padding(.top, Space.sm)
            }
            .padding(Space.lg)
        }
        .scrollIndicators(.hidden)
        .forgeScreenBackground()
        .navigationTitle(subgroup)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showAddCustom = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(item: $selected) { template in
            ExerciseDetailSheet(template: template)
        }
        .sheet(isPresented: $showAddCustom) {
            AddCustomExerciseSheet(category: category, subgroup: subgroup)
        }
    }

    @ViewBuilder
    private func exerciseRow(_ template: ExerciseTemplate, isCustom: Bool, customEntry: CustomExerciseEntry? = nil) -> some View {
        HStack(spacing: Space.md) {
            Button {
                selected = template
            } label: {
                HStack(spacing: Space.md) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text(template.name).font(.forgeBodySemibold(16)).foregroundStyle(forge.textPrimary)
                            if isCustom {
                                Text("CUSTOM")
                                    .font(.forgeCaption(10))
                                    .foregroundStyle(forge.textSecondary)
                                    .padding(.horizontal, 6).padding(.vertical, 2)
                                    .background(Capsule().stroke(forge.surfaceBorder, lineWidth: 1))
                            } else if appState.isNewForYou(template) {
                                Text("NEW")
                                    .font(.forgeCaption(10))
                                    .foregroundStyle(forge.onAccent)
                                    .padding(.horizontal, 6).padding(.vertical, 2)
                                    .background(Capsule().fill(forge.accent))
                            }
                        }
                        Text(template.kind.fieldSummary).font(.forgeCaption()).foregroundStyle(forge.textSecondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right").foregroundStyle(forge.textTertiary).font(.system(size: 13, weight: .semibold))
                }
            }
            .buttonStyle(.plain)

            if let customEntry {
                Button {
                    appState.deleteCustomExercise(customEntry)
                } label: {
                    Image(systemName: "xmark.circle.fill")
                }
                .buttonStyle(ForgeDestructiveIconButtonStyle())
            }
        }
        .forgeCard(padding: Space.md, cornerRadius: Radius.md)
    }
}
