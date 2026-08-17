import Foundation
import WidgetKit
import ActivityKit
import AppIntents

/// Shared Live Activity attributes for an in-progress workout session —
/// visible to both the app (starts/updates/ends the Activity) and the widget
/// extension (renders the Dynamic Island / Lock Screen UI).
struct WorkoutActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var exerciseName: String
        var exerciseIndex: Int
        var totalExercises: Int
        var isResting: Bool
        var restEndDate: Date?
    }
    var startedAt: Date
}

/// Compact copy of the data the home screen widget needs, written by the app
/// and read by the widget extension via a shared App Group container.
struct WidgetSnapshot: Codable {
    var streak: Int
    var weeklyWorked: Int
    var weeklyGoal: Int
    var hydrationCount: Int
    var hydrationGoal: Int
    var sleepQuality: Int?
    var sleepHours: Double?
    var sleepConfirmed: Bool
    /// Glasses tapped in from the widget's own "+" button since the app last synced.
    /// The widget bumps `hydrationCount` immediately for its own display, but the app
    /// is the source of truth — it drains this queue into a real check-in on next launch/foreground.
    var pendingHydrationTaps: Int = 0
    var updatedAt: Date

    static let empty = WidgetSnapshot(
        streak: 0, weeklyWorked: 0, weeklyGoal: 4,
        hydrationCount: 0, hydrationGoal: 8,
        sleepQuality: nil, sleepHours: nil, sleepConfirmed: false,
        updatedAt: .distantPast
    )

    static let preview = WidgetSnapshot(
        streak: 6, weeklyWorked: 3, weeklyGoal: 4,
        hydrationCount: 5, hydrationGoal: 8,
        sleepQuality: 4, sleepHours: 7.5, sleepConfirmed: true,
        updatedAt: Date()
    )
}

enum WidgetBridge {
    static let appGroupId = "group.com.utkarsh25rk.forge"
    private static let key = "forge.widgetSnapshot"

    static func write(_ snapshot: WidgetSnapshot) {
        guard let defaults = UserDefaults(suiteName: appGroupId),
              let data = try? JSONEncoder.forgeWidget.encode(snapshot) else { return }
        defaults.set(data, forKey: key)
    }

    static func read() -> WidgetSnapshot {
        guard let defaults = UserDefaults(suiteName: appGroupId),
              let data = defaults.data(forKey: key),
              let snapshot = try? JSONDecoder.forgeWidget.decode(WidgetSnapshot.self, from: data)
        else { return .empty }
        return snapshot
    }

    /// Called from the widget's own "+" button intent — runs in the widget extension process,
    /// so it can't touch AppState directly. Bumps the widget's own display count and queues the
    /// tap for the app to fold into a real check-in next time it launches or comes to the foreground.
    static func incrementHydration() {
        var snapshot = read()
        guard snapshot.hydrationCount < snapshot.hydrationGoal else { return }
        snapshot.hydrationCount += 1
        snapshot.pendingHydrationTaps += 1
        snapshot.updatedAt = Date()
        write(snapshot)
        WidgetCenter.shared.reloadAllTimelines()
    }
}

/// Increments hydration by one glass. Used by the widget's own "+" button (runs in the
/// widget extension process) and, via ForgeShortcuts, by Siri/Shortcuts (runs in the app).
struct AddWaterIntent: AppIntent {
    static var title: LocalizedStringResource = "Add a Glass of Water"
    static var description = IntentDescription("Logs one glass of water in FORGE without opening the app.")

    func perform() async throws -> some IntentResult {
        WidgetBridge.incrementHydration()
        return .result()
    }
}

extension JSONEncoder {
    static let forgeWidget: JSONEncoder = {
        let enc = JSONEncoder()
        enc.dateEncodingStrategy = .iso8601
        return enc
    }()
}

extension JSONDecoder {
    static let forgeWidget: JSONDecoder = {
        let dec = JSONDecoder()
        dec.dateDecodingStrategy = .iso8601
        return dec
    }()
}
