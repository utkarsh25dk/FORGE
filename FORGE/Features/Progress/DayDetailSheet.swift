import SwiftUI

struct DayDetailSheet: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.forge) private var forge
    @Environment(\.dismiss) private var dismiss
    var date: Date

    var body: some View {
        let entries = appState.sortedEntries(on: date)
        NavigationStack {
            Group {
                if entries.isEmpty {
                    EmptyStateView(icon: "moon.zzz", title: "Nothing logged :(", message: "No plan was recorded for this day.")
                } else {
                    ScrollView {
                        VStack(spacing: 2) {
                            ForEach(entries) { entry in
                                WorkoutRow(entry: entry) {}
                            }
                        }
                        .forgeCard()
                        .padding(Space.lg)
                    }
                    .scrollIndicators(.hidden)
                }
            }
            .forgeScreenBackground()
            .navigationTitle(date.formatted(.dateTime.weekday(.wide).month().day().year()))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } }
            }
        }
    }
}
