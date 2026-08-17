import SwiftUI

struct HydrationDetailSheet: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.forge) private var forge
    @Environment(\.dismiss) private var dismiss
    var date: Date

    private let hydrationColor = Color(hex: "5CE0D8")

    var body: some View {
        let count = appState.checkIn(on: date).hydrationCount
        NavigationStack {
            ScrollView {
                VStack(spacing: Space.lg) {
                    VStack(spacing: Space.sm) {
                        Text("\(count)/\(DailyCheckIn.hydrationGoal)")
                            .font(.forgeHeading(44))
                            .foregroundStyle(hydrationColor)
                            .monospacedDigit()
                        Text(count >= DailyCheckIn.hydrationGoal ? "Goal hit" : "glasses of water")
                            .font(.forgeBody(14))
                            .foregroundStyle(forge.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .forgeCard(padding: Space.lg, cornerRadius: Radius.md)

                    HStack(spacing: 8) {
                        ForEach(1...DailyCheckIn.hydrationGoal, id: \.self) { i in
                            Circle()
                                .fill(i <= count ? hydrationColor : forge.textTertiary.opacity(0.12))
                                .overlay(
                                    Circle().stroke(i <= count ? Color.clear : forge.textTertiary.opacity(0.35), lineWidth: 1.5)
                                )
                                .frame(width: 30, height: 30)
                        }
                        Spacer(minLength: 0)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .forgeCard(padding: Space.md, cornerRadius: Radius.md)
                }
                .padding(Space.lg)
            }
            .scrollIndicators(.hidden)
            .forgeScreenBackground()
            .navigationTitle(date.formatted(.dateTime.weekday(.wide).month().day()))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } }
            }
        }
        .presentationDetents([.medium])
    }
}
