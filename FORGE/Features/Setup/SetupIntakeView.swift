import SwiftUI

/// The intake that a generated plan is built from. One question per screen so
/// each gets a real answer rather than being skimmed past in a long form.
struct SetupIntakeView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.forge) private var forge
    @Environment(\.dismiss) private var dismiss

    @State private var step = 0
    var startStep: Int? = nil
    @State private var generated: Program?

    private var profile: TrainingProfile { appState.userData.trainingProfile }
    private let lastStep = 6

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                progressBar
                ScrollView {
                    VStack(alignment: .leading, spacing: Space.lg) {
                        switch step {
                        case 0: equipmentStep
                        case 1: dumbbellStep
                        case 2: experienceStep
                        case 3: currentFrequencyStep
                        case 4: targetFrequencyStep
                        case 5: sessionLengthStep
                        default: goalStep
                        }
                    }
                    .padding(Space.lg)
                }
                .scrollIndicators(.hidden)
                footer
            }
            .forgeScreenBackground()
            .navigationTitle("Set up")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { if let s = startStep { step = s } }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }.foregroundStyle(forge.textSecondary)
                }
            }
            .sheet(item: $generated) { program in
                GeneratedPlanSheet(program: program) { dismiss() }
            }
        }
    }

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Rectangle().fill(forge.raised).frame(height: 3)
                Rectangle().fill(forge.accent)
                    .frame(width: geo.size.width * (Double(step + 1) / Double(lastStep + 1)), height: 3)
            }
        }
        .frame(height: 3)
    }

    // MARK: Steps

    private var equipmentStep: some View {
        VStack(alignment: .leading, spacing: Space.md) {
            question("What can you train with?", "Tap everything you have access to. Nothing here is required — plenty works with no equipment at all.")
            ForEach(EquipmentGroup.selectable) { group in
                selectRow(title: group.label, detail: group.detail, icon: group.icon,
                          selected: appState.userData.ownedEquipment.contains(group)) {
                    appState.toggleEquipment(group)
                }
            }
            Text("\(appState.availableExerciseCount) of \(ExerciseLibrary.all.count) exercises available with this")
                .font(.forgeCaption(12))
                .foregroundStyle(forge.accent)
                .padding(.top, 2)
        }
    }

    @ViewBuilder private var dumbbellStep: some View {
        if appState.userData.ownedEquipment.contains(.dumbbells) {
            VStack(alignment: .leading, spacing: Space.md) {
                question("Which dumbbells?", "A pair of 5s and a pair of 50s support very different training, so this changes what gets programmed.")
                Picker("Unit", selection: Binding(
                    get: { appState.userData.trainingProfile.dumbbells.unit },
                    set: { appState.setDumbbellUnit($0) }
                )) {
                    ForEach(WeightUnit.allCases, id: \.self) { Text($0.label).tag($0) }
                }
                .pickerStyle(.segmented)

                let unit = profile.dumbbells.unit
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 82), spacing: Space.sm)], spacing: Space.sm) {
                    ForEach(DumbbellInventory.options(for: unit), id: \.self) { w in
                        let on = profile.dumbbells.weights.contains(w)
                        Button { appState.toggleDumbbellWeight(w) } label: {
                            Text("\(w == w.rounded() ? String(Int(w)) : String(format: "%.1f", w)) \(unit.short)")
                                .font(.forgeBodyMedium(14))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, Space.sm)
                                .foregroundStyle(on ? forge.onAccent : forge.textPrimary)
                                .background(RoundedRectangle(cornerRadius: Radius.sm)
                                    .fill(on ? forge.accent : forge.raised))
                        }
                        .buttonStyle(.plain)
                    }
                }
                Text(profile.dumbbells.summary)
                    .font(.forgeCaption(12))
                    .foregroundStyle(forge.textSecondary)
            }
        } else {
            VStack(alignment: .leading, spacing: Space.md) {
                question("No dumbbells", "You didn't select dumbbells, so there's nothing to set here. Skip ahead.")
            }
        }
    }

    private var experienceStep: some View {
        VStack(alignment: .leading, spacing: Space.md) {
            question("Where are you starting from?", "This sets how demanding the plan is, and nothing else.")
            ForEach(TrainingExperience.allCases) { e in
                selectRow(title: e.label, detail: e.detail, icon: nil,
                          selected: profile.experience == e) { appState.setExperience(e) }
            }
        }
    }

    private var currentFrequencyStep: some View {
        VStack(alignment: .leading, spacing: Space.md) {
            question("How many days a week do you train now?", "Be honest rather than optimistic — this is the number the plan is built around.")
            ForEach(0...6, id: \.self) { n in
                selectRow(title: n == 0 ? "Not currently training" : "\(n) day\(n == 1 ? "" : "s") a week",
                          detail: nil, icon: nil,
                          selected: profile.currentSessionsPerWeek == n) { appState.setCurrentSessions(n) }
            }
        }
    }

    private var targetFrequencyStep: some View {
        VStack(alignment: .leading, spacing: Space.md) {
            question("How many would you like to train?", "If that's a big jump from where you are, the plan will start closer to your current habit and build up.")
            ForEach(1...6, id: \.self) { n in
                selectRow(title: "\(n) day\(n == 1 ? "" : "s") a week", detail: nil, icon: nil,
                          selected: profile.targetSessionsPerWeek == n) { appState.setTargetSessions(n) }
            }
            if let c = profile.currentSessionsPerWeek, let t = profile.targetSessionsPerWeek, t > c + 2 {
                Text("You're at \(c) and aiming for \(t). The plan will start at \(profile.realisticSessionsPerWeek) — jumping more than two days at once is where most people quit. Rebuild it once that's routine.")
                    .font(.forgeCaption(12))
                    .foregroundStyle(forge.warning)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var sessionLengthStep: some View {
        VStack(alignment: .leading, spacing: Space.md) {
            question("How long can a session be?", "This decides how many exercises land on each day.")
            ForEach(SessionLength.allCases) { l in
                selectRow(title: l.label, detail: "About \(l.exerciseBudget) exercises", icon: nil,
                          selected: profile.sessionLength == l) { appState.setSessionLength(l) }
            }
        }
    }

    private var goalStep: some View {
        VStack(alignment: .leading, spacing: Space.md) {
            question("What are you training for?", "This sets which parts of the library the plan draws from.")
            ForEach(TrainingGoal.allCases) { g in
                selectRow(title: g.label, detail: g.detail, icon: nil,
                          selected: profile.goal == g) { appState.setGoal(g) }
            }
        }
    }

    // MARK: Chrome

    private func question(_ title: String, _ detail: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.forgeHeading(24)).foregroundStyle(forge.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            Text(detail).font(.forgeBody(14)).foregroundStyle(forge.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.bottom, Space.sm)
    }

    private func selectRow(title: String, detail: String?, icon: String?,
                           selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: Space.md) {
                if let icon {
                    Image(systemName: icon).font(.system(size: 15, weight: .medium))
                        .foregroundStyle(selected ? forge.accent : forge.textTertiary).frame(width: 24)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.forgeBodySemibold(15)).foregroundStyle(forge.textPrimary)
                    if let detail {
                        Text(detail).font(.forgeCaption(12)).foregroundStyle(forge.textTertiary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                Spacer(minLength: 0)
                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(selected ? forge.accent : forge.textTertiary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .forgeCard(padding: Space.md, cornerRadius: Radius.md)
        }
        .buttonStyle(.plain)
    }

    private var footer: some View {
        HStack(spacing: Space.md) {
            if step > 0 {
                Button("Back") { withAnimation { step -= 1 } }
                    .font(.forgeBodySemibold(16))
                    .foregroundStyle(forge.textSecondary)
                    .padding(.vertical, Space.md).padding(.horizontal, Space.lg)
            }
            Button(step == lastStep ? "Build my plan" : "Continue") {
                if step == lastStep {
                    generated = appState.generatePlan()
                } else {
                    withAnimation { step += 1 }
                }
            }
            .font(.forgeBodySemibold(16))
            .frame(maxWidth: .infinity)
            .padding(.vertical, Space.md)
            .foregroundStyle(canAdvance ? forge.onAccent : forge.textTertiary)
            .background(RoundedRectangle(cornerRadius: Radius.md)
                .fill(canAdvance ? forge.accent : forge.raised))
            .disabled(!canAdvance)
        }
        .padding(Space.lg)
    }

    /// Steps 0 and 1 are optional; the five real questions each need an answer.
    private var canAdvance: Bool {
        switch step {
        case 0, 1: return true
        case 2: return profile.experience != nil
        case 3: return profile.currentSessionsPerWeek != nil
        case 4: return profile.targetSessionsPerWeek != nil
        case 5: return profile.sessionLength != nil
        default: return profile.goal != nil
        }
    }
}

/// Shown once a plan has been generated, so the user sees what they got before
/// committing to it.
struct GeneratedPlanSheet: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.forge) private var forge
    @Environment(\.dismiss) private var dismiss
    let program: Program
    var onStart: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Space.lg) {
                    VStack(alignment: .leading, spacing: Space.sm) {
                        Text(program.name).font(.forgeHeading(28)).foregroundStyle(forge.textPrimary)
                        Text(program.tagline).font(.forgeBody(14)).foregroundStyle(forge.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Text(program.summary)
                        .font(.forgeBody(14)).foregroundStyle(forge.textSecondary)
                        .lineSpacing(3).fixedSize(horizontal: false, vertical: true)

                    SectionHeader(title: "Your week")
                    ForEach(Array(program.weekPattern.enumerated()), id: \.offset) { i, day in
                        HStack(alignment: .top, spacing: Space.md) {
                            Text("\(i + 1)").font(.forgeNumeric(14))
                                .foregroundStyle(day.isRest ? forge.textTertiary : forge.accent)
                                .frame(width: 20)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(day.isRest ? "Rest" : day.title)
                                    .font(.forgeBodySemibold(15))
                                    .foregroundStyle(day.isRest ? forge.textSecondary : forge.textPrimary)
                                if !day.isRest {
                                    Text(day.slots.compactMap { $0.template?.name }.joined(separator: " · "))
                                        .font(.forgeCaption(12)).foregroundStyle(forge.textTertiary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                            Spacer(minLength: 0)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .forgeCard(padding: Space.md, cornerRadius: Radius.md)
                    }

                    Button {
                        appState.enroll(in: program)
                        dismiss(); onStart()
                    } label: {
                        Text("Start this plan").font(.forgeBodySemibold(16))
                            .frame(maxWidth: .infinity).padding(.vertical, Space.md)
                    }
                    .foregroundStyle(forge.onAccent)
                    .background(RoundedRectangle(cornerRadius: Radius.md).fill(forge.accent))
                    Spacer(minLength: Space.xl)
                }
                .padding(Space.lg)
            }
            .scrollIndicators(.hidden)
            .forgeScreenBackground()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Not now") { dismiss() }.foregroundStyle(forge.textSecondary)
                }
            }
        }
    }
}
