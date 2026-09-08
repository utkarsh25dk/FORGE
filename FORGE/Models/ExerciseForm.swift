import Foundation

/// How to actually perform an exercise. FORGE ships one coaching tip per exercise,
/// which tells you how to progress but not how to do the movement — this is the
/// rest of that answer.
///
/// Every field except `steps` is optional, and an exercise with no entry at all is
/// valid: guidance is authored in batches, so the UI has to read partial coverage
/// without looking broken.
struct ExerciseForm: Hashable {
    /// The movement, start to finish. One instruction per step.
    var steps: [String]
    /// When to inhale and exhale. Omitted where it doesn't matter.
    var breathing: String? = nil
    /// The specific ways this movement goes wrong — worth more than restating the ideal.
    var mistakes: [String] = []
    /// A regression for someone who can't do it yet.
    var easier: String? = nil
    /// A progression for when it stops being hard.
    var harder: String? = nil
}

/// Form guidance keyed by exercise id.
///
/// Keyed by id rather than declared inline in `ExerciseLibrary`, for the same
/// reason `ExerciseAttributeTable` is: that file stays a clean list of 250
/// one-line definitions, and guidance can land incrementally without touching it.
enum ExerciseFormLibrary {

    static func form(for id: String) -> ExerciseForm? { forms[id] }

    /// How much of the library has guidance written. Surfaced so the gap is
    /// measurable rather than a vague "some exercises have it".
    static var coverage: (written: Int, total: Int) {
        (forms.count, ExerciseLibrary.all.count)
    }

    /// Ids present here that no longer exist in the library — a typo or a renamed
    /// exercise would otherwise sit undetected as guidance nothing can reach.
    static var orphanedIds: [String] {
        let known = Set(ExerciseLibrary.all.map(\.id))
        return forms.keys.filter { !known.contains($0) }.sorted()
    }

    private static let forms: [String: ExerciseForm] = [

        // MARK: Upper body

        "ub-chest-1": ExerciseForm(       // Barbell Bench Press
            steps: [
                "Lie back with your eyes directly under the bar and plant both feet flat on the floor.",
                "Pull your shoulder blades together and down into the bench, and keep them there for every rep.",
                "Grip a little wider than shoulder width and unrack to a point directly over your shoulders.",
                "Lower the bar under control to your lower chest, keeping elbows about 45 degrees from your torso.",
                "Touch the chest without bouncing, then press back up and slightly toward your face."
            ],
            breathing: "Breathe in as the bar comes down, brace, and breathe out as you press through the hardest part.",
            mistakes: [
                "Flaring the elbows straight out to the sides, which puts the shoulder in its weakest position.",
                "Letting the shoulder blades come apart at the bottom, so the chest loses its base.",
                "Bouncing the bar off the ribcage to get through the sticking point."
            ],
            easier: "Press dumbbells instead — they let each arm find its own path and are easy to drop safely.",
            harder: "Pause the bar on your chest for a full count before pressing. It removes all momentum."
        ),

        "ub-chest-3": ExerciseForm(       // Push-Ups
            steps: [
                "Set your hands slightly wider than your shoulders, directly under them, fingers forward.",
                "Straighten your legs behind you and squeeze your glutes so hips, ribs and shoulders form one line.",
                "Bend your elbows to about 45 degrees from your torso and lower until your chest is just off the floor.",
                "Press back up without letting your hips sag or rise."
            ],
            breathing: "Inhale on the way down, exhale as you press up.",
            mistakes: [
                "Hips sagging toward the floor, which turns it into a lower back exercise.",
                "Head dropping forward so the chin reaches the floor before the chest does.",
                "Only going halfway down once fatigue sets in."
            ],
            easier: "Put your hands on a bench or countertop. The higher the surface, the easier the rep.",
            harder: "Elevate your feet, or slow the lowering half to three full counts."
        ),

        "ub-back-1": ExerciseForm(        // Pull-Ups
            steps: [
                "Take an overhand grip a little wider than your shoulders and hang with arms straight.",
                "Before pulling, draw your shoulder blades down away from your ears.",
                "Pull your elbows down toward your ribs until your chin clears the bar.",
                "Lower all the way back to straight arms under control."
            ],
            breathing: "Exhale as you pull up, inhale as you lower.",
            mistakes: [
                "Kicking the legs to generate momentum instead of pulling.",
                "Stopping short of full arm extension at the bottom, which quietly shortens every rep.",
                "Shrugging the shoulders up toward the ears at the start of the pull."
            ],
            easier: "Loop a resistance band under your feet, or jump to the top and lower yourself slowly.",
            harder: "Add a weighted belt, or pause with your chin over the bar for two counts."
        ),

        // MARK: Lower body

        "lb-quads-1": ExerciseForm(       // Barbell Back Squat
            steps: [
                "Set the bar across your upper back — on the muscle, not on the bony ridge at the base of your neck.",
                "Step back with feet about shoulder width, toes turned slightly out.",
                "Take a big breath, brace your midsection, then push your hips back and bend your knees together.",
                "Descend until your hip crease passes below your kneecap, keeping your chest up.",
                "Drive up through your whole foot, keeping your knees tracking out over your toes."
            ],
            breathing: "Big breath at the top, hold it and stay braced through the rep, exhale once you're standing.",
            mistakes: [
                "Knees caving inward on the way up — usually a sign the weight is too heavy.",
                "Heels lifting off the floor, which shifts the load onto the knees.",
                "Cutting depth as the weight climbs. Depth first, then load."
            ],
            easier: "Squat to a box set at a height you can reach with good form, and lower it over time.",
            harder: "Pause for two counts at the bottom, or move to a front-loaded position."
        ),

        "lb-hams-1": ExerciseForm(        // Romanian Deadlift
            steps: [
                "Stand holding the bar at your hips, feet hip width, knees softly bent.",
                "Push your hips straight back and let the bar travel down your thighs, staying in contact with your legs.",
                "Keep your back flat and stop when you feel a strong stretch in your hamstrings — for most people just below the knee.",
                "Drive your hips forward to stand up, squeezing your glutes at the top."
            ],
            breathing: "Breathe in at the top, hold as you lower and lift, exhale at the top.",
            mistakes: [
                "Squatting down instead of hinging back — the knees should barely move.",
                "Letting the bar drift away from the legs, which loads the lower back.",
                "Rounding the upper back to chase extra range."
            ],
            easier: "Use dumbbells and a shorter range, stopping at mid-shin height.",
            harder: "Slow the lowering to four counts, or do them one leg at a time."
        ),

        "lb-glutes-1": ExerciseForm(      // Hip Thrust
            steps: [
                "Sit on the floor with your upper back against a bench and the bar across your hips, padded.",
                "Plant your feet flat, about shoulder width, close enough that your shins end vertical at the top.",
                "Tuck your chin and drive through your heels to lift your hips.",
                "Stop when your torso is parallel to the floor, squeeze hard, then lower under control."
            ],
            breathing: "Exhale as you drive up, inhale as you lower.",
            mistakes: [
                "Overextending at the top by arching the lower back instead of squeezing the glutes.",
                "Feet too far forward, which turns it into a hamstring exercise.",
                "Letting the chin lift, which pulls the ribs up and away from the hips."
            ],
            easier: "Do it bodyweight with your back on the floor as a glute bridge.",
            harder: "Pause for three counts at the top of every rep."
        ),

        // MARK: Full body

        "fb-compound-1": ExerciseForm(    // Deadlift
            steps: [
                "Stand with the bar over your mid-foot, feet hip width.",
                "Hinge down and grip just outside your legs, then drop your hips until your shins touch the bar.",
                "Lift your chest, flatten your back, and take the slack out of the bar before you pull.",
                "Push the floor away with your legs, keeping the bar dragging up your shins.",
                "Stand tall, then reverse the path to set it down — don't drop it and don't lean back at the top."
            ],
            breathing: "Big breath and brace before the pull, hold it through the rep, exhale once the bar is down.",
            mistakes: [
                "Hips shooting up first, which turns the lift into a stiff-legged pull off the floor.",
                "Rounding the lower back — the single most common way this lift causes injury.",
                "Jerking the bar off the floor instead of taking the slack out first."
            ],
            easier: "Pull from blocks or the second-lowest rack pin, so the bar starts nearer knee height.",
            harder: "Pause for two counts just below the knee on the way up."
        ),

        // MARK: Core

        "core-deep-1": ExerciseForm(      // Plank
            steps: [
                "Set your forearms on the floor, elbows directly under your shoulders.",
                "Step your feet back until your body forms one straight line from heels to head.",
                "Squeeze your glutes and gently draw your ribs down toward your hips.",
                "Hold, breathing normally, and stop the set when the line breaks — not when the timer says so."
            ],
            breathing: "Keep breathing steadily throughout. Holding your breath here defeats the point.",
            mistakes: [
                "Hips drifting up into a shallow pike, which makes the hold much easier than it looks.",
                "Hips sagging toward the floor, which loads the lower back.",
                "Holding on well past the point where the position has already collapsed."
            ],
            easier: "Drop to your knees, keeping the straight line from knees to head.",
            harder: "Lift one foot a few inches, or reach one arm forward, alternating sides."
        ),
    ]
}

// MARK: - Template convenience

extension ExerciseTemplate {
    /// Form guidance, when it has been written for this exercise.
    var form: ExerciseForm? { ExerciseFormLibrary.form(for: id) }
    var hasForm: Bool { form != nil }
}
