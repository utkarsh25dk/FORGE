import SwiftUI

/// On-device AI coach card. Reads Apple Intelligence availability at appear and either
/// shows a generated tip, a short "why not" state the user can act on, or nothing at
/// all when there's genuinely nothing actionable (e.g. an ineligible device).
struct CoachTipCard: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.forge) private var forge

    @State private var status: CoachAvailability = .unavailable
    @State private var tip: CoachTip?
    @State private var isLoading = true
    @State private var isExpanded = false

    var body: some View {
        Group {
            if isLoading {
                loadingCard
            } else if let tip {
                tipCard(tip)
            } else {
                switch status {
                case .appleIntelligenceOff, .modelDownloading:
                    setupCard
                case .ready, .deviceNotEligible, .unavailable:
                    EmptyView()
                }
            }
        }
        .task {
            let result = await CoachEngine.tip(for: appState)
            switch result {
            case .success(let generated):
                tip = generated
            case .failure(let reason):
                status = reason
            }
            isLoading = false
        }
    }

    private var loadingCard: some View {
        HStack(spacing: Space.md) {
            ProgressView()
                .tint(forge.accent)
            Text("Coach is thinking…")
                .font(.forgeBody(14))
                .foregroundStyle(forge.textSecondary)
            Spacer(minLength: 0)
        }
        .forgeCard(padding: Space.md, cornerRadius: Radius.md)
    }

    private func tipCard(_ tip: CoachTip) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) { isExpanded.toggle() }
        } label: {
            HStack(alignment: isExpanded ? .top : .center, spacing: Space.md) {
                ZStack {
                    Circle().fill(forge.raised).frame(width: 32, height: 32)
                    Image(systemName: icon(for: tip.tone))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(forge.accent)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text("Coach").font(.forgeCaption(11)).foregroundStyle(forge.textTertiary)
                    Text(tip.message)
                        .font(.forgeBodyMedium(14))
                        .foregroundStyle(forge.textPrimary)
                        .lineLimit(isExpanded ? nil : 1)
                        .truncationMode(.tail)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.down")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(forge.textTertiary)
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .forgeCard(padding: Space.md, cornerRadius: Radius.md)
    }

    private var setupCard: some View {
        HStack(alignment: .top, spacing: Space.md) {
            Image(systemName: "apple.intelligence")
                .font(.system(size: 18))
                .foregroundStyle(forge.textSecondary)
            VStack(alignment: .leading, spacing: 3) {
                Text(status == .modelDownloading ? "Coach is getting ready" : "AI Coach needs Apple Intelligence")
                    .font(.forgeBodySemibold(13))
                    .foregroundStyle(forge.textPrimary)
                Text(status == .modelDownloading
                     ? "The on-device model is still downloading. Check back shortly."
                     : "Turn it on in Settings for personalized, on-device coaching tips.")
                    .font(.forgeCaption(12))
                    .foregroundStyle(forge.textSecondary)
            }
            Spacer(minLength: 0)
        }
        .forgeCard(padding: Space.md, cornerRadius: Radius.md)
    }

    private func icon(for tone: CoachTone) -> String {
        switch tone {
        case .encouraging: return "hand.thumbsup.fill"
        case .celebratory: return "star.fill"
        case .nudge: return "bell.fill"
        case .informative: return "lightbulb.fill"
        }
    }
}
