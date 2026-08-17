import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.forge) private var forge

    @State private var step = 0
    @State private var weeklyGoal: Double = 4
    @State private var unitSystem: UnitSystem = .imperial
    @State private var themeMode: ThemeMode = .dark

    private let totalSteps = 4

    var body: some View {
        VStack(spacing: Space.xl) {
            HStack(spacing: 6) {
                ForEach(0..<totalSteps, id: \.self) { i in
                    Capsule()
                        .fill(i <= step ? forge.accent : forge.divider)
                        .frame(height: 4)
                }
            }
            .padding(.top, Space.xl)

            Spacer()

            Group {
                switch step {
                case 0: welcomeStep
                case 1: goalStep
                case 2: unitStep
                default: themeStep
                }
            }
            .transition(.opacity.combined(with: .move(edge: .trailing)))
            .id(step)

            Spacer()

            HStack(spacing: Space.md) {
                if step > 0 {
                    Button {
                        withAnimation { step -= 1 }
                    } label: {
                        Text("Back").frame(maxWidth: .infinity)
                    }
                    .forgeGlassSecondary()
                }
                Button {
                    if step == totalSteps - 1 {
                        finish()
                    } else {
                        withAnimation { step += 1 }
                    }
                } label: {
                    Text(step == totalSteps - 1 ? "Start Training" : "Next").frame(maxWidth: .infinity)
                }
                .forgeGlassPrimary()
            }
        }
        .padding(.horizontal, Space.xl)
        .padding(.bottom, Space.xl)
        .forgeScreenBackground()
    }

    private var welcomeStep: some View {
        VStack(spacing: Space.md) {
            Image(systemName: "flame.fill")
                .font(.system(size: 44))
                .foregroundStyle(forge.accent)
            Text("Welcome to FORGE").font(.forgeHeading(26)).foregroundStyle(forge.textPrimary)
            Text("A few quick questions so your plan fits how you train.")
                .font(.forgeBody(15))
                .foregroundStyle(forge.textSecondary)
                .multilineTextAlignment(.center)
        }
    }

    private var goalStep: some View {
        VStack(spacing: Space.lg) {
            Text("Weekly goal").font(.forgeHeading(24)).foregroundStyle(forge.textPrimary)
            Text("How many days a week are you aiming to train?")
                .font(.forgeBody(15)).foregroundStyle(forge.textSecondary)
                .multilineTextAlignment(.center)
            Text("\(Int(weeklyGoal)) days").font(.forgeNumeric(40)).foregroundStyle(forge.accent)
            Slider(value: $weeklyGoal, in: 2...7, step: 1).tint(forge.accent)
        }
    }

    private var unitStep: some View {
        VStack(spacing: Space.lg) {
            Text("Units").font(.forgeHeading(24)).foregroundStyle(forge.textPrimary)
            Text("How should we display weight and distance?")
                .font(.forgeBody(15)).foregroundStyle(forge.textSecondary)
                .multilineTextAlignment(.center)
            HStack(spacing: Space.md) {
                ForEach(UnitSystem.allCases) { system in
                    Button {
                        unitSystem = system
                    } label: {
                        Text(system.label).frame(maxWidth: .infinity)
                    }
                    .forgeGlassPrimary()
                    .opacity(unitSystem == system ? 1 : 0.4)
                }
            }
        }
    }

    private var themeStep: some View {
        VStack(spacing: Space.lg) {
            Text("Appearance").font(.forgeHeading(24)).foregroundStyle(forge.textPrimary)
            Text("Pick your look — you can change this anytime in Profile.")
                .font(.forgeBody(15)).foregroundStyle(forge.textSecondary)
                .multilineTextAlignment(.center)
            VStack(spacing: Space.sm) {
                ForEach(ThemeMode.allCases) { mode in
                    Button {
                        themeMode = mode
                    } label: {
                        HStack {
                            Text(mode.label).font(.forgeBodyMedium(16))
                            Spacer()
                            if themeMode == mode {
                                Image(systemName: "checkmark.circle.fill")
                            }
                        }
                        .foregroundStyle(forge.textPrimary)
                        .padding()
                    }
                    .buttonStyle(.plain)
                    .background(RoundedRectangle(cornerRadius: Radius.md).fill(themeMode == mode ? forge.accentSoft : forge.raised))
                }
            }
        }
    }

    private func finish() {
        appState.userData.weeklyGoal = Int(weeklyGoal)
        appState.userData.unitSystem = unitSystem
        appState.userData.onboardingComplete = true
        themeManager.mode = themeMode
    }
}
