import SwiftUI

// MARK: - Hex color

extension Color {
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)
        let r = Double((value >> 16) & 0xFF) / 255.0
        let g = Double((value >> 8) & 0xFF) / 255.0
        let b = Double(value & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Theme mode

enum ThemeMode: String, Codable, CaseIterable, Identifiable {
    case system, light, dark
    var id: String { rawValue }
    var label: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }
}

final class ThemeManager: ObservableObject {
    @Published var mode: ThemeMode {
        didSet { UserDefaults.standard.set(mode.rawValue, forKey: "forge.themeMode") }
    }

    init() {
        let stored = UserDefaults.standard.string(forKey: "forge.themeMode") ?? ThemeMode.dark.rawValue
        mode = ThemeMode(rawValue: stored) ?? .dark
    }

    var preferredColorScheme: ColorScheme? {
        switch mode {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

// MARK: - Palette

struct ForgeColors {
    let background: Color
    let backgroundGradTop: Color
    let backgroundGradMid: Color
    let backgroundGradBottom: Color
    let surface: Color
    let surfaceGradTop: Color
    let surfaceGradBottom: Color
    let surfaceBorder: Color
    let raised: Color
    let textPrimary: Color
    let textSecondary: Color
    let textTertiary: Color
    let accent: Color
    let accentSoft: Color
    let onAccent: Color
    let success: Color
    let warning: Color
    let danger: Color
    let divider: Color

    var backgroundGradient: LinearGradient {
        LinearGradient(colors: [backgroundGradTop, backgroundGradMid, backgroundGradBottom], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    var cardGradient: LinearGradient {
        LinearGradient(colors: [surfaceGradTop, surfaceGradBottom], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    /// Faint radial variation behind icon "bubbles" — a hint of depth, not a glow.
    var accentGlow: RadialGradient {
        RadialGradient(colors: [accent.opacity(0.18), accent.opacity(0.13)], center: .center, startRadius: 0, endRadius: 34)
    }

    /// Brand fire gradient — streak flame, widgets, and (per this pass) the big screen headings.
    var fireGradient: LinearGradient {
        LinearGradient(
            colors: [Color(hex: "FFB03C"), Color(hex: "FF5C2E"), Color(hex: "FF2D3E")],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    }

    static func current(_ scheme: ColorScheme) -> ForgeColors {
        scheme == .light ? .light : .dark
    }

    static let dark = ForgeColors(
        background: Color(hex: "0A0B0A"),
        backgroundGradTop: Color(hex: "241D15"),
        backgroundGradMid: Color(hex: "14120E"),
        backgroundGradBottom: Color(hex: "060706"),
        surface: Color(hex: "15181A"),
        surfaceGradTop: Color(hex: "1C211D"),
        surfaceGradBottom: Color(hex: "111412"),
        surfaceBorder: Color.white.opacity(0.08),
        raised: Color(hex: "20241F"),
        textPrimary: Color(hex: "F4F7F3"),
        textSecondary: Color(hex: "9BA69C"),
        textTertiary: Color(hex: "656E64"),
        accent: Color(hex: "FFB03C"),
        accentSoft: Color(hex: "FFB03C").opacity(0.16),
        onAccent: Color(hex: "1F1102"),
        success: Color(hex: "FFB03C"),
        warning: Color(hex: "FFC65C"),
        danger: Color(hex: "FF6B5C"),
        divider: Color.white.opacity(0.07)
    )

    static let light = ForgeColors(
        background: Color(hex: "F2F4EF"),
        backgroundGradTop: Color(hex: "FFF9EE"),
        backgroundGradMid: Color(hex: "F6F3E9"),
        backgroundGradBottom: Color(hex: "E9EBE2"),
        surface: Color(hex: "FDFEFC"),
        surfaceGradTop: Color(hex: "FFFFFF"),
        surfaceGradBottom: Color(hex: "F0F2ED"),
        surfaceBorder: Color.black.opacity(0.06),
        raised: Color(hex: "E9ECE5"),
        textPrimary: Color(hex: "13160F"),
        textSecondary: Color(hex: "5B6158"),
        textTertiary: Color(hex: "8B9187"),
        accent: Color(hex: "C2410C"),
        accentSoft: Color(hex: "C2410C").opacity(0.12),
        onAccent: Color(hex: "FFFFFF"),
        success: Color(hex: "C2410C"),
        warning: Color(hex: "9C7217"),
        danger: Color(hex: "B84438"),
        divider: Color.black.opacity(0.05)
    )
}

private struct ForgeColorsKey: EnvironmentKey {
    static let defaultValue: ForgeColors = .dark
}

extension EnvironmentValues {
    var forge: ForgeColors {
        get { self[ForgeColorsKey.self] }
        set { self[ForgeColorsKey.self] = newValue }
    }
}

struct ForgeThemedRoot: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    func body(content: Content) -> some View {
        content.environment(\.forge, ForgeColors.current(colorScheme))
    }
}

extension View {
    /// Injects the resolved palette for the active color scheme into the environment.
    func withForgeTheme() -> some View { modifier(ForgeThemedRoot()) }
}

// MARK: - Typography

extension Font {
    static func forgeDisplay(_ size: CGFloat) -> Font { .custom("SpaceGrotesk-Bold", size: size) }
    static func forgeHeading(_ size: CGFloat) -> Font { .custom("SpaceGrotesk-Bold", size: size) }
    static func forgeHeadingMedium(_ size: CGFloat) -> Font { .custom("SpaceGrotesk-Medium", size: size) }
    static func forgeNumeric(_ size: CGFloat) -> Font { .custom("SpaceGrotesk-Bold", size: size) }
    static func forgeBody(_ size: CGFloat = 16) -> Font { .custom("Manrope-Regular", size: size) }
    static func forgeBodyMedium(_ size: CGFloat = 16) -> Font { .custom("Manrope-Medium", size: size) }
    static func forgeBodySemibold(_ size: CGFloat = 16) -> Font { .custom("Manrope-SemiBold", size: size) }
    static func forgeBodyBold(_ size: CGFloat = 16) -> Font { .custom("Manrope-Bold", size: size) }
    static func forgeCaption(_ size: CGFloat = 13) -> Font { .custom("Manrope-Medium", size: size) }
}

// MARK: - Spacing / radius

enum Space {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
}

enum Radius {
    static let sm: CGFloat = 10
    static let md: CGFloat = 16
    static let lg: CGFloat = 22
    static let pill: CGFloat = 999
}

// MARK: - Card surface

struct ForgeCardBackground: ViewModifier {
    @Environment(\.forge) private var forge
    var padding: CGFloat = Space.lg
    var cornerRadius: CGFloat = Radius.lg
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(forge.cardGradient)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(forge.surfaceBorder, lineWidth: 1)
            )
    }
}

extension View {
    func forgeCard(padding: CGFloat = Space.lg, cornerRadius: CGFloat = Radius.lg) -> some View {
        modifier(ForgeCardBackground(padding: padding, cornerRadius: cornerRadius))
    }
}

// MARK: - Buttons

/// Full-width primary CTA rendered with the system's Liquid Glass material, tinted to brand accent.
struct ForgeGlassPrimary: ViewModifier {
    @Environment(\.forge) private var forge
    func body(content: Content) -> some View {
        content
            .font(.forgeBodySemibold(16))
            .foregroundStyle(forge.onAccent)
            .frame(maxWidth: .infinity, minHeight: 52)
            .buttonStyle(.glassProminent)
            .tint(forge.accent)
    }
}

/// Full-width secondary action rendered with plain (untinted) Liquid Glass material.
struct ForgeGlassSecondary: ViewModifier {
    @Environment(\.forge) private var forge
    func body(content: Content) -> some View {
        content
            .font(.forgeBodySemibold(16))
            .foregroundStyle(forge.textPrimary)
            .frame(maxWidth: .infinity, minHeight: 52)
            .buttonStyle(.glass)
    }
}

extension View {
    func forgeGlassPrimary() -> some View { modifier(ForgeGlassPrimary()) }
    func forgeGlassSecondary() -> some View { modifier(ForgeGlassSecondary()) }
}

struct ForgeDestructiveIconButtonStyle: ButtonStyle {
    @Environment(\.forge) private var forge
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(forge.danger)
            .frame(width: 44, height: 44)
            .contentShape(Rectangle())
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
