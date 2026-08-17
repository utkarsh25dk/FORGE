import SwiftUI

struct SuggestView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.forge) private var forge
    @State private var searchText = ""
    @State private var selectedResult: ExerciseTemplate?

    private let columns = [GridItem(.flexible(), spacing: Space.md), GridItem(.flexible(), spacing: Space.md)]

    private var searchResults: [ExerciseTemplate] {
        guard !searchText.isEmpty else { return [] }
        return ExerciseLibrary.all.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            Group {
                if !searchText.isEmpty {
                    searchResultsList
                } else {
                    categoryGrid
                }
            }
            .forgeScreenBackground()
            .navigationDestination(for: WorkoutCategory.self) { category in
                SubgroupListView(category: category)
            }
            .navigationDestination(for: SuggestRoute.self) { route in
                ExerciseListView(category: route.category, subgroup: route.subgroup)
            }
            .sheet(item: $selectedResult) { template in
                ExerciseDetailSheet(template: template)
            }
        }
        .searchable(text: $searchText, prompt: "Search exercises")
    }

    private var categoryGrid: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Space.lg) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Suggest").font(.forgeHeading(34)).foregroundStyle(forge.fireGradient)
                    Text("Train. Track. Level up.")
                        .font(.forgeBody(14)).foregroundStyle(forge.textSecondary)
                }
                .padding(.top, Space.md)

                LazyVGrid(columns: columns, spacing: Space.md) {
                    ForEach(WorkoutCategory.browsable) { category in
                        NavigationLink(value: category) {
                            VStack(spacing: Space.md) {
                                CategoryIcon(systemName: category.icon, size: 38)
                                Text(category.rawValue)
                                    .font(.forgeBodySemibold(16))
                                    .foregroundStyle(forge.textPrimary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 128)
                            .forgeCard(padding: Space.md, cornerRadius: Radius.md)
                        }
                        .buttonStyle(.plain)
                    }
                }
                Spacer(minLength: 90)
            }
            .padding(Space.lg)
        }
        .scrollIndicators(.hidden)
    }

    private var searchResultsList: some View {
        ScrollView {
            VStack(spacing: Space.md) {
                if searchResults.isEmpty {
                    EmptyStateView(icon: "magnifyingglass", title: "No matches", message: "Try a different exercise name.")
                        .padding(.top, Space.xl)
                } else {
                    ForEach(searchResults) { template in
                        Button {
                            selectedResult = template
                        } label: {
                            HStack(spacing: Space.md) {
                                CategoryIcon(systemName: template.category.icon, size: 16)
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(template.name).font(.forgeBodySemibold(15)).foregroundStyle(forge.textPrimary)
                                    Text("\(template.category.rawValue) · \(template.subgroup)")
                                        .font(.forgeCaption())
                                        .foregroundStyle(forge.textSecondary)
                                }
                                Spacer(minLength: 0)
                                Image(systemName: "chevron.right").foregroundStyle(forge.textTertiary).font(.system(size: 13, weight: .semibold))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .forgeCard(padding: Space.md, cornerRadius: Radius.md)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(Space.lg)
        }
        .scrollIndicators(.hidden)
    }
}

struct SuggestRoute: Hashable {
    let category: WorkoutCategory
    let subgroup: String
}
