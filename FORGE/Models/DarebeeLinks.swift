import Foundation

/// Links out to DAREBEE's video demonstrations for the exercises they cover.
///
/// DAREBEE is a free, ad-free, donation-supported fitness resource. Their
/// materials are CC BY-NC-ND, so none of their content is copied into FORGE —
/// but their terms explicitly welcome linking, and a video of a movement is
/// something written guidance cannot replace.
///
/// Every entry here was checked against the exercise's own description rather
/// than matched on name. That matters: their "Leg Extensions" is a donkey kick
/// on all fours, not the seated machine movement, and their "Leg Swings" is a
/// kneeling quadruped swing rather than a standing warm-up. Both were dropped.
/// Their library is bodyweight-only, so it covers a small slice of FORGE's, and
/// a wrong link mid-workout is worse than no link.
enum DarebeeLinks {

    static let attribution = "Video demonstrations by DAREBEE, a free non-profit fitness resource."
    static let homeURL = URL(string: "https://darebee.com")!
    static let libraryURL = URL(string: "https://darebee.com/library.html")!

    private static let slugs: [String: String] = [
        // Upper body
        "ub-chest-3":     "push-ups",

        // Lower body
        "lb-glutes-2":    "bridges",

        // Full body
        "fb-circuit-1":   "burpees",
        "fb-circuit-2":   "climbers",
        "fb-circuit-3":   "jumping-jacks",
        "fb-flow-3":      "plank-jacks",

        // Core
        "core-upper-1":   "crunches",
        "core-upper-2":   "sit-ups",
        "core-lower-1":   "leg-raises",
        "core-lower-2":   "reverse-crunches",
        "core-lower-3":   "flutter-kicks",
        "core-deep-1":    "elbow-plank-hold",
        "core-deep-2":    "dead-bug",
        "core-oblique-2": "side-elbow-plank-hold",
        "core-lowback-1": "superman-stretch",

        // Flexibility
        "flex-dyn-2":     "arms-circles",
    ]

    static func url(for exerciseId: String) -> URL? {
        guard let slug = slugs[exerciseId] else { return nil }
        return URL(string: "https://darebee.com/exercises/\(slug).html")
    }

    /// Exercise ids covered, so tests can prove none has gone stale.
    static var coveredIds: [String] { slugs.keys.sorted() }
}

extension ExerciseTemplate {
    var darebeeURL: URL? { DarebeeLinks.url(for: id) }
}
