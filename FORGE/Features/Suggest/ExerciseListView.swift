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
    /// Exercises the user's equipment covers.
    private var availableExercises: [ExerciseTemplate] {
        guard appState.isFilteringByEquipment else { return libraryExercises }
        return libraryExercises.filter { appState.canPerform($0) }
    }
    /// The rest — listed separately rather than hidden, so it's clear what
    /// the equipment setting is holding back and why.
    private var unavailableExercises: [ExerciseTemplate] {
        guard appState.isFilteringByEquipment else { return [] }
        return libraryExercises.filter { !appState.canPerform($0) }
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
                ForEach(availableExercises) { template in
                    exerciseRow(template, isCustom: false)
                }
                if availableExercises.isEmpty {
                    Text("Nothing here matches your equipment yet.")
                        .font(.forgeBody(14))
                        .foregroundStyle(forge.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, Space.sm)
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
                if !unavailableExercises.isEmpty {
                    VStack(alignment: .leading, spacing: Space.md) {
                        Text("Needs equipment you don't have")
                            .font(.forgeCaption())
                            .foregroundStyle(forge.textTertiary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, Space.sm)
                        ForEach(unavailableExercises) { template in
                            exerciseRow(template, isCustom: false)
                                .opacity(0.45)
                        }
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
                        HStack(spacing: 6) {
                            Image(systemName: template.level.icon)
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(forge.textTertiary)
                            Text("\(template.level.label) · \(template.kind.fieldSummary)")
                                .font(.forgeCaption())
                                .foregroundStyle(forge.textSecondary)
                                .lineLimit(1)
                        }
                        // Own line: inline, this badge wrapped mid-sentence and
                        // broke the row's alignment.
                        if appState.hasSetUpEquipment && !appState.canPerform(template) {
                            Text("Needs \(template.equipmentGroup.label.lowercased())")
                                .font(.forgeCaption(10))
                                .foregroundStyle(forge.warning)
                                .lineLimit(1)
                                .padding(.horizontal, 6).padding(.vertical, 2)
                                .background(Capsule().stroke(forge.warning.opacity(0.5), lineWidth: 1))
                                .padding(.top, 1)
                        }
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
