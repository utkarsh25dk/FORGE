import SwiftUI

struct StreakCard: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.forge) private var forge

    private var fireGlow: RadialGradient {
        RadialGradient(colors: [Color(hex: "FF5C2E").opacity(0.22), Color(hex: "FF5C2E").opacity(0.1)], center: .center, startRadius: 0, endRadius: 40)
    }

    var body: some View {
        VStack(spacing: Space.sm) {
            ZStack {
                Circle().fill(fireGlow).frame(width: 64, height: 64)
                Image(systemName: "flame.fill")
                    .foregroundStyle(forge.fireGradient)
                    .font(.system(size: 28))
                    .symbolEffect(.bounce, value: appState.currentStreak)
            }
            Text("\(appState.currentStreak) day\(appState.currentStreak == 1 ? "" : "s")")
                .font(.forgeNumeric(28))
                .foregroundStyle(forge.fireGradient)
                .monospacedDigit()
                .contentTransition(.numericText())
                .animation(.default, value: appState.currentStreak)
        }
        .frame(maxWidth: .infinity)
        .forgeCard()
    }
}

struct WeeklyGoalCard: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.forge) private var forge

    var body: some View {
        let worked = appState.weeklyWorkedDays()
        VStack(spacing: Space.sm) {
            ZStack {
                ProgressRing(progress: appState.weeklyProgress, lineWidth: 7)
                    .frame(width: 48, height: 48)
                Text("\(worked)/\(appState.userData.weeklyGoal)")
                    .font(.forgeCaption(11))
                    .foregroundStyle(forge.textPrimary)
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .animation(.default, value: worked)
            }
            Text("Weekly goal").font(.forgeBodySemibold(14)).foregroundStyle(forge.textPrimary)
            Text(appState.weeklyProgress >= 1 ? "Goal hit" : "\(appState.userData.weeklyGoal - worked) to go")
                .font(.forgeCaption(11))
                .foregroundStyle(forge.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .forgeCard(padding: Space.md, cornerRadius: Radius.md)
    }
}

struct LevelCard: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.forge) private var forge
    @State private var showDetail = false

    var body: some View {
        let progress = appState.levelProgress
        VStack(spacing: Space.sm) {
            ZStack {
                Circle().fill(forge.accentGlow).frame(width: 48, height: 48)
                Text("\(progress.level)")
                    .font(.forgeHeading(18))
                    .foregroundStyle(forge.accent)
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .animation(.default, value: progress.level)
            }
            Text("Level \(progress.level)").font(.forgeBodySemibold(14)).foregroundStyle(forge.textPrimary)
            Text("\(progress.xpToNext) XP to next")
                .font(.forgeCaption(11))
                .foregroundStyle(forge.textSecondary)
                .monospacedDigit()
                .contentTransition(.numericText())
                .animation(.default, value: progress.xpToNext)
        }
        .frame(maxWidth: .infinity)
        .forgeCard(padding: Space.md, cornerRadius: Radius.md)
        .contentShape(Rectangle())
        .onTapGesture { showDetail = true }
        .sheet(isPresented: $showDetail) { LevelDetailSheet() }
    }
}

struct HydrationCard: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.forge) private var forge

    var body: some View {
        let count = appState.checkIn(on: Date()).hydrationCount
        VStack(alignment: .leading, spacing: Space.md) {
            HStack {
                Text("💧 Stay hydrated").font(.forgeBodySemibold(15)).foregroundStyle(forge.textPrimary)
                Spacer(minLength: 0)
                Text("\(count)/\(DailyCheckIn.hydrationGoal)")
                    .font(.forgeCaption())
                    .foregroundStyle(forge.textSecondary)
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .animation(.default, value: count)
            }
            HStack(spacing: 6) {
                ForEach(1...DailyCheckIn.hydrationGoal, id: \.self) { i in
                    Circle()
                        .fill(i <= count ? AnyShapeStyle(forge.accent) : AnyShapeStyle(.ultraThinMaterial))
                        .overlay(
                            Circle().stroke(forge.textTertiary.opacity(i <= count ? 0 : 0.3), lineWidth: 1)
                        )
                        .frame(width: 36, height: 36)
                        .scaleEffect(i <= count ? 1 : 0.9)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: count)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            appState.setHydration(count == i ? i - 1 : i)
                        }
                }
                Spacer(minLength: 0)
            }
            .sensoryFeedback(.selection, trigger: count)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .forgeCard()
    }
}

struct SleepCard: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.forge) private var forge
    @State private var quality: Int = 3
    @State private var hours: Double = 7
    @State private var initialized = false

    var body: some View {
        let checkIn = appState.checkIn(on: Date())
        VStack(alignment: .leading, spacing: Space.md) {
            HStack {
                Text("😴 Sleep").font(.forgeBodySemibold(15)).foregroundStyle(forge.textPrimary)
                Spacer(minLength: 0)
                if checkIn.sleepConfirmed {
                    Label("Logged", systemImage: "checkmark.circle.fill")
                        .font(.forgeCaption())
                        .foregroundStyle(forge.accent)
                }
            }
            Text("How well did you sleep?")
                .font(.forgeCaption())
                .foregroundStyle(forge.textTertiary)
            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { i in
                    Circle()
                        .fill(i <= quality ? AnyShapeStyle(forge.accent) : AnyShapeStyle(.ultraThinMaterial))
                        .overlay(
                            Circle().stroke(forge.textTertiary.opacity(i <= quality ? 0 : 0.3), lineWidth: 1)
                        )
                        .frame(width: 44, height: 44)
                        .scaleEffect(i <= quality ? 1 : 0.9)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: quality)
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
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .forgeCard()
        .onAppear {
            guard !initialized else { return }
            initialized = true
            if let q = checkIn.sleepQuality { quality = q }
            if let h = checkIn.sleepHours { hours = h }
        }
    }
}

