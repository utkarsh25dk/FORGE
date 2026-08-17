import Foundation

enum WorkoutEntryDisplay {
    static func summary(_ e: WorkoutEntry, unit: UnitSystem) -> String {
        switch e.kind {
        case .strength:
            let w = e.weight ?? 0
            let weightPart = w > 0 ? " @ \(Int(w)) \(unit.weightUnit)" : ""
            return "\(e.sets ?? 0) × \(e.reps ?? 0)\(weightPart)"
        case .cardio:
            var parts = ["\(e.durationMin ?? 0) min"]
            if let incline = e.inclinePercent, incline > 0 { parts.append("\(incline)% incline") }
            if let intensity = e.intensity { parts.append("RPE \(intensity)") }
            return parts.joined(separator: " · ")
        case .hold:
            return "\(e.sets ?? 1) × \(e.holdSec ?? 0)s hold"
        case .distance:
            let dist = e.distanceMiles ?? 0
            return "\(String(format: "%.1f", dist)) \(unit.distanceUnit) · \(e.durationMin ?? 0) min"
        case .interval:
            return "\(e.rounds ?? 0) rounds · \(e.workSec ?? 0)s on / \(e.restSec ?? 0)s off"
        case .session:
            var parts = ["\(e.durationMin ?? 0) min"]
            if let intensity = e.intensity { parts.append("RPE \(intensity)") }
            return parts.joined(separator: " · ")
        }
    }
}
