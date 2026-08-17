import SwiftUI
import Charts

struct BodyMeasurementsView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.forge) private var forge
    @State private var showAdd = false

    private var weightSeries: [BodyMeasurementEntry] {
        appState.userData.measurements.filter { $0.weight != nil }.sorted { $0.date < $1.date }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Space.md) {
            HStack {
                SectionHeader(title: "Body Weight")
                Spacer()
                Button { showAdd = true } label: {
                    Image(systemName: "plus.circle.fill").foregroundStyle(forge.accent)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
            }

            if weightSeries.isEmpty {
                EmptyStateView(icon: "scalemass", title: "No entries yet", message: "Log your weight to start tracking trends over time.", actionTitle: "Add Entry") { showAdd = true }
            } else {
                Chart(weightSeries) { entry in
                    LineMark(x: .value("Date", entry.date), y: .value("Weight", entry.weight ?? 0))
                        .foregroundStyle(forge.accent)
                        .interpolationMethod(.catmullRom)
                    PointMark(x: .value("Date", entry.date), y: .value("Weight", entry.weight ?? 0))
                        .foregroundStyle(forge.accent)
                }
                .chartYAxis { AxisMarks(position: .leading) }
                .frame(height: 160)

                VStack(spacing: 2) {
                    ForEach(weightSeries.reversed().prefix(5)) { entry in
                        HStack {
                            Text(entry.date.formatted(.dateTime.month().day())).font(.forgeCaption(12)).foregroundStyle(forge.textSecondary)
                            Spacer()
                            Text("\(Int(entry.weight ?? 0)) \(appState.userData.unitSystem.weightUnit)").font(.forgeBodyMedium(13)).foregroundStyle(forge.textPrimary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .forgeCard()
        .sheet(isPresented: $showAdd) { AddMeasurementSheet() }
    }
}

struct AddMeasurementSheet: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var date = Date()
    @State private var weight: Double = 150
    @State private var waist: Double = 0
    @State private var chest: Double = 0
    @State private var arms: Double = 0
    @State private var hips: Double = 0
    @State private var thighs: Double = 0

    var body: some View {
        NavigationStack {
            Form {
                DatePicker("Date", selection: $date, displayedComponents: .date)
                Section("Weight (\(appState.userData.unitSystem.weightUnit))") {
                    TextField("Weight", value: $weight, format: .number).keyboardType(.decimalPad)
                }
                Section("Measurements (optional)") {
                    measurementField("Waist", $waist)
                    measurementField("Chest", $chest)
                    measurementField("Arms", $arms)
                    measurementField("Hips", $hips)
                    measurementField("Thighs", $thighs)
                }
            }
            .navigationTitle("Log Measurements")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        appState.addMeasurement(BodyMeasurementEntry(
                            date: date.startOfDay, weight: weight,
                            waist: waist > 0 ? waist : nil, chest: chest > 0 ? chest : nil,
                            arms: arms > 0 ? arms : nil, hips: hips > 0 ? hips : nil, thighs: thighs > 0 ? thighs : nil
                        ))
                        dismiss()
                    }
                }
            }
        }
    }

    private func measurementField(_ label: String, _ value: Binding<Double>) -> some View {
        HStack {
            Text(label)
            Spacer()
            TextField("0", value: value, format: .number).keyboardType(.decimalPad).multilineTextAlignment(.trailing).frame(width: 80)
        }
    }
}
