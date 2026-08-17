import SwiftUI

struct CopyDaySheet: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.forge) private var forge
    @Environment(\.dismiss) private var dismiss
    var sourceDate: Date

    @State private var targetDate = Calendar.forge.date(byAdding: .day, value: 1, to: Date())!

    var body: some View {
        NavigationStack {
            VStack(spacing: Space.xl) {
                DatePicker("Copy to", selection: $targetDate, in: Date()..., displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .tint(forge.accent)
                Button {
                    appState.copyDay(from: sourceDate, to: targetDate.startOfDay)
                    dismiss()
                } label: {
                    Text("Copy Workouts").frame(maxWidth: .infinity)
                }
                .forgeGlassPrimary()
                Spacer()
            }
            .padding(Space.lg)
            .navigationTitle("Copy Day")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            }
        }
    }
}

struct SaveTemplateSheet: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    var sourceDate: Date

    @State private var name = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Template name") {
                    TextField("e.g. Push Day", text: $name)
                }
            }
            .navigationTitle("Save Template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        appState.saveTemplate(name: name, from: sourceDate)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

struct ApplyTemplateSheet: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.forge) private var forge
    @Environment(\.dismiss) private var dismiss
    var targetDate: Date

    var body: some View {
        NavigationStack {
            Group {
                if appState.userData.templates.isEmpty {
                    EmptyStateView(icon: "square.stack", title: "No templates yet", message: "Save a day's plan as a template to reuse it here.")
                } else {
                    List {
                        ForEach(appState.userData.templates) { template in
                            Button {
                                appState.applyTemplate(template, to: targetDate)
                                dismiss()
                            } label: {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(template.name).font(.forgeBodySemibold(15)).foregroundStyle(forge.textPrimary)
                                    Text("\(template.entries.count) exercise(s)").font(.forgeCaption()).foregroundStyle(forge.textSecondary)
                                }
                            }
                        }
                        .onDelete { indexSet in
                            for i in indexSet { appState.deleteTemplate(appState.userData.templates[i]) }
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Apply Template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            }
            .forgeScreenBackground()
        }
    }
}
