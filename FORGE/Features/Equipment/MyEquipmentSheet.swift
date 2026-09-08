import SwiftUI

/// Lets the user say what they own, and shows immediately how much of the
/// library that unlocks — the number moves as they toggle, so the choice has
/// visible consequences rather than being a form to fill in.
struct MyEquipmentSheet: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.forge) private var forge
    @Environment(\.dismiss) private var dismiss

    private var unlocked: Int { appState.availableExerciseCount }
    private var total: Int { ExerciseLibrary.all.count }
    private var bodyweightOnly: Int {
        ExerciseLibrary.all.filter(\.needsNoEquipment).count
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Space.lg) {
                    summary

                    VStack(alignment: .leading, spacing: Space.sm) {
                        SectionHeader(title: "What do you have?",
                                      subtitle: "Tap everything you can get to")
                        ForEach(EquipmentGroup.selectable) { group in
                            row(group)
                        }
                    }

                    Text("\(bodyweightOnly) exercises need no equipment at all, so they're always available.")
                        .font(.forgeCaption(12))
                        .foregroundStyle(forge.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer(minLength: Space.xl)
                }
                .padding(Space.lg)
            }
            .scrollIndicators(.hidden)
            .forgeScreenBackground()
            .navigationTitle("My Equipment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }.foregroundStyle(forge.accent)
                }
            }
        }
    }

    private var summary: some View {
        VStack(alignment: .leading, spacing: Space.sm) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text("\(unlocked)")
                    .font(.forgeNumeric(34))
                    .foregroundStyle(forge.accent)
                Text("of \(total) exercises available")
                    .font(.forgeBody(15))
                    .foregroundStyle(forge.textSecondary)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(forge.raised).frame(height: 6)
                    Capsule().fill(forge.accent)
                        .frame(width: max(0, geo.size.width * (Double(unlocked) / Double(max(1, total)))), height: 6)
                }
            }
            .frame(height: 6)

            Toggle(isOn: Binding(
                get: { appState.userData.filterByEquipment },
                set: { appState.setEquipmentFilter($0) }
            )) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Only show what I can do")
                        .font(.forgeBodyMedium(15))
                        .foregroundStyle(forge.textPrimary)
                    Text(appState.hasSetUpEquipment
                         ? "Hides exercises needing gear you don't have"
                         : "Pick some equipment first")
                        .font(.forgeCaption(12))
                        .foregroundStyle(forge.textTertiary)
                }
            }
            .tint(forge.accent)
            .disabled(!appState.hasSetUpEquipment)
            .padding(.top, Space.sm)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .forgeCard()
    }

    private func row(_ group: EquipmentGroup) -> some View {
        let owned = appState.owns(group)
        return Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.85)) {
                appState.toggleEquipment(group)
            }
        } label: {
            HStack(spacing: Space.md) {
                Image(systemName: group.icon)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(owned ? forge.accent : forge.textTertiary)
                    .frame(width: 24)
                VStack(alignment: .leading, spacing: 2) {
                    Text(group.label)
                        .font(.forgeBodySemibold(15))
                        .foregroundStyle(forge.textPrimary)
                    Text(group.detail)
                        .font(.forgeCaption(12))
                        .foregroundStyle(forge.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
                Image(systemName: owned ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(owned ? forge.accent : forge.textTertiary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .forgeCard(padding: Space.md, cornerRadius: Radius.md)
        }
        .buttonStyle(.plain)
    }
}
