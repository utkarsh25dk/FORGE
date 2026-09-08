import Foundation

/// A selectable equipment category.
///
/// The library uses 42 distinct equipment strings, most appearing once or twice.
/// Presenting 42 toggles would be unusable, so raw values are folded into the
/// categories people actually think in — "do I own dumbbells", not "do I own a
/// SkiErg". `noneNeeded` is never shown as a toggle: those exercises are always
/// available and are what someone with no equipment at all still sees.
enum EquipmentGroup: String, Codable, CaseIterable, Hashable, Identifiable {
    case noneNeeded
    case dumbbells
    case barbell
    case kettlebell
    case resistanceBands
    case pullUpBar
    case mat
    case foamRoller
    case jumpRope
    case cableMachine
    case weightMachines
    case cardioMachines
    case bicycle
    case pool
    case specialty

    var id: String { rawValue }

    var label: String {
        switch self {
        case .noneNeeded: return "No equipment"
        case .dumbbells: return "Dumbbells"
        case .barbell: return "Barbell & plates"
        case .kettlebell: return "Kettlebell"
        case .resistanceBands: return "Resistance bands"
        case .pullUpBar: return "Pull-up bar"
        case .mat: return "Mat"
        case .foamRoller: return "Foam roller"
        case .jumpRope: return "Jump rope"
        case .cableMachine: return "Cable machine"
        case .weightMachines: return "Weight machines"
        case .cardioMachines: return "Cardio machines"
        case .bicycle: return "Bike"
        case .pool: return "Pool"
        case .specialty: return "Sports & specialty gear"
        }
    }

    var detail: String {
        switch self {
        case .noneNeeded: return "Always available"
        case .dumbbells: return "One pair is enough for most of these"
        case .barbell: return "A bar, plates and somewhere to rack it"
        case .kettlebell: return "Any single bell"
        case .resistanceBands: return "Loop or tube bands"
        case .pullUpBar: return "Doorway or mounted"
        case .mat: return "For floor and yoga work"
        case .foamRoller: return "For rolling and release work"
        case .jumpRope: return "Any rope"
        case .cableMachine: return "Usually gym only"
        case .weightMachines: return "Leg press, curl, extension and similar"
        case .cardioMachines: return "Treadmill, rower, elliptical, stair climber"
        case .bicycle: return "Road, stationary or trail"
        case .pool: return "Access to a pool or open water"
        case .specialty: return "Racquets, gloves, sled, climbing gear and so on"
        }
    }

    var icon: String {
        switch self {
        case .noneNeeded: return "figure.stand"
        case .dumbbells: return "dumbbell.fill"
        case .barbell: return "figure.strengthtraining.traditional"
        case .kettlebell: return "figure.cross.training"
        case .resistanceBands: return "line.diagonal"
        case .pullUpBar: return "figure.play"
        case .mat: return "rectangle.portrait"
        case .foamRoller: return "cylinder.fill"
        case .jumpRope: return "figure.jumprope"
        case .cableMachine: return "cablecar"
        case .weightMachines: return "gearshape.2.fill"
        case .cardioMachines: return "figure.run.treadmill"
        case .bicycle: return "bicycle"
        case .pool: return "figure.pool.swim"
        case .specialty: return "sportscourt.fill"
        }
    }

    /// Everything a user can actually toggle. `noneNeeded` is implicit.
    static var selectable: [EquipmentGroup] { allCases.filter { $0 != .noneNeeded } }
}

enum EquipmentMap {

    /// Raw library equipment string to selectable group. Asserted exhaustive
    /// against the library in tests, so a new exercise with unrecognised
    /// equipment fails loudly rather than silently becoming unavailable.
    private static let map: [String: EquipmentGroup] = [
        "None": .noneNeeded, "Bodyweight": .noneNeeded,
        // A mixed circuit is assembled from whatever is to hand, so it doesn't
        // gate on owning any one thing.
        "Mixed": .noneNeeded,

        "Dumbbell": .dumbbells,
        "Barbell": .barbell,
        "Kettlebell": .kettlebell,
        "Resistance Band": .resistanceBands,
        "Pull-Up Bar": .pullUpBar,
        "Mat": .mat, "Yoga Block": .mat,
        "Foam Roller": .foamRoller,
        "Jump Rope": .jumpRope,
        "Cable": .cableMachine,
        "Machine": .weightMachines,

        "Treadmill": .cardioMachines, "Rower": .cardioMachines,
        "Elliptical": .cardioMachines, "Stair Climber": .cardioMachines,
        "StairMaster": .cardioMachines, "Assault Bike": .cardioMachines,
        "SkiErg": .cardioMachines,

        "Bike": .bicycle, "Mountain Bike": .bicycle, "Gravel Bike": .bicycle,
        "Pool": .pool,

        "Sled": .specialty, "Tire": .specialty, "Sandbag": .specialty,
        "Battle Ropes": .specialty, "Plyo Box": .specialty,
        "Medicine Ball": .specialty, "Racquet": .specialty,
        "Ball Machine": .specialty, "Gloves": .specialty, "Pads": .specialty,
        "Gi": .specialty, "Heavy Bag": .specialty,
        "Climbing Shoes": .specialty, "Harness": .specialty,
        "Campus Board": .specialty, "Frisbee": .specialty, "Kayak": .specialty,
    ]

    static func group(for equipment: String) -> EquipmentGroup {
        map[equipment] ?? .specialty
    }

    /// Raw strings the map covers, so tests can prove nothing falls through.
    static var knownEquipment: Set<String> { Set(map.keys) }
}

extension ExerciseTemplate {
    var equipmentGroup: EquipmentGroup { EquipmentMap.group(for: equipment) }
    /// True when the exercise needs nothing anyone would have to buy.
    var needsNoEquipment: Bool { equipmentGroup == .noneNeeded }
}
