import ActivityKit
import WidgetKit
import SwiftUI

private extension Color {
    init(activityHex hex: String) {
        let cleaned = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)
        let r = Double((value >> 16) & 0xFF) / 255.0
        let g = Double((value >> 8) & 0xFF) / 255.0
        let b = Double(value & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}

private let activityFireGradient = LinearGradient(
    colors: [Color(activityHex: "FFB03C"), Color(activityHex: "FF5C2E"), Color(activityHex: "FF2D3E")],
    startPoint: .topLeading, endPoint: .bottomTrailing
)

struct LiveWorkoutActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WorkoutActivityAttributes.self) { context in
            LiveWorkoutBannerView(context: context)
                .activityBackgroundTint(Color.black)
                .activitySystemActionForegroundColor(Color.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(activityFireGradient)
                        .font(.system(size: 20))
                }
                DynamicIslandExpandedRegion(.trailing) {
                    restOrProgressLabel(context.state, size: 16)
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(context.state.exerciseName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(context.state.isResting ? "Resting" : "In progress")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.white.opacity(0.65))
                }
            } compactLeading: {
                Image(systemName: "flame.fill").foregroundStyle(activityFireGradient)
            } compactTrailing: {
                restOrProgressLabel(context.state, size: 13)
                    .frame(width: 44)
            } minimal: {
                Image(systemName: "flame.fill").foregroundStyle(activityFireGradient)
            }
        }
    }

    @ViewBuilder
    private func restOrProgressLabel(_ state: WorkoutActivityAttributes.ContentState, size: CGFloat) -> some View {
        if state.isResting, let end = state.restEndDate, end > Date() {
            Text(timerInterval: Date.now...end, countsDown: true)
                .font(.system(size: size, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.white)
        } else {
            Text("\(state.exerciseIndex + 1)/\(state.totalExercises)")
                .font(.system(size: size, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
    }
}

private struct LiveWorkoutBannerView: View {
    let context: ActivityViewContext<WorkoutActivityAttributes>

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle().fill(Color.white.opacity(0.1)).frame(width: 46, height: 46)
                Image(systemName: "flame.fill")
                    .foregroundStyle(activityFireGradient)
                    .font(.system(size: 20))
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(context.state.exerciseName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text("Exercise \(context.state.exerciseIndex + 1) of \(context.state.totalExercises)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white.opacity(0.6))
            }
            Spacer(minLength: 0)
            if context.state.isResting, let end = context.state.restEndDate, end > Date() {
                VStack(spacing: 2) {
                    Text(timerInterval: Date.now...end, countsDown: true)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(.white)
                    Text("rest").font(.system(size: 10, weight: .medium)).foregroundStyle(.white.opacity(0.6))
                }
            }
        }
        .padding(16)
    }
}
