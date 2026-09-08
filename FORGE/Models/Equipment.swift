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
    case dipBars
    case bench
    case adjustableBench
    case squatRack
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
        case .dipBars: return "Dip bars"
        case .bench: return "Flat bench"
        case .adjustableBench: return "Adjustable bench"
        case .squatRack: return "Squat rack"
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
        case .dipBars: return "Parallel bars or a dip station"
        case .bench: return "Any sturdy flat bench or box"
        case .adjustableBench: return "Tilts for incline work"
        case .squatRack: return "Rack or stands to unrack a loaded bar"
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
        case .dipBars: return "figure.parallel.bars"
        case .bench: return "chair.lounge.fill"
        case .adjustableBench: return "chair.lounge"
        case .squatRack: return "square.split.2x1"
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

    /// Groups this one also satisfies. An adjustable bench is a flat bench with
    /// a hinge, so owning one shouldn't mean ticking both.
    var implies: Set<EquipmentGroup> {
        switch self {
        case .adjustableBench: return [.bench]
        default: return []
        }
    }
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

/// Equipment an exercise needs *in addition* to its primary tag.
///
/// The library records one equipment string per exercise, which is not enough:
/// an Incline Dumbbell Press is tagged "Dumbbell" but is impossible without an
/// adjustable bench, and Pull-Ups are tagged "Bodyweight" but need a bar. Telling
/// someone with a pair of dumbbells and no bench that they can do it is worse
/// than not filtering at all.
enum ExerciseRequirements {

    static let additional: [String: [EquipmentGroup]] = [
        // Bench work
        "ub-chest-1":  [.bench, .squatRack],   // Barbell Bench Press
        "ub-chest-2":  [.adjustableBench],     // Incline Dumbbell Press
        "ub-chest-5":  [.bench],               // Dumbbell Pullover
        "ub-back-5":   [.bench],               // Single-Arm Dumbbell Row
        "ub-biceps-3": [.adjustableBench],     // Incline Dumbbell Curl
        "ub-biceps-5": [.bench],               // Concentration Curl
        "ub-triceps-1":[.bench, .squatRack],   // Close-Grip Bench Press
        "ub-triceps-3":[.bench],               // Skull Crushers
        "lb-glutes-1": [.bench],               // Hip Thrust
        "lb-glutes-5": [.bench],               // Step-Ups — a bench doubles as the box
        "lb-quads-5":  [.bench],               // Bulgarian Split Squat

        // A loaded bar on your back has to come off something
        "lb-quads-1":  [.squatRack],           // Barbell Back Squat
        "lb-hams-3":   [.squatRack],           // Good Mornings
        "core-lowback-3": [.squatRack],        // Good Morning

        // Tagged bodyweight, but you cannot do them on the floor
        "ub-back-1":   [.pullUpBar],           // Pull-Ups
        "ub-triceps-5":[.dipBars],             // Dips
    ]

    static func requirements(for id: String) -> [EquipmentGroup] { additional[id] ?? [] }
}

extension ExerciseTemplate {
    var equipmentGroup: EquipmentGroup { EquipmentMap.group(for: equipment) }
    /// Everything needed to perform this: the primary group plus any extras.
    var requiredEquipment: Set<EquipmentGroup> {
        var set = Set(ExerciseRequirements.requirements(for: id))
        if !needsNoEquipment { set.insert(equipmentGroup) }
        return set
    }
    /// True when the exercise needs nothing anyone would have to buy.
    var needsNoEquipment: Bool { equipmentGroup == .noneNeeded }
}
