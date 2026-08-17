import Foundation

struct DailyCheckIn: Codable, Hashable {
    var date: Date
    var hydrationCount: Int = 0
    var sleepQuality: Int? = nil     // 1-5
    var sleepHours: Double? = nil
    var sleepConfirmed: Bool = false

    static let hydrationGoal = 8
}

struct BodyMeasurementEntry: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var date: Date
    var weight: Double?      // canonical lbs
    var waist: Double?
    var chest: Double?
    var arms: Double?
    var hips: Double?
    var thighs: Double?
}
