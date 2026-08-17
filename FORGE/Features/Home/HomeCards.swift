import SwiftUI

/// Streak, weekly goal, and level as one continuous surface with hairline
/// dividers instead of three separate glowing cards — plus the hydration
/// and sleep check-ins below their own divider. This is "Today."
struct TodayCard: View {
    @Environment(\.forge) private var forge

    var body: some View {
        VStack(spacing: 0) {
            StatRow()
            Divider().overlay(forge.divider).padding(.vertical, Space.md)
            HydrationSection()
            Divider().overlay(forge.divider).padding(.vertical, Space.md)
            SleepSection()
        }
        .forgeCard()
    }
}

private struct StatRow: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.forge) private var forge

    var body: some View {
        HStack(spacing: 0) {
            streakTile
            statDivider
            weeklyGoalTile
            statDivider
            LevelTile()
        }
    }

    private var statDivider: some View {
        Rectangle().fill(forge.divider).frame(width: 1).padding(.vertical, 4)
    }

    /// The app's one reserved hero moment — everything else on this screen is flat.
    private var streakTile: some View {
        VStack(spacing: 6) {
            Image(systemName: "flame.fill")
                .foregroundStyle(forge.fireGradient)
                .font(.system(size: 22))
                .symbolEffect(.bounce, value: appState.currentStreak)
            Text("\(appState.currentStreak)")
                .font(.forgeNumeric(30))
                .foregroundStyle(forge.fireGradient)
                .monospacedDigit()
                .contentTransition(.numericText())
                .animation(.default, value: appState.currentStreak)
            Text(appState.currentStreak == 1 ? "day streak" : "day streak")
                .font(.forgeCaption(11))
                .foregroundStyle(forge.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var weeklyGoalTile: some View {
        let worked = appState.weeklyWorkedDays()
        return VStack(spacing: 6) {
            ZStack {
                ProgressRing(progress: appState.weeklyProgress, lineWidth: 6)
                    .frame(width: 40, height: 40)
                Text("\(worked)/\(appState.userData.weeklyGoal)")
                    .font(.forgeCaption(10))
                    .foregroundStyle(forge.textPrimary)
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .animation(.default, value: worked)
            }
            Text(appState.weeklyProgress >= 1 ? "Goal hit" : "\(appState.userData.weeklyGoal - worked) to go")
                .font(.forgeCaption(11))
                .foregroundStyle(forge.textSecondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }

}

private struct LevelTile: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.forge) private var forge
    @State private var showDetail = false

    var body: some View {
        let progress = appState.levelProgress
        VStack(spacing: 6) {
            Text("\(progress.level)")
                .font(.forgeNumeric(30))
                .foregroundStyle(forge.accent)
                .monospacedDigit()
                .contentTransition(.numericText())
                .animation(.default, value: progress.level)
            Text("\(progress.xpToNext) XP to next")
                .font(.forgeCaption(11))
                .foregroundStyle(forge.textTertiary)
                .monospacedDigit()
                .contentTransition(.numericText())
                .animation(.default, value: progress.xpToNext)
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture { showDetail = true }
        .sheet(isPresented: $showDetail) { LevelDetailSheet() }
    }
}

private struct HydrationSection: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.forge) private var forge

    var body: some View {
        let count = appState.checkIn(on: Date()).hydrationCount
        VStack(alignment: .leading, spacing: Space.md) {
            HStack(spacing: 6) {
                Image(systemName: "drop.fill").font(.system(size: 13)).foregroundStyle(forge.accent)
                Text("Stay hydrated").font(.forgeBodySemibold(15)).foregroundStyle(forge.textPrimary)
                Spacer(minLength: 0)
                Text("\(count)/\(DailyCheckIn.hydrationGoal)")
                    .font(.forgeCaption())
                    .foregroundStyle(forge.textSecondary)
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .animation(.default, value: count)
            }
            HStack(spacing: 4) {
                ForEach(1...DailyCheckIn.hydrationGoal, id: \.self) { i in
                    Capsule()
                        .fill(i <= count ? AnyShapeStyle(forge.accent) : AnyShapeStyle(forge.raised))
                        .frame(height: 10)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            appState.setHydration(count == i ? i - 1 : i)
                        }
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: count)
            .sensoryFeedback(.selection, trigger: count)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct SleepSection: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.forge) private var forge
    @State private var quality: Int = 3
    @State private var hours: Double = 7
    @State private var initialized = false
    @State private var isExpanded = false

    var body: some View {
        let checkIn = appState.checkIn(on: Date())
        VStack(alignment: .leading, spacing: Space.md) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) { isExpanded.toggle() }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "moon.zzz.fill").font(.system(size: 13)).foregroundStyle(forge.accent)
                    Text("Sleep").font(.forgeBodySemibold(15)).foregroundStyle(forge.textPrimary)
                    Spacer(minLength: 0)
                    if checkIn.sleepConfirmed {
                        Text(String(format: "%.1f hrs", checkIn.sleepHours ?? hours))
                            .font(.forgeCaption())
                            .foregroundStyle(forge.textSecondary)
                    } else if !isExpanded {
                        Text("Log sleep")
                            .font(.forgeCaption())
                            .foregroundStyle(forge.accent)
                    }
                    Image(systemName: "chevron.down")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(forge.textTertiary)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isExpanded {
                Text("How well did you sleep?")
                    .font(.forgeCaption())
                    .foregroundStyle(forge.textTertiary)
                HStack(spacing: 8) {
                    ForEach(1...5, id: \.self) { i in
                        Circle()
                            .fill(i <= quality ? AnyShapeStyle(forge.accent) : AnyShapeStyle(forge.raised))
                            .overlay(
                                Circle().stroke(forge.textTertiary.opacity(i <= quality ? 0 : 0.45), lineWidth: 1)
                            )
                            .frame(width: 44, height: 44)
                            .scaleEffect(i <= quality ? 1 : 0.9)
                            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: quality)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                quality = i
                            }
                    }
                    Spacer(minLength: 0)
                }
                .sensoryFeedback(.selection, trigger: quality)

                HStack {
                    Text("Hours slept")
                        .font(.forgeCaption())
                        .foregroundStyle(forge.textTertiary)
                    Spacer(minLength: 0)
                    Text(String(format: "%.1f hrs", hours))
                        .font(.forgeCaption())
                        .foregroundStyle(forge.textSecondary)
                        .monospacedDigit()
                        .contentTransition(.numericText())
                        .animation(.default, value: hours)
                }
                Slider(value: $hours, in: 0...12, step: 0.5).tint(forge.accent)
                Button {
                    appState.confirmSleep(quality: quality, hours: hours)
                } label: {
                    HStack {
                        Image(systemName: "checkmark")
                        Text(checkIn.sleepConfirmed ? "Update" : "Confirm")
                    }
                    .frame(maxWidth: .infinity)
                }
                .forgeGlassSecondary()
                .frame(height: 40)
                .sensoryFeedback(.success, trigger: checkIn.sleepConfirmed)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear {
            guard !initialized else { return }
            initialized = true
            if let q = checkIn.sleepQuality { quality = q }
            if let h = checkIn.sleepHours { hours = h }
        }
    }
}
