import SwiftUI

struct ExerciseDetailSheet: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.forge) private var forge
    @Environment(\.dismiss) private var dismiss
    var template: ExerciseTemplate

    @State private var date = Date()
    @State private var sets: Int = 3
    @State private var reps: Int = 10
    @State private var weight: Double = 0
    @State private var durationMin: Int = 20
    @State private var inclinePercent: Int = 0
    @State private var intensity: Int = 5
    @State private var holdSec: Int = 30
    @State private var distanceMiles: Double = 1.0
    @State private var rounds: Int = 5
    @State private var workSec: Int = 30
    @State private var restSec: Int = 30

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Space.lg) {
                    header

                    if let warning = appState.restWarning(for: template) {
                        banner(text: warning, icon: "exclamationmark.triangle.fill", tint: forge.warning)
                    }
                    if let suggestion = appState.progressionSuggestion(for: template) {
                        banner(text: suggestion, icon: "chart.line.uptrend.xyaxis", tint: forge.accent)
                    } else {
                        banner(text: template.tip, icon: "lightbulb.fill", tint: forge.accent)
                    }

                    fieldsSection

                    DatePicker("Add to", selection: $date, in: Date()..., displayedComponents: .date)
                        .font(.forgeBodyMedium(15))
                        .tint(forge.accent)
                        .forgeCard(padding: Space.md, cornerRadius: Radius.md)

                    Button {
                        addToPlan()
                    } label: {
                        Text("Add to Plan").frame(maxWidth: .infinity)
                    }
                    .forgeGlassPrimary()
                }
                .padding(Space.lg)
            }
            .scrollIndicators(.hidden)
            .forgeScreenBackground()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Close") { dismiss() } }
            }
            .onAppear { populateDefaults() }
        }
        .presentationDetents([.large])
    }

    private var header: some View {
        VStack(spacing: 6) {
            CategoryIcon(systemName: template.category.icon, size: 26, tint: template.category.fireTint)
            Text(template.name).font(.forgeHeading(22)).foregroundStyle(forge.textPrimary).multilineTextAlignment(.center)
            Text("\(template.subgroup) · \(template.equipment)").font(.forgeCaption()).foregroundStyle(forge.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    private func banner(text: String, icon: String, tint: Color) -> some View {
        HStack(alignment: .top, spacing: Space.sm) {
            Image(systemName: icon).foregroundStyle(tint)
            Text(text).font(.forgeBody(13)).foregroundStyle(forge.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .forgeCard(padding: Space.md, cornerRadius: Radius.md)
    }

    @ViewBuilder
    private var fieldsSection: some View {
        VStack(alignment: .leading, spacing: Space.md) {
            switch template.kind {
            case .strength:
                Stepper("Sets: \(sets)", value: $sets, in: 1...10)
                Stepper("Reps: \(reps)", value: $reps, in: 1...50)
                HStack {
                    Text("Weight (\(appState.userData.unitSystem.weightUnit))")
                    Spacer()
                    Stepper("\(Int(weight))", value: $weight, in: 0...1000, step: 5).fixedSize()
                }
            case .cardio:
                Stepper("Duration: \(durationMin) min", value: $durationMin, in: 5...180, step: 5)
                Stepper("Incline: \(inclinePercent)%", value: $inclinePercent, in: 0...20)
                Stepper("Intensity (RPE): \(intensity)", value: $intensity, in: 1...10)
            case .hold:
                Stepper("Sets: \(sets)", value: $sets, in: 1...10)
                Stepper("Hold: \(holdSec)s", value: $holdSec, in: 10...600, step: 10)
            case .distance:
                Stepper("Distance: \(String(format: "%.1f", distanceMiles)) \(appState.userData.unitSystem.distanceUnit)", value: $distanceMiles, in: 0.25...50, step: 0.25)
                Stepper("Duration: \(durationMin) min", value: $durationMin, in: 5...300, step: 5)
            case .interval:
                Stepper("Rounds: \(rounds)", value: $rounds, in: 2...20)
                Stepper("Work: \(workSec)s", value: $workSec, in: 10...120, step: 5)
                Stepper("Rest: \(restSec)s", value: $restSec, in: 5...120, step: 5)
                Stepper("Intensity (RPE): \(intensity)", value: $intensity, in: 1...10)
            case .session:
                Stepper("Duration: \(durationMin) min", value: $durationMin, in: 5...180, step: 5)
                Stepper("Intensity (RPE): \(intensity)", value: $intensity, in: 1...10)
            }
        }
        .font(.forgeBodyMedium(15))
        .foregroundStyle(forge.textPrimary)
        .forgeCard(padding: Space.md, cornerRadius: Radius.md)
    }

    private func populateDefaults() {
        sets = template.sets ?? 3
        reps = template.reps ?? 10
        weight = 0
        durationMin = template.durationMin ?? 20
        inclinePercent = template.inclinePercent ?? 0
        intensity = template.intensity ?? 5
        holdSec = template.holdSec ?? 30
        distanceMiles = template.distanceMiles ?? 1.0
        rounds = template.rounds ?? 5
        workSec = template.workSec ?? 30
        restSec = template.restSec ?? 30
    }

    private func addToPlan() {
        var entry = WorkoutEntry(name: template.name, category: template.category, subgroup: template.subgroup, kind: template.kind, date: date.startOfDay)
        switch template.kind {
        case .strength:
            entry.sets = sets; entry.reps = reps; entry.weight = weight
        case .cardio:
            entry.durationMin = durationMin; entry.inclinePercent = inclinePercent; entry.intensity = intensity
        case .hold:
            entry.sets = sets; entry.holdSec = holdSec
        case .distance:
            entry.distanceMiles = distanceMiles; entry.durationMin = durationMin
        case .interval:
            entry.rounds = rounds; entry.workSec = workSec; entry.restSec = restSec; entry.intensity = intensity
        case .session:
            entry.durationMin = durationMin; entry.intensity = intensity
        }
        appState.addEntry(entry)
        appState.notify("Added \(template.name) to your plan")
        dismiss()
    }
}
