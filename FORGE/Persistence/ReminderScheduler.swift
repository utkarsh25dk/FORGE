import Foundation
import UserNotifications

/// Evening check-in nudge — fires at 8pm only if hydration, sleep, or today's workout/rest
/// day hasn't been logged yet. Re-evaluated (cancel + maybe reschedule) on every relevant
/// data change, so it never fires once everything for the day is already covered.
enum ReminderScheduler {
    private static let key = "forge.eveningReminderEnabled"
    private static let requestId = "forge.eveningReminder"

    static var isEnabled: Bool {
        UserDefaults.standard.bool(forKey: key)
    }

    static func setEnabled(_ enabled: Bool, hydrationDone: Bool, sleepDone: Bool, workoutLoggedToday: Bool, completion: @escaping (Bool) -> Void) {
        if enabled {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                DispatchQueue.main.async {
                    UserDefaults.standard.set(granted, forKey: key)
                    if granted { evaluate(hydrationDone: hydrationDone, sleepDone: sleepDone, workoutLoggedToday: workoutLoggedToday) }
                    completion(granted)
                }
            }
        } else {
            UserDefaults.standard.set(false, forKey: key)
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [requestId])
            completion(false)
        }
    }

    static func evaluate(hydrationDone: Bool, sleepDone: Bool, workoutLoggedToday: Bool) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [requestId])
        guard isEnabled, !(hydrationDone && sleepDone && workoutLoggedToday) else { return }

        var comps = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        comps.hour = 20
        comps.minute = 0
        guard let fireDate = Calendar.current.date(from: comps), fireDate > Date() else { return }

        var missing: [String] = []
        if !hydrationDone { missing.append("log your water") }
        if !sleepDone { missing.append("log last night's sleep") }
        if !workoutLoggedToday { missing.append("log today's workout or mark it a rest day") }

        let body: String
        switch missing.count {
        case 1:
            body = "Don't forget to \(missing[0]) before the day ends."
        case 2:
            body = "Don't forget to \(missing[0]) and \(missing[1])."
        default:
            body = "Stay on track — log your water, last night's sleep, and today's workout or rest day."
        }

        let content = UNMutableNotificationContent()
        content.title = "Evening check-in"
        content.body = body
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.hour, .minute], from: fireDate),
            repeats: false
        )
        let request = UNNotificationRequest(identifier: requestId, content: content, trigger: trigger)
        center.add(request)
    }
}
