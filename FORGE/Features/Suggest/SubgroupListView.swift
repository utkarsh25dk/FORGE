import SwiftUI

struct SubgroupListView: View {
    @Environment(\.forge) private var forge
    var category: WorkoutCategory

    var body: some View {
        ScrollView {
            VStack(spacing: Space.md) {
                HStack(spacing: Space.md) {
                    CategoryIcon(systemName: category.icon, size: 22)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(category.rawValue).font(.forgeHeading(20)).foregroundStyle(forge.textPrimary)
                        Text("Pick a muscle group to see exercises").font(.forgeCaption()).foregroundStyle(forge.textSecondary)
                    }
                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, Space.sm)

                ForEach(ExerciseLibrary.subgroups(for: category), id: \.self) { subgroup in
                    NavigationLink(value: SuggestRoute(category: category, subgroup: subgroup)) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(subgroup).font(.forgeBodySemibold(16)).foregroundStyle(forge.textPrimary)
                                Text("5 exercises").font(.forgeCaption()).foregroundStyle(forge.textSecondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right").foregroundStyle(forge.textTertiary).font(.system(size: 13, weight: .semibold))
                        }
                        .forgeCard(padding: Space.md, cornerRadius: Radius.md)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(Space.lg)
        }
        .scrollIndicators(.hidden)
        .forgeScreenBackground()
        .navigationTitle(category.rawValue)
        .navigationBarTitleDisplayMode(.inline)
    }
}
