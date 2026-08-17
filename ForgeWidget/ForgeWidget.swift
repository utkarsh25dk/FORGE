import WidgetKit
import SwiftUI

// MARK: - Palette (self-contained; the widget extension doesn't link the app's DesignSystem)

private extension Color {
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

private let fireBgGradient = RadialGradient(
    colors: [Color(hex: "5A2A1A"), Color(hex: "241D15"), Color(hex: "060706")],
    center: .topLeading, startRadius: 0, endRadius: 280
)
private let accent = Color(hex: "FFB03C")
private let hydrationColor = Color(hex: "5CE0D8")
private let sleepColor = Color(hex: "5CA8FF")
private let textPrimary = Color(hex: "F4F7F3")
private let textSecondary = Color(hex: "9BA69C")
private let fireGradient = LinearGradient(
    colors: [Color(hex: "FFB03C"), Color(hex: "FF5C2E"), Color(hex: "FF2D3E")],
    startPoint: .topLeading, endPoint: .bottomTrailing
)

// MARK: - Timeline

struct ForgeWidgetEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetSnapshot
}

struct ForgeWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> ForgeWidgetEntry {
        ForgeWidgetEntry(date: Date(), snapshot: .preview)
    }

    func getSnapshot(in context: Context, completion: @escaping (ForgeWidgetEntry) -> Void) {
        let snapshot = context.isPreview ? .preview : WidgetBridge.read()
        completion(ForgeWidgetEntry(date: Date(), snapshot: snapshot))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ForgeWidgetEntry>) -> Void) {
        let entry = ForgeWidgetEntry(date: Date(), snapshot: WidgetBridge.read())
        let nextRefresh = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date().addingTimeInterval(3600)
        completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
    }
}

// MARK: - Widget

struct ForgeWidget: Widget {
    let kind = "ForgeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ForgeWidgetProvider()) { entry in
            ForgeWidgetView(entry: entry)
        }
        .configurationDisplayName("FORGE")
        .description("Your streak, weekly progress, hydration and sleep at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct ForgeWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: ForgeWidgetEntry

    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                SmallWidgetView(snapshot: entry.snapshot)
            case .systemMedium:
                MediumWidgetView(snapshot: entry.snapshot)
            default:
                LargeWidgetView(snapshot: entry.snapshot)
            }
        }
        .containerBackground(for: .widget) {
            fireBgGradient
        }
    }
}

// MARK: - Small: streak

private struct SmallWidgetView: View {
    let snapshot: WidgetSnapshot

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "flame.fill")
                .font(.system(size: 54))
                .foregroundStyle(fireGradient)
            Text("\(snapshot.streak)")
                .font(.system(size: 46, weight: .bold, design: .rounded))
                .foregroundStyle(textPrimary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Medium: streak + weekly progress

private struct MediumWidgetView: View {
    let snapshot: WidgetSnapshot

    var body: some View {
        HStack(spacing: 20) {
            VStack(spacing: 6) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(fireGradient)
                Text("\(snapshot.streak)")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(textPrimary)
            }
            .frame(maxWidth: .infinity)

            Divider().background(textSecondary.opacity(0.2))

            VStack(spacing: 6) {
                ZStack {
                    RingView(progress: weeklyProgress, color: accent, lineWidth: 6)
                        .frame(width: 46, height: 46)
                    Text("\(snapshot.weeklyWorked)/\(snapshot.weeklyGoal)")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(textPrimary)
                }
                Text("weekly goal")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(textSecondary)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 4)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var weeklyProgress: Double {
        guard snapshot.weeklyGoal > 0 else { return 0 }
        return min(1, Double(snapshot.weeklyWorked) / Double(snapshot.weeklyGoal))
    }
}

// MARK: - Large: streak + weekly progress + hydration + sleep

private struct LargeWidgetView: View {
    let snapshot: WidgetSnapshot

    var body: some View {
        VStack(spacing: 16) {
            MediumWidgetView(snapshot: snapshot)
                .frame(height: 90)

            Divider().background(textSecondary.opacity(0.2))

            HStack(spacing: 20) {
                statBlock(
                    icon: "drop.fill", color: hydrationColor,
                    value: "\(snapshot.hydrationCount)/\(snapshot.hydrationGoal)",
                    label: "hydration"
                )
                statBlock(
                    icon: "moon.stars.fill", color: sleepColor,
                    value: snapshot.sleepConfirmed ? String(format: "%.1f hrs", snapshot.sleepHours ?? 0) : "—",
                    label: "sleep"
                )
            }
        }
        .padding(.vertical, 4)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func statBlock(icon: String, color: Color, value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(color)
            Text(value)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(textPrimary)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Ring

private struct RingView: View {
    var progress: Double
    var color: Color
    var lineWidth: CGFloat

    var body: some View {
        ZStack {
            Circle().stroke(textSecondary.opacity(0.25), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: max(0.0025, min(progress, 1)))
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
    }
}

#Preview(as: .systemSmall) {
    ForgeWidget()
} timeline: {
    ForgeWidgetEntry(date: .now, snapshot: .preview)
}

#Preview(as: .systemMedium) {
    ForgeWidget()
} timeline: {
    ForgeWidgetEntry(date: .now, snapshot: .preview)
}

#Preview(as: .systemLarge) {
    ForgeWidget()
} timeline: {
    ForgeWidgetEntry(date: .now, snapshot: .preview)
}
