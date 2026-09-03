import SwiftUI

struct ProgramListView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.forge) private var forge
    @State private var selected: Program?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Space.lg) {
                Text("Multi-week plans that schedule the work for you. One runs at a time.")
                    .font(.forgeBody(14))
                    .foregroundStyle(forge.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                ForEach(ProgramLibrary.all) { program in
                    Button { selected = program } label: { ProgramCard(program: program) }
                        .buttonStyle(.plain)
                }
                Spacer(minLength: 90)
            }
            .padding(Space.lg)
        }
        .scrollIndicators(.hidden)
        .forgeScreenBackground()
        .navigationTitle("Programs")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selected) { ProgramDetailSheet(program: $0) }
    }
}

private struct ProgramCard: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.forge) private var forge
    let program: Program

    private var isActive: Bool { appState.isEnrolled(in: program) }

    var body: some View {
        VStack(alignment: .leading, spacing: Space.md) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(program.name)
                        .font(.forgeHeading(20))
                        .foregroundStyle(forge.textPrimary)
                    Text(program.tagline)
                        .font(.forgeBody(13))
                        .foregroundStyle(forge.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: Space.sm)
                if isActive {
                    Text("ACTIVE")
                        .font(.forgeCaption(11))
                        .foregroundStyle(forge.onAccent)
                        .padding(.horizontal, Space.sm)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(forge.accent))
                }
            }

            HStack(spacing: Space.sm) {
                ForgeChip(label: "\(program.totalDays) days", systemImage: "calendar")
                ForgeChip(label: program.level.label, systemImage: program.level.icon)
                Spacer(minLength: 0)
            }

            Text("\(program.trainingDaysPerWeek) training days a week · \(program.equipmentLabel)")
                .font(.forgeCaption(12))
                .foregroundStyle(forge.textTertiary)
                .fixedSize(horizontal: false, vertical: true)

            if isActive, let e = appState.activeEnrollment {
                VStack(alignment: .leading, spacing: 6) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(forge.raised).frame(height: 6)
                            Capsule().fill(forge.accent)
                                .frame(width: max(0, geo.size.width * e.progress), height: 6)
                        }
                    }
                    .frame(height: 6)
                    Text("\(e.completedDayIndices.count) of \(program.totalDays) days done")
                        .font(.forgeCaption(12))
                        .foregroundStyle(forge.textSecondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .forgeCard()
    }
}
