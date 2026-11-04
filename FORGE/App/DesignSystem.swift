import SwiftUI

// The four rules this file exists to hold. They are cheap to state and expensive to
// rediscover, so they live here rather than in a document nobody opens.
//
// 1. Two colours, two jobs. `accent` is what you *do* — taps, selection, the brand's
//    own fire. `success` is what you *did* — a ticked exercise, a PR, an earned badge,
//    the green of the contribution calendar. Never swap them: the palette turns to
//    noise the moment a button and a checkmark are the same colour. `fireGradient`
//    stays reserved for one hero moment per screen (see its own note below), because
//    two gradients on one screen is not twice the emphasis, it is none.
// 2. Flat surfaces. A surface is a flat fill plus a hairline border — never a glow
//    halo, never a gradient fill. `forgeCard()` is the only card surface; depth comes
//    from the border and the background behind it. (The screen background's gradient
//    and grain are atmosphere behind content, not a surface, and are exempt.)
// 3. SF Symbols only. Never an emoji as a UI icon: emoji do not inherit tint, do not
//    scale with Dynamic Type, and render differently per platform version.
// 4. Hierarchy comes from type, not colour. Rank things with the size and weight of
//    the scale below plus the three text tiers. Colour marks *kind* — accent for
//    interactive, danger for destructive, the data hues for series — never rank.

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

extension Color {
    /// Black or white, whichever is legible on this colour.
    ///
    /// The contribution ramp runs dark-green to bright-green, so a single text colour
    /// fails at one end or the other — and which end flips between themes. Measuring
    /// the fill is self-maintaining: change the ramp and the numerals follow.
    var readableForeground: Color { Color.ink(legibleOn: [self]) }

    var relativeLuminance: Double {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        UIColor(self).getRed(&r, green: &g, blue: &b, alpha: &a)
        func channel(_ c: CGFloat) -> Double {
            let v = Double(c)
            return v <= 0.03928 ? v / 12.92 : pow((v + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * channel(r) + 0.7152 * channel(g) + 0.0722 * channel(b)
    }

    /// The theme ink that stays legible on every colour it might sit on, picked by the
    /// worst case: a numeral spanning two bands has to clear both of them.
    ///
    /// This compares the two inks rather than testing luminance against a threshold.
    /// A threshold has to be guessed, and the guess here was 0.4 when the crossover is
    /// nearer 0.18 — which put white text on mid blues and greens that wanted black.
    static func ink(legibleOn colors: [Color]) -> Color {
        let dark = Color(hex: "0A0B0A")
        let light = Color(hex: "F4F7F3")
        func worstContrast(_ ink: Color) -> Double {
            let a = ink.relativeLuminance
            return colors.map { color in
                let b = color.relativeLuminance
                return (max(a, b) + 0.05) / (min(a, b) + 0.05)
            }.min() ?? 1
        }
        return worstContrast(dark) >= worstContrast(light) ? dark : light
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
    let surfaceBorder: Color
    let raised: Color
    let textPrimary: Color
    let textSecondary: Color
    let textTertiary: Color
    let accent: Color
    let accentSoft: Color
    let onAccent: Color
    /// Achievement green, keyed to the contribution calendar. Everything marking work
    /// already banked uses this; `accent` marks work you can start. A warning is amber
    /// rather than accent so a caution never looks like just another button.
    let success: Color
    let warning: Color
    let danger: Color
    let divider: Color
    /// Data-series colors for the weekly charts — semantic per-metric hues,
    /// deliberately distinct from `accent` (dataviz: series color != brand accent).
    let dataSleep: Color
    let dataHydration: Color
    /// Calendar day-status colors — worked/rest are distinct hues (missed reuses
    /// `danger`) so the streak calendar reads at a glance instead of by weight.
    let dayWorked: Color
    let dayRest: Color
    /// Contribution ramp, lowest to highest: index 0 is a day with nothing on it,
    /// 1...4 are increasing training volume. Intensity encodes *how much* you did,
    /// which is the one thing a year of squares can show that a status cannot.
    let contribution: [Color]
    /// Colours for the training families the calendar sorts days into, indexed by
    /// `TrainingFamily.rawValue`. Six, not ten: a grid with ten hues is confetti.
    let family: [Color]

    var backgroundGradient: LinearGradient {
        LinearGradient(colors: [backgroundGradTop, backgroundGradMid, backgroundGradBottom], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    /// Brand fire gradient. Reserved for exactly one hero moment per screen —
    /// the streak flame/number — never applied to headings, icons, or other
    /// numbers by default. Everything else uses flat `accent` or `textPrimary`.
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
        backgroundGradTop: Color(hex: "1C211D"),
        backgroundGradMid: Color(hex: "15181A"),
        backgroundGradBottom: Color(hex: "0A0B0A"),
        surface: Color(hex: "15181A"),
        surfaceBorder: Color.white.opacity(0.08),
        raised: Color(hex: "20241F"),
        textPrimary: Color(hex: "F4F7F3"),
        textSecondary: Color(hex: "9BA69C"),
        textTertiary: Color(hex: "656E64"),
        accent: Color(hex: "FA5F4A"),
        accentSoft: Color(hex: "FA5F4A").opacity(0.16),
        onAccent: Color(hex: "1F1102"),
        success: Color(hex: "3FB950"),
        warning: Color(hex: "D29922"),
        danger: Color(hex: "FF6B5C"),
        divider: Color.white.opacity(0.07),
        dataSleep: Color(hex: "5CA8FF"),
        dataHydration: Color(hex: "5CE0D8"),
        dayWorked: Color(hex: "26A641"),
        dayRest: Color(hex: "6E7681"),
        contribution: [
            Color(hex: "1E2224"),
            Color(hex: "0E4429"),
            Color(hex: "006D32"),
            Color(hex: "26A641"),
            Color(hex: "39D353")
        ],
        family: [
            Color(hex: "3FB950"),
            Color(hex: "58A6FF"),
            Color(hex: "39C5CF"),
            Color(hex: "D29922"),
            Color(hex: "6E7681")
        ]
    )

    static let light = ForgeColors(
        background: Color(hex: "F2F4EF"),
        backgroundGradTop: Color(hex: "FDFEFC"),
        backgroundGradMid: Color(hex: "F7F8F5"),
        backgroundGradBottom: Color(hex: "F0F1ED"),
        surface: Color(hex: "FDFEFC"),
        surfaceBorder: Color.black.opacity(0.06),
        raised: Color(hex: "E9ECE5"),
        textPrimary: Color(hex: "13160F"),
        textSecondary: Color(hex: "5B6158"),
        textTertiary: Color(hex: "8B9187"),
        accent: Color(hex: "C2410C"),
        accentSoft: Color(hex: "C2410C").opacity(0.12),
        onAccent: Color(hex: "FFFFFF"),
        success: Color(hex: "1A7F37"),
        warning: Color(hex: "9A6700"),
        danger: Color(hex: "B84438"),
        divider: Color.black.opacity(0.05),
        dataSleep: Color(hex: "2B6CB0"),
        dataHydration: Color(hex: "0E8074"),
        dayWorked: Color(hex: "2DA44E"),
        dayRest: Color(hex: "656D76"),
        contribution: [
            Color(hex: "EBEDF0"),
            Color(hex: "9BE9A8"),
            Color(hex: "40C463"),
            Color(hex: "30A14E"),
            Color(hex: "216E39")
        ],
        family: [
            Color(hex: "1A7F37"),
            Color(hex: "0969DA"),
            Color(hex: "1B7C83"),
            Color(hex: "9A6700"),
            Color(hex: "656D76")
        ]
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
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
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
                    .fill(forge.surface)
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

/// Quiet until touched. A delete sits on every row of a list, so painting it `danger`
/// at rest turns the whole right edge red and drowns out the green that marks work done.
/// The glyph keeps the affordance; the colour arrives when the press does.
struct ForgeDestructiveIconButtonStyle: ButtonStyle {
    @Environment(\.forge) private var forge
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(configuration.isPressed ? forge.danger : forge.textTertiary)
            .frame(width: 44, height: 44)
            .contentShape(Rectangle())
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
