import SwiftUI

/// A warm, categorical palette reserved for the Suggest tab's category icons -
/// distinct from `forge.accent` so categories read apart from each other, but
/// kept in the amber/orange/red "fire" family rather than a full rainbow (that's
/// TotalWorkoutsDetailSheet's job, for its donut chart legend).
extension WorkoutCategory {
    var fireTint: Color {
        switch self {
        case .upperBody: return Color(hex: "F5923C")
        case .lowerBody: return Color(hex: "FF8144")
        case .fullBody: return Color(hex: "FF7048")
        case .core: return Color(hex: "FA5F4A")
        case .cardio: return Color(hex: "F5504A")
        case .hiit: return Color(hex: "EB4141")
        case .flexibility: return Color(hex: "D9713F")
        case .recovery: return Color(hex: "C77A32")
        case .activity: return Color(hex: "B86A28")
        case .sports: return Color(hex: "E0862F")
        case .warmUp, .coolDown, .other: return Color(hex: "FFB03C")
        }
    }
}

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
                    Text("Suggest").font(.forgeHeading(34)).foregroundStyle(forge.textPrimary)
                    Text("Train. Track. Level up.")
                        .font(.forgeBody(14)).foregroundStyle(forge.textSecondary)
                }
                .padding(.top, Space.md)

                LazyVGrid(columns: columns, spacing: Space.md) {
                    ForEach(WorkoutCategory.browsable) { category in
                        NavigationLink(value: category) {
                            VStack(spacing: Space.md) {
                                CategoryIcon(systemName: category.icon, size: 38, tint: category.fireTint)
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
                                CategoryIcon(systemName: template.category.icon, size: 16, tint: template.category.fireTint)
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
