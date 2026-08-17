import SwiftUI

// MARK: - Section header

struct SectionHeader: View {
    @Environment(\.forge) private var forge
    var title: String
    var subtitle: String? = nil
    var trailing: (() -> AnyView)? = nil

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.forgeHeading(20))
                    .foregroundStyle(forge.textPrimary)
                if let subtitle {
                    Text(subtitle)
                        .font(.forgeCaption())
                        .foregroundStyle(forge.textSecondary)
                }
            }
            Spacer()
            if let trailing { trailing() }
        }
    }
}

// MARK: - Chip

struct ForgeChip: View {
    @Environment(\.forge) private var forge
    var label: String
    var systemImage: String? = nil
    var isSelected: Bool = false
    var tint: Color? = nil

    var body: some View {
        HStack(spacing: 6) {
            if let systemImage {
                Image(systemName: systemImage).font(.system(size: 12, weight: .semibold))
            }
            Text(label).font(.forgeBodyMedium(14))
        }
        .padding(.horizontal, Space.md)
        .padding(.vertical, 8)
        .foregroundStyle(isSelected ? forge.onAccent : forge.textPrimary)
        .background(
            Capsule().fill(isSelected ? (tint ?? forge.accent) : forge.raised)
        )
        .overlay(
            Capsule().stroke(isSelected ? Color.clear : forge.surfaceBorder, lineWidth: 1)
        )
    }
}

// MARK: - Empty state

struct EmptyStateView: View {
    @Environment(\.forge) private var forge
    var icon: String
    var title: String
    var message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: Space.md) {
            ZStack {
                Circle().fill(forge.accentSoft).frame(width: 64, height: 64)
                Image(systemName: icon)
                    .font(.system(size: 26, weight: .medium))
                    .foregroundStyle(forge.accent)
            }
            VStack(spacing: 4) {
                Text(title).font(.forgeHeadingMedium(17)).foregroundStyle(forge.textPrimary)
                Text(message)
                    .font(.forgeBody(14))
                    .foregroundStyle(forge.textSecondary)
                    .multilineTextAlignment(.center)
            }
            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle).frame(maxWidth: .infinity)
                }
                .forgeGlassSecondary()
                .frame(maxWidth: 220)
            }
        }
        .padding(Space.xl)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Category icon

/// Bold icon on a soft tinted circle — the two-tone "badge" look used everywhere
/// a WorkoutCategory icon is shown, in place of a bare flat system-image glyph.
struct CategoryIcon: View {
    @Environment(\.forge) private var forge
    var systemName: String
    var size: CGFloat = 20
    var circleSize: CGFloat? = nil
    var tint: Color? = nil

    var body: some View {
        let color = tint ?? forge.accent
        let circle = circleSize ?? size * 1.8
        ZStack {
            Circle()
                .fill(color.opacity(0.16))
                .frame(width: circle, height: circle)
            Image(systemName: systemName)
                .font(.system(size: size, weight: .bold))
                .foregroundStyle(color)
        }
        .frame(width: circle, height: circle)
    }
}

// MARK: - Progress ring

struct ProgressRing: View {
    @Environment(\.forge) private var forge
    var progress: Double // 0...1
    var lineWidth: CGFloat = 10
    var ringColor: Color? = nil

    var body: some View {
        ZStack {
            Circle()
                .stroke(forge.divider, lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: max(0.0025, min(progress, 1)))
                .stroke(ringColor ?? forge.accent, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
    }
}

// MARK: - Stat tile

struct StatTile: View {
    @Environment(\.forge) private var forge
    var value: String
    var label: String
    var icon: String
    var tint: Color? = nil

    var body: some View {
        VStack(spacing: Space.sm) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(tint ?? forge.accent)
            Text(value)
                .font(.forgeNumeric(22))
                .foregroundStyle(forge.textPrimary)
                .monospacedDigit()
                .contentTransition(.numericText())
                .animation(.default, value: value)
            Text(label)
                .font(.forgeCaption())
                .foregroundStyle(forge.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .forgeCard(padding: Space.md, cornerRadius: Radius.md)
    }
}

// MARK: - Text field style

struct ForgeTextFieldStyle: TextFieldStyle {
    @Environment(\.forge) private var forge
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.forgeBody(16))
            .foregroundStyle(forge.textPrimary)
            .padding(.horizontal, Space.md)
            .frame(height: 50)
            .background(RoundedRectangle(cornerRadius: Radius.sm, style: .continuous).fill(forge.raised))
            .overlay(RoundedRectangle(cornerRadius: Radius.sm, style: .continuous).stroke(forge.surfaceBorder, lineWidth: 1))
    }
}

// MARK: - Password field with show/hide toggle

struct PasswordField: View {
    @Environment(\.forge) private var forge
    var placeholder: String
    @Binding var text: String
    @State private var isVisible = false

    var body: some View {
        HStack(spacing: Space.sm) {
            Group {
                if isVisible {
                    TextField(placeholder, text: $text)
                } else {
                    SecureField(placeholder, text: $text)
                }
            }
            .font(.forgeBody(16))
            .foregroundStyle(forge.textPrimary)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()

            Button {
                isVisible.toggle()
            } label: {
                Image(systemName: isVisible ? "eye.slash" : "eye")
                    .foregroundStyle(forge.textSecondary)
                    .font(.system(size: 15))
            }
            .buttonStyle(.plain)
            .frame(width: 32, height: 32)
        }
        .padding(.horizontal, Space.md)
        .frame(height: 50)
        .background(RoundedRectangle(cornerRadius: Radius.sm, style: .continuous).fill(forge.raised))
        .overlay(RoundedRectangle(cornerRadius: Radius.sm, style: .continuous).stroke(forge.surfaceBorder, lineWidth: 1))
    }
}

// MARK: - Screen background

struct ForgeScreenBackground: ViewModifier {
    @Environment(\.forge) private var forge
    func body(content: Content) -> some View {
        ZStack {
            forge.backgroundGradient.ignoresSafeArea()
            Image("GrainTexture")
                .resizable(resizingMode: .tile)
                .opacity(0.05)
                .blendMode(.overlay)
                .allowsHitTesting(false)
                .ignoresSafeArea()
            content
        }
    }
}

extension View {
    func forgeScreenBackground() -> some View { modifier(ForgeScreenBackground()) }
}

// MARK: - Toast

struct ForgeToast: View {
    @Environment(\.forge) private var forge
    var message: String
    var icon: String = "checkmark.circle.fill"

    var body: some View {
        HStack(spacing: Space.sm) {
            Image(systemName: icon).foregroundStyle(forge.accent)
            Text(message).font(.forgeBodyMedium(14)).foregroundStyle(forge.textPrimary)
        }
        .padding(.horizontal, Space.lg)
        .padding(.vertical, Space.md)
        .background(Capsule().fill(forge.raised))
        .overlay(Capsule().stroke(forge.surfaceBorder, lineWidth: 1))
        .shadow(color: .black.opacity(0.16), radius: 8, y: 3)
    }
}
