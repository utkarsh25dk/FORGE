import Foundation

struct Account: Codable, Identifiable, Hashable {
    let id: String
    var email: String
    var passwordHash: String
    var salt: String
    var displayName: String
    var createdAt: Date
}

enum UnitSystem: String, Codable, CaseIterable, Identifiable {
    case imperial
    case metric
    var id: String { rawValue }
    var label: String { self == .imperial ? "lbs / mi" : "kg / km" }
    var weightUnit: String { self == .imperial ? "lbs" : "kg" }
    var distanceUnit: String { self == .imperial ? "mi" : "km" }
}
