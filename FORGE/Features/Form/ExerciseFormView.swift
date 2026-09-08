import SwiftUI

/// Renders one exercise's form guidance. Shared by the exercise detail sheet and
/// the live workout screen so the guidance reads identically in both.
struct ExerciseFormView: View {
    @Environment(\.forge) private var forge
    let form: ExerciseForm
    /// Suppressed where the container already carries a "How to do it" heading,
    /// so the label doesn't appear twice.
    var showsStepsHeading: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: Space.lg) {
            steps
            if let breathing = form.breathing { breathingRow(breathing) }
            if !form.mistakes.isEmpty { mistakes }
            if form.easier != nil || form.harder != nil { progressions }
        }
    }

    private var steps: some View {
        VStack(alignment: .leading, spacing: Space.sm) {
            if showsStepsHeading { label("How to do it") }
            VStack(alignment: .leading, spacing: Space.sm) {
                ForEach(Array(form.steps.enumerated()), id: \.offset) { i, step in
                    HStack(alignment: .top, spacing: Space.md) {
                        Text("\(i + 1)")
                            .font(.forgeNumeric(13))
                            .foregroundStyle(forge.accent)
                            .frame(width: 16, alignment: .trailing)
                            .padding(.top, 1)
                        Text(step)
                            .font(.forgeBody(14))
                            .foregroundStyle(forge.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }

    private func breathingRow(_ text: String) -> some View {
        HStack(alignment: .top, spacing: Space.sm) {
            Image(systemName: "wind")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(forge.textTertiary)
                .padding(.top, 1)
            Text(text)
                .font(.forgeBody(13))
                .foregroundStyle(forge.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Space.md)
        .background(RoundedRectangle(cornerRadius: Radius.sm).fill(forge.raised))
    }

    private var mistakes: some View {
        VStack(alignment: .leading, spacing: Space.sm) {
            label("Common mistakes")
            VStack(alignment: .leading, spacing: 7) {
                ForEach(Array(form.mistakes.enumerated()), id: \.offset) { _, mistake in
                    HStack(alignment: .top, spacing: Space.sm) {
                        Image(systemName: "xmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(forge.warning)
                            .padding(.top, 3)
                        Text(mistake)
                            .font(.forgeBody(13))
                            .foregroundStyle(forge.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }

    private var progressions: some View {
        VStack(alignment: .leading, spacing: Space.sm) {
            if let easier = form.easier {
                progressionRow(icon: "arrow.down.right", title: "Easier", text: easier)
            }
            if let harder = form.harder {
                progressionRow(icon: "arrow.up.right", title: "Harder", text: harder)
            }
        }
    }

    private func progressionRow(icon: String, title: String, text: String) -> some View {
        HStack(alignment: .top, spacing: Space.md) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(forge.accent)
                .frame(width: 16)
                .padding(.top, 2)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.forgeCaption(11))
                    .foregroundStyle(forge.textTertiary)
                    .textCase(.uppercase)
                Text(text)
                    .font(.forgeBody(13))
                    .foregroundStyle(forge.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func label(_ text: String) -> some View {
        Text(text)
            .font(.forgeCaption(11))
            .foregroundStyle(forge.textTertiary)
            .textCase(.uppercase)
    }
}

/// Full-screen presentation of form guidance, used from the live workout where
/// there's no room to inline it.
struct ExerciseFormSheet: View {
    @Environment(\.forge) private var forge
    @Environment(\.dismiss) private var dismiss
    let title: String
    let form: ExerciseForm

    var body: some View {
        NavigationStack {
            ScrollView {
                ExerciseFormView(form: form)
                    .padding(Space.lg)
            }
            .scrollIndicators(.hidden)
            .forgeScreenBackground()
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }.foregroundStyle(forge.accent)
                }
            }
        }
    }
}
