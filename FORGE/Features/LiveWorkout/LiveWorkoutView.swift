import SwiftUI

struct LiveWorkoutView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.forge) private var forge
    @Environment(\.dismiss) private var dismiss
    @StateObject private var liveActivity = LiveWorkoutActivityManager()
    var date: Date

    @State private var orderedIds: [UUID] = []
    @State private var index = 0
    @State private var showTimer = false
    @State private var timerSeconds = 60
    @State private var repsInput = 10
    @State private var weightInput: Double = 0
    @State private var finished = false

    private var currentEntry: WorkoutEntry? {
        guard index >= 0, index < orderedIds.count else { return nil }
        return appState.userData.entries.first { $0.id == orderedIds[index] }
    }

    var body: some View {
        NavigationStack {
            Group {
                if finished || orderedIds.isEmpty || currentEntry == nil {
                    completionView
                } else if let entry = currentEntry {
                    VStack(spacing: 0) {
                        progressHeader(entry)
                        ScrollView {
                            VStack(spacing: Space.lg) {
                                exerciseCard(entry)
                                if showTimer {
                                    RestTimerView(remaining: timerSeconds, title: entry.kind == .strength ? "Rest" : "In Progress") {
                                        showTimer = false
                                        if entry.kind != .strength { appState.markComplete(entry) }
                                        liveActivity.update(exerciseName: entry.name, index: index, total: orderedIds.count, isResting: false, restEndDate: nil)
                                    }
                                }
                            }
                            .padding(Space.lg)
                        }
                        footer(entry)
                    }
                }
            }
            .forgeScreenBackground()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: { Image(systemName: "xmark") }
                }
            }
        }
        .onAppear {
            orderedIds = appState.sortedEntries(on: date).map { $0.id }
            syncInputs()
            if let entry = currentEntry {
                liveActivity.start(exerciseName: entry.name, index: index, total: orderedIds.count)
            }
        }
        .onDisappear {
            liveActivity.end()
        }
    }

    private func syncInputs() {
        guard let entry = currentEntry else { return }
        repsInput = entry.reps ?? 10
        weightInput = entry.weight ?? 0
        showTimer = false
        liveActivity.update(exerciseName: entry.name, index: index, total: orderedIds.count, isResting: false, restEndDate: nil)
    }

    private func progressHeader(_ entry: WorkoutEntry) -> some View {
        VStack(spacing: Space.sm) {
            HStack {
                Text("Step \(index + 1) of \(orderedIds.count)")
                    .font(.forgeCaption())
                    .foregroundStyle(forge.textSecondary)
                Spacer()
            }
            ProgressView(value: Double(index + 1), total: Double(max(orderedIds.count, 1)))
                .tint(forge.accent)
        }
        .padding(.horizontal, Space.lg)
        .padding(.top, Space.sm)
    }

    @ViewBuilder
    private func exerciseCard(_ entry: WorkoutEntry) -> some View {
        VStack(spacing: Space.lg) {
            VStack(spacing: 4) {
                CategoryIcon(systemName: entry.category.icon, size: 28)
                Text(entry.name).font(.forgeHeading(24)).foregroundStyle(forge.textPrimary).multilineTextAlignment(.center)
                if let subgroup = entry.subgroup {
                    Text(subgroup).font(.forgeCaption()).foregroundStyle(forge.textSecondary)
                }
            }

            if entry.kind == .strength {
                strengthLogger(entry)
            } else {
                otherKindPanel(entry)
            }
        }
        .frame(maxWidth: .infinity)
        .forgeCard()
    }

    @ViewBuilder
    private func strengthLogger(_ entry: WorkoutEntry) -> some View {
        let target = entry.sets ?? 3
        let done = entry.loggedSets.count
        VStack(spacing: Space.md) {
            Text("Set \(min(done + 1, target)) of \(target)")
                .font(.forgeHeadingMedium(18))
                .foregroundStyle(forge.textPrimary)

            Stepper("Reps: \(repsInput)", value: $repsInput, in: 1...50)
            HStack {
                Text("Weight (\(appState.userData.unitSystem.weightUnit))")
                Spacer()
                Stepper("\(Int(weightInput))", value: $weightInput, in: 0...1000, step: 5)
                    .fixedSize()
            }

            if done < target {
                Button {
                    appState.logSet(LoggedSet(reps: repsInput, weight: weightInput), for: entry)
                    if done + 1 >= target {
                        appState.markComplete(entry)
                    } else {
                        timerSeconds = 60
                        showTimer = true
                        liveActivity.update(exerciseName: entry.name, index: index, total: orderedIds.count, isResting: true, restEndDate: Date().addingTimeInterval(60))
                    }
                } label: {
                    Text("Log Set").frame(maxWidth: .infinity)
                }
                .forgeGlassPrimary()
            } else {
                Label("Exercise complete", systemImage: "checkmark.circle.fill")
                    .font(.forgeBodySemibold(15))
                    .foregroundStyle(forge.accent)
            }
        }
    }

    @ViewBuilder
    private func otherKindPanel(_ entry: WorkoutEntry) -> some View {
        VStack(spacing: Space.md) {
            Text(WorkoutEntryDisplay.summary(entry, unit: appState.userData.unitSystem))
                .font(.forgeBodyMedium(16))
                .foregroundStyle(forge.textSecondary)

            if entry.isCompleted {
                Label("Exercise complete", systemImage: "checkmark.circle.fill")
                    .font(.forgeBodySemibold(15))
                    .foregroundStyle(forge.accent)
            } else if !showTimer {
                Button {
                    timerSeconds = seconds(for: entry)
                    showTimer = true
                    liveActivity.update(exerciseName: entry.name, index: index, total: orderedIds.count, isResting: true, restEndDate: Date().addingTimeInterval(TimeInterval(timerSeconds)))
                } label: {
                    Text("Start").frame(maxWidth: .infinity)
                }
                .forgeGlassPrimary()

                Button {
                    appState.markComplete(entry)
                } label: {
                    Text("Mark Complete").frame(maxWidth: .infinity)
                }
                .forgeGlassSecondary()
            }
        }
    }

    private func seconds(for entry: WorkoutEntry) -> Int {
        switch entry.kind {
        case .hold: return entry.holdSec ?? 30
        case .cardio, .session: return (entry.durationMin ?? 5) * 60
        case .distance: return (entry.durationMin ?? 20) * 60
        case .interval: return (entry.workSec ?? 30) * (entry.rounds ?? 4)
        case .strength: return 60
        }
    }

    private func footer(_ entry: WorkoutEntry) -> some View {
        HStack(spacing: Space.md) {
            if index > 0 {
                Button {
                    index -= 1
                    syncInputs()
                } label: {
                    Text("Previous").frame(maxWidth: .infinity)
                }
                .forgeGlassSecondary()
            }
            Button {
                if index == orderedIds.count - 1 {
                    finished = true
                    liveActivity.end()
                } else {
                    index += 1
                    syncInputs()
                }
            } label: {
                Text(index == orderedIds.count - 1 ? "Finish" : "Next").frame(maxWidth: .infinity)
            }
            .forgeGlassPrimary()
        }
        .padding(Space.lg)
    }

    private var completionView: some View {
        VStack(spacing: Space.lg) {
            Spacer()
            Image(systemName: "checkmark.seal.fill").font(.system(size: 56)).foregroundStyle(forge.accent)
            Text("Workout Complete").font(.forgeHeading(26)).foregroundStyle(forge.textPrimary)
            Text("Nice work — your progress has been saved.")
                .font(.forgeBody(15)).foregroundStyle(forge.textSecondary)
            Spacer()
            Button {
                dismiss()
            } label: {
                Text("Done").frame(maxWidth: .infinity)
            }
            .forgeGlassPrimary()
        }
        .padding(Space.xl)
    }
}
