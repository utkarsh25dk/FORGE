import SwiftUI

struct SleepDetailSheet: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.forge) private var forge
    @Environment(\.dismiss) private var dismiss
    var date: Date

    private let sleepColor = Color(hex: "5CA8FF")

    var body: some View {
        let checkIn = appState.checkIn(on: date)
        NavigationStack {
            Group {
                if !checkIn.sleepConfirmed {
                    EmptyStateView(icon: "moon.zzz", title: "Nothing logged", message: "No sleep check-in for this day.")
                } else {
                    ScrollView {
                        VStack(spacing: Space.lg) {
                            VStack(spacing: Space.sm) {
                                Text(String(format: "%.1f", checkIn.sleepHours ?? 0))
                                    .font(.forgeHeading(44))
                                    .foregroundStyle(sleepColor)
                                    .monospacedDigit()
                                Text("hours slept")
                                    .font(.forgeBody(14))
                                    .foregroundStyle(forge.textSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            .forgeCard(padding: Space.lg, cornerRadius: Radius.md)

                            VStack(alignment: .leading, spacing: Space.sm) {
                                Text("Sleep quality").font(.forgeBodySemibold(15)).foregroundStyle(forge.textPrimary)
                                HStack(spacing: 8) {
                                    ForEach(1...5, id: \.self) { i in
                                        Circle()
                                            .fill(i <= (checkIn.sleepQuality ?? 0) ? forge.accent : forge.textTertiary.opacity(0.12))
                                            .overlay(
                                                Circle().stroke(i <= (checkIn.sleepQuality ?? 0) ? Color.clear : forge.textTertiary.opacity(0.35), lineWidth: 1.5)
                                            )
                                            .frame(width: 30, height: 30)
                                    }
                                    Spacer(minLength: 0)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .forgeCard(padding: Space.md, cornerRadius: Radius.md)
                        }
                        .padding(Space.lg)
                    }
                    .scrollIndicators(.hidden)
                }
            }
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
