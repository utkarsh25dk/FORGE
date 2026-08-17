import SwiftUI

struct RestTimerView: View {
    @Environment(\.forge) private var forge
    @State var remaining: Int
    var title: String = "Rest"
    var onFinish: () -> Void

    private let total: Int
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    init(remaining: Int, title: String = "Rest", onFinish: @escaping () -> Void) {
        _remaining = State(initialValue: remaining)
        self.total = max(remaining, 1)
        self.title = title
        self.onFinish = onFinish
    }

    var body: some View {
        VStack(spacing: Space.lg) {
            Text(title).font(.forgeHeadingMedium(16)).foregroundStyle(forge.textSecondary)
            ZStack {
                ProgressRing(progress: 1 - (Double(remaining) / Double(total)), lineWidth: 10)
                    .frame(width: 140, height: 140)
                Text("\(remaining)s")
                    .font(.forgeNumeric(36))
                    .foregroundStyle(forge.textPrimary)
            }
            HStack(spacing: Space.md) {
                Button {
                    remaining = max(0, remaining - 15)
                } label: {
                    Text("-15s").frame(maxWidth: .infinity)
                }
                .forgeGlassSecondary()
                Button {
                    remaining += 15
                } label: {
                    Text("+15s").frame(maxWidth: .infinity)
                }
                .forgeGlassSecondary()
            }
            Button("Skip", action: onFinish)
                .font(.forgeBodyMedium(14))
                .foregroundStyle(forge.accent)
        }
        .padding(Space.xl)
        .forgeCard()
        .onReceive(timer) { _ in
            guard remaining > 0 else { return }
            remaining -= 1
            if remaining == 0 { onFinish() }
        }
    }
}
