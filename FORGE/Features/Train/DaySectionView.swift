import SwiftUI

struct DaySectionView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.forge) private var forge
    var date: Date
    var label: String

    @State private var editingEntry: WorkoutEntry?
    @State private var showAdd = false
    @State private var showCopySheet = false
    @State private var showSaveTemplate = false
    @State private var showLiveWorkout = false

    var body: some View {
        let entries = appState.sortedEntries(on: date)
        let realEntries = entries.filter { !$0.isWarmUp && !$0.isCoolDown }

        VStack(alignment: .leading, spacing: Space.sm) {
            HStack {
                Text(label).font(.forgeHeadingMedium(17)).foregroundStyle(forge.textPrimary)
                Spacer()
                if !realEntries.isEmpty {
                    Menu {
                        Button("Copy to another day", systemImage: "doc.on.doc") { showCopySheet = true }
                        Button("Save as template", systemImage: "square.and.arrow.down") { showSaveTemplate = true }
                    } label: {
                        Image(systemName: "ellipsis.circle").foregroundStyle(forge.textSecondary)
                            .frame(width: 44, height: 44)
                    }
                }
                Button {
                    showAdd = true
                } label: {
                    Image(systemName: "plus.circle.fill").foregroundStyle(forge.accent)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
            }

            if entries.isEmpty {
                Text("Nothing planned yet.")
                    .font(.forgeCaption())
                    .foregroundStyle(forge.textTertiary)
                    .padding(.vertical, Space.sm)
            } else {
                VStack(spacing: 2) {
                    ForEach(entries) { entry in
                        WorkoutRow(entry: entry) { editingEntry = entry }
                        if entry.id != entries.last?.id {
                            Divider().background(forge.divider)
                        }
                    }
                }

                if realEntries.contains(where: { !$0.isCompleted }) {
                    Button {
                        showLiveWorkout = true
                    } label: {
                        Label("Start Workout", systemImage: "play.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .forgeGlassPrimary()
                    .padding(.top, Space.xs)
                }
            }
        }
        .forgeCard()
        .sheet(isPresented: $showAdd) {
            AddWorkoutSheet(initialDate: date)
        }
        .sheet(item: $editingEntry) { entry in
            AddWorkoutSheet(editingEntry: entry, initialDate: date)
        }
        .sheet(isPresented: $showCopySheet) {
            CopyDaySheet(sourceDate: date)
        }
        .sheet(isPresented: $showSaveTemplate) {
            SaveTemplateSheet(sourceDate: date)
        }
        .fullScreenCover(isPresented: $showLiveWorkout) {
            LiveWorkoutView(date: date)
        }
    }
}
