import WidgetKit
import SwiftUI
import AppIntents

// AddWaterIntent lives in the shared WidgetSnapshot.swift (compiled into both the
// app and widget targets) — the app target needs it too so ForgeShortcuts can
// expose it to Siri/Shortcuts, which only works for intents reachable from the app.

// MARK: - Widget

struct ForgeWaterWidget: Widget {
    let kind = "ForgeWaterWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ForgeWaterProvider()) { entry in
            ForgeWaterWidgetView(entry: entry)
        }
        .configurationDisplayName("Water Intake")
        .description("Tap + to log a glass of water without opening the app.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

struct ForgeWaterEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetSnapshot
}

struct ForgeWaterProvider: TimelineProvider {
    func placeholder(in context: Context) -> ForgeWaterEntry {
        ForgeWaterEntry(date: Date(), snapshot: .preview)
    }

    func getSnapshot(in context: Context, completion: @escaping (ForgeWaterEntry) -> Void) {
        let snapshot = context.isPreview ? .preview : WidgetBridge.read()
        completion(ForgeWaterEntry(date: Date(), snapshot: snapshot))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ForgeWaterEntry>) -> Void) {
        let entry = ForgeWaterEntry(date: Date(), snapshot: WidgetBridge.read())
        completion(Timeline(entries: [entry], policy: .never))
    }
}

// MARK: - Views

private extension Color {
    init(waterHex hex: String) {
        let cleaned = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)
        let r = Double((value >> 16) & 0xFF) / 255.0
        let g = Double((value >> 8) & 0xFF) / 255.0
        let b = Double(value & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}

private let waterBgGradient = RadialGradient(
    colors: [Color(waterHex: "1F3A3D"), Color(waterHex: "17242A"), Color(waterHex: "060706")],
    center: .topLeading, startRadius: 0, endRadius: 280
)
private let waterColor = Color(waterHex: "5CE0D8")
private let waterTextPrimary = Color(waterHex: "F4F7F3")
private let waterTextSecondary = Color(waterHex: "9BA69C")

struct ForgeWaterWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: ForgeWaterEntry

    private var isComplete: Bool { entry.snapshot.hydrationCount >= entry.snapshot.hydrationGoal }

    var body: some View {
        Group {
            switch family {
            case .systemMedium:
                mediumBody
            case .accessoryCircular:
                lockScreenCircular
            case .accessoryRectangular:
                lockScreenRectangular
            case .accessoryInline:
                lockScreenInline
            default:
                smallBody
            }
        }
        .containerBackground(for: .widget) {
            if family == .systemSmall || family == .systemMedium {
                waterBgGradient
            }
        }
    }

    // MARK: - Lock Screen

    private var lockScreenCircular: some View {
        Button(intent: AddWaterIntent()) {
            Gauge(value: Double(entry.snapshot.hydrationCount), in: 0...Double(max(entry.snapshot.hydrationGoal, 1))) {
                Image(systemName: "drop.fill")
            } currentValueLabel: {
                Text("\(entry.snapshot.hydrationCount)")
            }
            .gaugeStyle(.accessoryCircularCapacity)
        }
        .buttonStyle(.plain)
    }

    private var lockScreenRectangular: some View {
        Button(intent: AddWaterIntent()) {
            HStack(spacing: 8) {
                Image(systemName: "drop.fill")
                VStack(alignment: .leading, spacing: 1) {
                    Text("Water").font(.system(size: 12, weight: .medium))
                    Text("\(entry.snapshot.hydrationCount)/\(entry.snapshot.hydrationGoal) glasses")
                        .font(.system(size: 15, weight: .semibold))
                }
                Spacer(minLength: 0)
            }
        }
        .buttonStyle(.plain)
    }

    private var lockScreenInline: some View {
        Button(intent: AddWaterIntent()) {
            Label("\(entry.snapshot.hydrationCount)/\(entry.snapshot.hydrationGoal) glasses", systemImage: "drop.fill")
        }
        .buttonStyle(.plain)
    }

    private var smallBody: some View {
        VStack(spacing: 10) {
            HStack(spacing: 4) {
                Image(systemName: "drop.fill").font(.system(size: 12)).foregroundStyle(waterColor)
                Text("Water").font(.system(size: 12, weight: .medium)).foregroundStyle(waterTextSecondary)
                Spacer(minLength: 0)
            }
            Spacer(minLength: 0)
            Text("\(entry.snapshot.hydrationCount)/\(entry.snapshot.hydrationGoal)")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(waterTextPrimary)
            Spacer(minLength: 0)
            addButton(size: 44, iconSize: 18)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var mediumBody: some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    Image(systemName: "drop.fill").font(.system(size: 13)).foregroundStyle(waterColor)
                    Text("Water intake").font(.system(size: 13, weight: .medium)).foregroundStyle(waterTextSecondary)
                }
                Text("\(entry.snapshot.hydrationCount)/\(entry.snapshot.hydrationGoal) glasses")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(waterTextPrimary)
                Text(isComplete ? "Goal hit today" : "Tap + for one glass")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(waterTextSecondary)
            }
            Spacer(minLength: 0)
            addButton(size: 56, iconSize: 22)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func addButton(size: CGFloat, iconSize: CGFloat) -> some View {
        Button(intent: AddWaterIntent()) {
            Image(systemName: isComplete ? "checkmark" : "plus")
                .font(.system(size: iconSize, weight: .bold))
                .foregroundStyle(Color.black)
                .frame(width: size, height: size)
                .background(Circle().fill(waterColor))
        }
        .buttonStyle(.plain)
    }
}

#Preview(as: .systemSmall) {
    ForgeWaterWidget()
} timeline: {
    ForgeWaterEntry(date: .now, snapshot: .preview)
}

#Preview(as: .systemMedium) {
    ForgeWaterWidget()
} timeline: {
    ForgeWaterEntry(date: .now, snapshot: .preview)
}
