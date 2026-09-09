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

        // MARK: Upper body — Chest

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

        "ub-chest-2": ExerciseForm(       // Incline Dumbbell Press
            steps: [
                "Set the bench to about 30 degrees — steeper than 45 and it becomes a shoulder press.",
                "Sit with the dumbbells on your thighs, then kick them up one at a time as you lie back.",
                "Pin your shoulder blades down and back, palms facing forward, dumbbells at upper-chest level.",
                "Press up until your arms are straight without clanging the dumbbells together.",
                "Lower under control until your elbows are just below shoulder level."
            ],
            breathing: "Inhale as you lower, exhale as you press.",
            mistakes: [
                "Setting the incline too steep, which shifts the work off the chest and onto the front delts.",
                "Banging the dumbbells together at the top, which dumps the tension you just built.",
                "Letting the elbows drift straight out to the sides instead of staying at roughly 45 degrees."
            ],
            easier: "Lower the bench angle toward flat, or drop the weight and add reps.",
            harder: "Pause for a full count at the bottom, where the chest is most stretched."
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

        "ub-chest-4": ExerciseForm(       // Cable Chest Fly
            steps: [
                "Set both pulleys at roughly shoulder height and take a handle in each hand.",
                "Step forward into a split stance with a slight forward lean, arms out to your sides.",
                "Set a soft bend in your elbows and hold that same angle for the whole set.",
                "Bring your hands together in a wide arc in front of your chest and squeeze.",
                "Let your arms travel back until you feel a stretch across the chest, and no further."
            ],
            breathing: "Exhale as your hands come together, inhale as they travel back.",
            mistakes: [
                "Bending and straightening the elbows, which quietly turns the fly into a press.",
                "Letting the hands travel too far back, which strains the front of the shoulder.",
                "Using enough weight that the torso swings to start each rep."
            ],
            easier: "Reduce the weight and shorten the range until you can hold the elbow angle fixed.",
            harder: "Hold the squeeze for two counts where your hands meet."
        ),

        "ub-chest-5": ExerciseForm(       // Dumbbell Pullover
            steps: [
                "Lie along a bench holding one dumbbell with both hands, palms flat against the top plate.",
                "Press it up over your chest with a slight, fixed bend in your elbows.",
                "Lower it back over your head until you feel a stretch through your chest and lats.",
                "Pull it back over your chest along the same arc."
            ],
            breathing: "Inhale as the weight travels back, exhale as you pull it over.",
            mistakes: [
                "Letting the lower back arch off the bench to chase more range.",
                "Bending and straightening the elbows, which turns it into a triceps extension.",
                "Going deeper than your shoulders comfortably allow."
            ],
            easier: "Shorten the range and stop well before the stretch becomes uncomfortable.",
            harder: "Slow the lowering to four counts."
        ),

        // MARK: Upper body — Back

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

        "ub-back-2": ExerciseForm(        // Bent-Over Barbell Row
            steps: [
                "Stand with feet hip width and grip the bar just outside your knees.",
                "Hinge at the hips until your torso is around 45 degrees or lower, back flat.",
                "Let the bar hang at arms length below your chest.",
                "Pull it to your lower ribs by driving your elbows back, not by yanking with your arms.",
                "Lower under control without letting your back round."
            ],
            breathing: "Take a breath and brace at the top, exhale at the end of the pull.",
            mistakes: [
                "Standing more upright as the set gets hard, so the torso angle changes rep to rep.",
                "Rounding the lower back, which is where this lift causes injury.",
                "Pulling to the chest rather than the ribs, which turns it into a rear delt movement."
            ],
            easier: "Rest your chest on an incline bench so the lower back is taken out of it entirely.",
            harder: "Pause the bar against your ribs for a full count on every rep."
        ),

        "ub-back-3": ExerciseForm(        // Lat Pulldown
            steps: [
                "Set the thigh pad snug enough that you stay seated under load.",
                "Grip the bar wider than your shoulders and sit tall with a slight backward lean.",
                "Start the movement by pulling your shoulder blades down, before your arms bend.",
                "Pull the bar to your collarbone, driving your elbows down toward your sides.",
                "Let the bar rise all the way back until your arms are straight and your lats stretch."
            ],
            breathing: "Exhale as you pull down, inhale as the bar rises.",
            mistakes: [
                "Leaning far back and heaving, which turns the pulldown into a row.",
                "Pulling the bar behind your neck, which puts the shoulder in a vulnerable position.",
                "Not letting the arms fully straighten at the top, cutting the stretch out of every rep."
            ],
            easier: "Lighten the stack until you can feel the shoulder blades move before the arms do.",
            harder: "Pause with the bar at your collarbone for two counts."
        ),

        "ub-back-4": ExerciseForm(        // Seated Cable Row
            steps: [
                "Sit with your feet on the platform and a soft bend in your knees.",
                "Take the handle and sit tall, arms straight, letting your shoulders travel forward into a stretch.",
                "Pull the handle to your navel by driving your elbows straight back past your ribs.",
                "Return under control, letting your shoulders travel forward again at the end."
            ],
            breathing: "Exhale as you pull, inhale as you return.",
            mistakes: [
                "Rocking the torso back and forth to build momentum.",
                "Shrugging the shoulders up toward the ears instead of pulling the elbows back.",
                "Letting the lower back round as the shoulders travel forward at the stretch."
            ],
            easier: "Reduce the weight until your torso can stay upright and still.",
            harder: "Hold the handle at your navel for two counts before returning."
        ),

        "ub-back-5": ExerciseForm(        // Single-Arm Dumbbell Row
            steps: [
                "Put one knee and the same-side hand on a bench, other foot planted on the floor.",
                "Set your back flat and roughly parallel to the ground.",
                "Let the dumbbell hang at arms length directly below your shoulder.",
                "Pull it up to your hip, keeping your elbow close to your side.",
                "Lower it all the way back down to a full stretch."
            ],
            breathing: "Exhale as you pull, inhale as you lower.",
            mistakes: [
                "Rotating the torso open at the top to lift a heavier dumbbell.",
                "Pulling toward the shoulder rather than the hip, which loses the lat.",
                "Letting the lower back round at the bottom of the stretch."
            ],
            easier: "Use a lighter dumbbell and slow the movement until the torso stays square.",
            harder: "Pause at the top for two counts, matching reps on both sides."
        ),

        // MARK: Upper body — Shoulders

        "ub-shoulders-1": ExerciseForm(   // Overhead Press
            steps: [
                "Set the bar on your front delts with hands just outside your shoulders, elbows slightly ahead of the bar.",
                "Stand feet hip width, squeeze your glutes, and brace your midsection hard.",
                "Press up, tilting your head back just enough to let the bar pass your face.",
                "Lock out with the bar over your mid-foot and your head back through your arms.",
                "Lower under control all the way to your front delts."
            ],
            breathing: "Breath in at the bottom, hold and stay braced through the press, exhale at lockout.",
            mistakes: [
                "Leaning back through the ribs, which turns a press into a standing incline press.",
                "Pressing around your face instead of moving your head out of the way.",
                "Finishing with the bar in front of your head rather than over your mid-foot."
            ],
            easier: "Press dumbbells seated with the bench upright, so the torso can't lean back.",
            harder: "Pause for a count with the bar at chin height on the way up."
        ),

        "ub-shoulders-2": ExerciseForm(   // Lateral Raise
            steps: [
                "Stand with a dumbbell in each hand at your sides, elbows slightly bent.",
                "Lead with your elbows and raise your arms out to the sides.",
                "Stop at shoulder height, no higher.",
                "Lower slowly rather than letting the weights drop."
            ],
            breathing: "Exhale as you raise, inhale as you lower.",
            mistakes: [
                "Swinging the torso to throw the weights up, which is the most common fault on this movement.",
                "Raising above shoulder height, which hands the work to the traps.",
                "Choosing a weight heavy enough that momentum does most of the lifting."
            ],
            easier: "Go lighter. This movement punishes ego more than almost any other in the gym.",
            harder: "Pause at the top for two counts, or do them one arm at a time leaning away from a cable."
        ),

        "ub-shoulders-3": ExerciseForm(   // Arnold Press
            steps: [
                "Sit upright with dumbbells at chin height, palms facing you, elbows in front of your body.",
                "Press up while rotating your palms to face forward, spreading the elbows out as you go.",
                "Finish overhead with arms straight and palms forward.",
                "Reverse the rotation on the way down, ending back at chin height with palms facing you."
            ],
            breathing: "Exhale as you press and rotate, inhale as you lower.",
            mistakes: [
                "Rushing the rotation so it all happens at the very top instead of through the press.",
                "Arching the lower back off the bench as the weight goes overhead.",
                "Using a weight too heavy to control the rotation, which strains the shoulder."
            ],
            easier: "Do a plain seated dumbbell press without the rotation until the pressing strength is there.",
            harder: "Slow the lowering and the reverse rotation to three counts."
        ),

        "ub-shoulders-4": ExerciseForm(   // Rear Delt Fly
            steps: [
                "Hinge at the hips with a flat back until your torso is close to parallel with the floor.",
                "Let the dumbbells hang under your chest with a slight, fixed bend in your elbows.",
                "Raise your arms out to the sides, leading with the elbows.",
                "Squeeze your shoulder blades together at the top, then lower under control."
            ],
            breathing: "Exhale as you raise, inhale as you lower.",
            mistakes: [
                "Pulling the elbows back past the body, which turns the fly into a row.",
                "Bouncing the torso up and down to help the weights along.",
                "Going heavy enough that the traps and upper back take over from the rear delts."
            ],
            easier: "Lie chest-down on an incline bench so the torso cannot swing at all.",
            harder: "Pause at the top of every rep for two counts."
        ),

        "ub-shoulders-5": ExerciseForm(   // Front Raise
            steps: [
                "Stand holding dumbbells in front of your thighs, palms facing back.",
                "Raise your arms straight out in front of you with a slight bend at the elbow.",
                "Stop at shoulder height.",
                "Lower slowly under control."
            ],
            breathing: "Exhale as you raise, inhale as you lower.",
            mistakes: [
                "Rocking the hips forward to start each rep.",
                "Raising well above shoulder height, which just recruits the traps.",
                "Letting the weights fall rather than controlling the lowering half."
            ],
            easier: "Alternate arms so you can give each side your full attention.",
            harder: "Pause at shoulder height for two counts."
        ),

        // MARK: Upper body — Biceps

        "ub-biceps-1": ExerciseForm(      // Barbell Curl
            steps: [
                "Stand feet hip width holding the bar at shoulder width, arms straight.",
                "Pin your elbows against your sides and keep them there.",
                "Curl the bar up by bending only at the elbow.",
                "Lower all the way back to straight arms under control."
            ],
            breathing: "Exhale as you curl up, inhale as you lower.",
            mistakes: [
                "Swinging the torso and using the hips to start the bar moving.",
                "Letting the elbows drift forward, which turns the top half into a front raise.",
                "Not straightening the arms at the bottom, cutting the hardest part out of every rep."
            ],
            easier: "Use an EZ bar if a straight bar bothers your wrists, and drop the weight.",
            harder: "Take three full counts on the lowering half of every rep."
        ),

        "ub-biceps-2": ExerciseForm(      // Dumbbell Hammer Curl
            steps: [
                "Stand with a dumbbell in each hand, palms facing your thighs.",
                "Keep that neutral grip for the whole rep — no rotation.",
                "Curl up with your elbows staying at your sides.",
                "Lower to full arm extension."
            ],
            breathing: "Exhale as you curl, inhale as you lower.",
            mistakes: [
                "Rotating the wrist on the way up, which turns it into an ordinary curl.",
                "Swinging the weights up with a dip of the knees.",
                "Letting the elbows travel forward as the set gets hard."
            ],
            easier: "Sit down to curl, which removes any chance of using the legs or torso.",
            harder: "Curl across your body toward the opposite shoulder."
        ),

        "ub-biceps-3": ExerciseForm(      // Incline Dumbbell Curl
            steps: [
                "Set a bench to roughly 45 to 60 degrees and sit back against it.",
                "Let your arms hang straight down, slightly behind your torso.",
                "Keep your upper arms still and curl the dumbbells up.",
                "Lower all the way back down into the stretch."
            ],
            breathing: "Exhale as you curl, inhale as you lower.",
            mistakes: [
                "Rolling the shoulders forward to help, which removes the stretch this version exists for.",
                "Stopping short at the bottom, again losing the stretch.",
                "Sliding the hips up the bench as the set gets hard."
            ],
            easier: "Raise the bench angle closer to upright, which reduces the stretch.",
            harder: "Lower the bench angle, or slow the lowering to three counts."
        ),

        "ub-biceps-4": ExerciseForm(      // Cable Curl
            steps: [
                "Stand facing a low pulley with a bar attached, arms straight down.",
                "Step back far enough that there is tension on the cable at the bottom.",
                "Curl up with your elbows pinned at your sides.",
                "Lower under control, resisting the cable rather than letting it pull your arms straight."
            ],
            breathing: "Exhale as you curl, inhale as you lower.",
            mistakes: [
                "Standing too close, so all the tension disappears at the bottom of the rep.",
                "Leaning back to get the last few reps.",
                "Letting the stack snap the arms straight at the end of each rep."
            ],
            easier: "Reduce the weight until you can control the lowering half completely.",
            harder: "Pause at the top for two counts on every rep."
        ),

        "ub-biceps-5": ExerciseForm(      // Concentration Curl
            steps: [
                "Sit on a bench with your feet wide and a dumbbell in one hand.",
                "Brace the back of that upper arm against the inside of your thigh.",
                "Curl the dumbbell up without letting the upper arm move at all.",
                "Lower to full extension before starting the next rep."
            ],
            breathing: "Exhale as you curl, inhale as you lower.",
            mistakes: [
                "Leaning back to help the weight up in the second half of the set.",
                "Not straightening the arm fully at the bottom.",
                "Letting the elbow slide off the thigh, which removes the bracing."
            ],
            easier: "Use a lighter dumbbell so the upper arm can stay completely still.",
            harder: "Take two full seconds on the lowering half of every rep."
        ),

        // MARK: Upper body — Triceps

        "ub-triceps-1": ExerciseForm(     // Close-Grip Bench Press
            steps: [
                "Lie on the bench and grip the bar about shoulder width — narrower strains the wrists.",
                "Unrack to a point over your shoulders with your shoulder blades pinned back.",
                "Lower the bar to your lower chest with your elbows tucked close to your sides.",
                "Press back up, keeping the elbows tucked the whole way."
            ],
            breathing: "Inhale as you lower, exhale as you press.",
            mistakes: [
                "Gripping so narrow that the wrists bend back painfully under load.",
                "Letting the elbows flare out, which hands the work back to the chest.",
                "Bouncing the bar off the chest to get through the sticking point."
            ],
            easier: "Use dumbbells held with a neutral grip so your wrists can find their own position.",
            harder: "Pause the bar on your chest for a full count."
        ),

        "ub-triceps-2": ExerciseForm(     // Tricep Rope Pushdown
            steps: [
                "Stand facing a high pulley with a rope in both hands.",
                "Pin your elbows against your sides and keep them there for the whole set.",
                "Push down until your arms are straight, spreading the rope apart at the bottom.",
                "Let the rope rise back to about 90 degrees at the elbow without the elbows moving."
            ],
            breathing: "Exhale as you push down, inhale as the rope rises.",
            mistakes: [
                "Leaning over the rope so bodyweight pushes the stack down instead of the triceps.",
                "Elbows drifting forward away from the ribs as the weight climbs.",
                "Letting the stack pull the arms up so far the elbows travel."
            ],
            easier: "Reduce the weight until your elbows can stay completely still.",
            harder: "Hold the straight-arm position with the rope spread for two counts."
        ),

        "ub-triceps-3": ExerciseForm(     // Skull Crushers
            steps: [
                "Lie on a bench holding an EZ bar over your chest with straight arms.",
                "Angle your upper arms slightly back toward your head and hold them there.",
                "Bend at the elbows only, lowering the bar toward your forehead or just behind it.",
                "Extend back to straight arms without letting the upper arms move."
            ],
            breathing: "Inhale as you lower, exhale as you extend.",
            mistakes: [
                "Letting the upper arms swing back so it becomes a pullover.",
                "Flaring the elbows out wide, which takes tension off the triceps.",
                "Going heavy enough that the elbows start to ache — this movement rewards patience."
            ],
            easier: "Use dumbbells with a neutral grip, which is usually kinder on the elbows.",
            harder: "Lower behind your head rather than to your forehead, slowly."
        ),

        "ub-triceps-4": ExerciseForm(     // Overhead Tricep Extension
            steps: [
                "Hold one dumbbell with both hands and press it overhead, arms straight.",
                "Keep your upper arms close to your ears with the elbows pointing forward.",
                "Lower the weight behind your head until you feel a stretch along the back of your arms.",
                "Extend back overhead without letting the upper arms drift."
            ],
            breathing: "Inhale as you lower, exhale as you extend.",
            mistakes: [
                "Elbows flaring out to the sides instead of pointing forward.",
                "Arching the lower back as the weight travels behind the head.",
                "Lowering further than your shoulder mobility comfortably allows."
            ],
            easier: "Do it seated with back support, one arm at a time.",
            harder: "Slow the lowering to three counts."
        ),

        "ub-triceps-5": ExerciseForm(     // Dips
            steps: [
                "Grip parallel bars and press up until your arms are straight.",
                "Lean your torso slightly forward and point your elbows back, not out.",
                "Lower until your upper arms are roughly parallel with the floor.",
                "Press back up to straight arms without shrugging."
            ],
            breathing: "Inhale as you lower, exhale as you press up.",
            mistakes: [
                "Dropping deeper than parallel, which strains the front of the shoulder.",
                "Letting the elbows flare out to the sides.",
                "Shrugging the shoulders up toward the ears at the bottom."
            ],
            easier: "Use an assisted dip machine or a band, or do bench dips with your feet on the floor.",
            harder: "Add weight with a dip belt, or pause for a count at the bottom."
        ),

        // MARK: Lower body — Quads

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

        "lb-quads-2": ExerciseForm(       // Leg Press
            steps: [
                "Sit with your back and hips flat against the pad.",
                "Place your feet shoulder width on the platform, weight through the middle of each foot.",
                "Release the safeties and lower until your knees reach roughly 90 degrees.",
                "Press back through your whole foot, stopping just short of locking the knees hard."
            ],
            breathing: "Inhale as you lower, exhale as you press.",
            mistakes: [
                "Letting the hips curl up off the pad at the bottom, which rounds the lower back under load.",
                "Snapping the knees into a hard lockout at the top.",
                "Setting the feet too low on the platform, forcing the knees far past the toes."
            ],
            easier: "Shorten the range and stop higher, well before the hips start to lift.",
            harder: "Slow the lowering to three counts, or press one leg at a time."
        ),

        "lb-quads-3": ExerciseForm(       // Walking Lunges
            steps: [
                "Stand tall with a dumbbell in each hand.",
                "Step forward far enough that both knees can bend to about 90 degrees.",
                "Lower until your back knee is just short of the floor.",
                "Drive through your front heel and step straight into the next lunge."
            ],
            breathing: "Inhale as you lower, exhale as you drive up.",
            mistakes: [
                "Stepping too short, which drives the front knee well over the toes.",
                "Letting the torso pitch forward as the set gets hard.",
                "Banging the back knee into the floor rather than stopping just above it."
            ],
            easier: "Do them bodyweight, or step backward into a reverse lunge instead.",
            harder: "Pause with the back knee an inch off the floor for two counts."
        ),

        "lb-quads-4": ExerciseForm(       // Leg Extension
            steps: [
                "Sit with your back against the pad and your knees lined up with the machine's pivot.",
                "Set the shin pad so it rests just above your ankles.",
                "Extend until your legs are straight and pause briefly at the top.",
                "Lower under control rather than letting the stack fall."
            ],
            breathing: "Exhale as you extend, inhale as you lower.",
            mistakes: [
                "Swinging the torso to throw the first few inches of each rep.",
                "Slamming into full lockout with a heavy stack, which the knee joint does not enjoy.",
                "Letting the weight drop back down, wasting the lowering half entirely."
            ],
            easier: "Reduce the weight and stop just short of full lockout.",
            harder: "Pause at the top for two counts on every rep."
        ),

        "lb-quads-5": ExerciseForm(       // Bulgarian Split Squat
            steps: [
                "Stand about a stride in front of a bench and rest the top of one foot on it behind you.",
                "Check the front foot is far enough forward that the knee stays over the mid-foot.",
                "Lower straight down until the front thigh is roughly parallel with the floor.",
                "Drive up through the front heel without pushing off the back foot."
            ],
            breathing: "Inhale as you lower, exhale as you drive up.",
            mistakes: [
                "Front foot too close to the bench, which forces the knee well past the toes.",
                "Leaning the torso forward to make the rep easier.",
                "Letting the back leg take load instead of using it purely for balance."
            ],
            easier: "Hold a rail for balance and use bodyweight only until the position feels stable.",
            harder: "Add dumbbells, or pause for two counts at the bottom."
        ),

        // MARK: Lower body — Hamstrings

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

        "lb-hams-2": ExerciseForm(        // Leg Curl
            steps: [
                "Lie face down with your knees lined up with the machine's pivot.",
                "Set the pad so it sits just above your heels, not up on the calf.",
                "Curl until your hamstrings are fully shortened.",
                "Lower slowly, resisting the stack the whole way back."
            ],
            breathing: "Exhale as you curl, inhale as you lower.",
            mistakes: [
                "Lifting the hips off the pad to swing heavier weight up.",
                "Letting the pad fall back rather than controlling it — the lowering half is where hamstrings grow.",
                "Setting the pad too high on the calf, which puts pressure in the wrong place."
            ],
            easier: "Reduce the weight until your hips stay flat on the pad throughout.",
            harder: "Take three full counts on the lowering half of every rep."
        ),

        "lb-hams-3": ExerciseForm(        // Good Mornings
            steps: [
                "Set the bar on your upper back as you would for a squat, feet hip width, knees soft.",
                "Take a big breath and brace hard before you move.",
                "Push your hips straight back and hinge until your torso is close to parallel with the floor.",
                "Keep your back flat throughout, then drive your hips forward to stand."
            ],
            breathing: "Breath at the top, hold and stay braced through the hinge, exhale once standing.",
            mistakes: [
                "Starting too heavy. This lift rewards patience more than almost any other barbell movement.",
                "Rounding the back as the torso lowers.",
                "Bending the knees enough that it becomes a squat rather than a hinge."
            ],
            easier: "Do it with no bar at all, hands crossed on your chest, until the hinge is automatic.",
            harder: "Add load in the smallest increments available — five pounds at a time."
        ),

        "lb-hams-4": ExerciseForm(        // Kettlebell Swing
            steps: [
                "Stand with the bell about a foot in front of you, feet slightly wider than your shoulders.",
                "Hinge at the hips and hike the bell back between your legs like a snap pass.",
                "Snap your hips forward hard and let the bell float up to chest height on its own.",
                "Let it fall back down and straight into the next hinge."
            ],
            breathing: "Exhale sharply as your hips snap, inhale as the bell falls.",
            mistakes: [
                "Squatting the bell up instead of hinging, which turns a hip drive into a front raise.",
                "Lifting with the arms rather than letting the hips throw the bell.",
                "Leaning back at the top to get the bell higher, which loads the lower back."
            ],
            easier: "Practise the hinge with no bell at all until the movement is automatic.",
            harder: "Use a heavier bell, or swing it one-handed."
        ),

        "lb-hams-5": ExerciseForm(        // Single-Leg RDL
            steps: [
                "Stand on one leg with a soft knee, holding a dumbbell in the opposite hand.",
                "Hinge at the hip, letting your free leg travel straight back as a counterweight.",
                "Keep your hips square to the floor throughout.",
                "Stop at a strong hamstring stretch, then drive the hip forward to stand."
            ],
            breathing: "Inhale as you hinge, exhale as you stand.",
            mistakes: [
                "Letting the hip of the free leg rotate open toward the ceiling.",
                "Rounding the back to reach lower than your hamstrings allow.",
                "Rushing, which turns a balance exercise into a wobble."
            ],
            easier: "Touch the free toe down lightly behind you for balance.",
            harder: "Hold the bottom position for two counts before standing."
        ),

        // MARK: Lower body — Glutes

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

        "lb-glutes-2": ExerciseForm(      // Glute Bridge
            steps: [
                "Lie on your back with knees bent, feet flat and hip width, heels close to your glutes.",
                "Tuck your ribs down toward your hips and squeeze your glutes before you move.",
                "Drive through your heels to lift your hips until your torso and thighs form a line.",
                "Lower under control without resting the hips between reps."
            ],
            breathing: "Exhale as you lift, inhale as you lower.",
            mistakes: [
                "Arching the lower back to get higher instead of squeezing the glutes.",
                "Pushing through the toes rather than the heels.",
                "Letting the knees drift apart at the top."
            ],
            easier: "Shorten the range and hold briefly at whatever height you can reach with the ribs down.",
            harder: "Add a band above the knees, or do them one leg at a time."
        ),

        "lb-glutes-3": ExerciseForm(      // Cable Kickback
            steps: [
                "Attach an ankle strap to a low pulley and face the machine.",
                "Hold the frame for balance and hinge slightly forward at the hips.",
                "Drive the working leg straight back with the knee mostly straight.",
                "Stop before your hips start to rotate, then return under control."
            ],
            breathing: "Exhale as you drive back, inhale as you return.",
            mistakes: [
                "Arching the lower back to squeeze out more range.",
                "Rotating the hips open so a heavier stack can be moved.",
                "Swinging the leg rather than driving it, which loses the glute entirely."
            ],
            easier: "Reduce the weight and keep the range short enough that the hips stay square.",
            harder: "Pause at the end of the kick for two counts."
        ),

        "lb-glutes-4": ExerciseForm(      // Sumo Deadlift
            steps: [
                "Take a wide stance with your toes turned out and your shins close to the bar.",
                "Grip inside your legs with straight arms.",
                "Drop your hips, lift your chest, and pull the slack out of the bar before you lift.",
                "Push the floor apart with your feet and stand tall.",
                "Reverse the same path to set the bar down."
            ],
            breathing: "Big breath and brace before the pull, hold through the rep, exhale once the bar is down.",
            mistakes: [
                "Letting the hips rise before the bar leaves the floor.",
                "Knees caving inward off the floor instead of pushing out over the toes.",
                "Rounding the upper back to reach the bar."
            ],
            easier: "Pull from blocks so the bar starts nearer knee height.",
            harder: "Pause just below the knee for two counts on the way up."
        ),

        "lb-glutes-5": ExerciseForm(      // Step-Ups
            steps: [
                "Stand facing a box at roughly knee height with a dumbbell in each hand.",
                "Place one whole foot on the box, heel included.",
                "Drive through that heel to stand up without pushing off the trailing foot.",
                "Lower under control until the trailing foot touches lightly, then repeat."
            ],
            breathing: "Exhale as you step up, inhale as you lower.",
            mistakes: [
                "Pushing off the back foot, which quietly does most of the work.",
                "Letting the working knee cave inward on the drive up.",
                "Dropping back down rather than lowering under control."
            ],
            easier: "Use a lower box and no added weight.",
            harder: "Raise the box height, which shifts more of the work onto the glutes."
        ),

        // MARK: Lower body — Calves

        "lb-calves-1": ExerciseForm(      // Standing Calf Raise
            steps: [
                "Set the shoulder pads so you stand tall with the balls of your feet on the platform.",
                "Let your heels drop below the platform into a full stretch.",
                "Press up onto your toes as high as you can and pause.",
                "Lower slowly back into the stretch."
            ],
            breathing: "Exhale as you press up, inhale as you lower.",
            mistakes: [
                "Bouncing out of the bottom on the tendon rather than pressing with the muscle.",
                "Cutting the range short at both ends, which is most of the point of the exercise.",
                "Bending the knees to help the weight up."
            ],
            easier: "Reduce the weight until you can reach the full stretch and the full contraction.",
            harder: "Pause two counts at the top and two counts in the stretch."
        ),

        "lb-calves-2": ExerciseForm(      // Seated Calf Raise
            steps: [
                "Sit with the pad across your lower thighs and the balls of your feet on the platform.",
                "Let your heels drop into a full stretch.",
                "Press up onto your toes and squeeze at the top.",
                "Lower slowly back down."
            ],
            breathing: "Exhale as you press up, inhale as you lower.",
            mistakes: [
                "Skipping this in favour of standing raises alone, which under-trains the soleus.",
                "Bouncing through the bottom of each rep.",
                "Short-changing the range at the top."
            ],
            easier: "Reduce the weight and concentrate on reaching the full stretch.",
            harder: "Pause two counts at the top of every rep."
        ),

        "lb-calves-3": ExerciseForm(      // Donkey Calf Raise
            steps: [
                "Bend forward at the hips with your torso supported and the balls of your feet on a raised platform.",
                "Let your heels drop into a deep stretch — the bent-over angle makes this deeper than a standing raise.",
                "Press up onto your toes.",
                "Lower slowly back into the stretch."
            ],
            breathing: "Exhale as you press up, inhale as you lower.",
            mistakes: [
                "Bending the knees as you press, which takes the calves out of it.",
                "Bouncing out of the stretch instead of pressing.",
                "Rushing the reps, which this position makes easy to do."
            ],
            easier: "Do it bodyweight before adding any load.",
            harder: "Add weight across the hips, or pause two counts at the top."
        ),

        "lb-calves-4": ExerciseForm(      // Single-Leg Calf Raise
            steps: [
                "Stand on one foot on a step with the other foot hooked behind your ankle.",
                "Hold something for balance, using it only to stay upright.",
                "Let your heel drop below the step into a stretch.",
                "Press up as high as you can, then lower slowly."
            ],
            breathing: "Exhale as you press up, inhale as you lower.",
            mistakes: [
                "Pulling yourself up with the hand you're balancing with.",
                "Stopping short at the bottom and losing the stretch.",
                "Doing more reps on the stronger side without noticing."
            ],
            easier: "Keep both feet down and do them two-legged until the strength is there.",
            harder: "Hold a dumbbell in your free hand."
        ),

        "lb-calves-5": ExerciseForm(      // Jump Rope Calf Pumps
            steps: [
                "Hold the handles with your elbows close to your sides.",
                "Turn the rope with your wrists, not your arms.",
                "Stay on the balls of your feet with small, low hops.",
                "Keep your knees soft and land quietly."
            ],
            breathing: "Breathe steadily and rhythmically — don't hold your breath between hops.",
            mistakes: [
                "Jumping far higher than the rope needs, which burns you out in the first minute.",
                "Swinging from the shoulders instead of turning the rope with the wrists.",
                "Landing flat-footed and heavily, which defeats the purpose."
            ],
            easier: "Skip the rope entirely and do the same footwork, or step side to side instead of hopping.",
            harder: "Increase the pace, or move to single-leg hops."
        ),

        // MARK: Lower body — Adductors & Abductors

        "lb-adduct-1": ExerciseForm(      // Cable Hip Adduction
            steps: [
                "Attach an ankle strap to a low pulley and fasten it to the leg nearest the machine.",
                "Stand far enough away that the cable pulls that leg out to the side.",
                "Hold the frame for balance and keep your torso still and upright.",
                "Pull the working leg in across toward your standing leg, then return under control."
            ],
            breathing: "Exhale as you pull across, inhale as you return.",
            mistakes: [
                "Leaning the torso away from the machine to generate force.",
                "Letting the cable snap the leg back out rather than resisting it.",
                "Using enough weight that the standing leg wobbles through every rep."
            ],
            easier: "Reduce the weight and shorten the range until the torso stays still.",
            harder: "Pause for two counts at the fully adducted position."
        ),

        "lb-adduct-2": ExerciseForm(      // Cable Hip Abduction
            steps: [
                "Attach the ankle strap to the leg furthest from the machine.",
                "Stand close enough that there is tension on the cable with the leg down.",
                "Hold the frame for balance, torso upright and square.",
                "Raise the working leg out to the side, then return under control."
            ],
            breathing: "Exhale as you raise, inhale as you return.",
            mistakes: [
                "Leaning the torso sideways to get the leg higher.",
                "Rotating the hip so the toe points upward, which shifts the work off the target muscle.",
                "Letting the leg swing back down rather than controlling it."
            ],
            easier: "Reduce the weight and keep the range small enough to stay upright.",
            harder: "Pause at the top of the raise for two counts."
        ),

        "lb-adduct-3": ExerciseForm(      // Side-Lying Leg Raise
            steps: [
                "Lie on your side with your body in a straight line, bottom arm supporting your head.",
                "Stack your hips vertically, one directly above the other.",
                "Raise the top leg with your toe pointing forward, not at the ceiling.",
                "Stop before your hips roll backward, then lower slowly."
            ],
            breathing: "Exhale as you raise, inhale as you lower.",
            mistakes: [
                "Rolling the hips backward to lift the leg higher than the range allows.",
                "Pointing the toe at the ceiling, which hands the work to the hip flexors.",
                "Letting the leg drop rather than lowering it."
            ],
            easier: "Bend the bottom leg for a wider, steadier base.",
            harder: "Add an ankle weight, or pause two counts at the top."
        ),

        "lb-adduct-4": ExerciseForm(      // Sumo Squat
            steps: [
                "Stand wide with your toes turned out about 45 degrees, holding a dumbbell in front of you.",
                "Keep your chest up and brace your midsection.",
                "Sit straight down between your heels, knees tracking out over your toes.",
                "Drive up through your whole foot."
            ],
            breathing: "Inhale as you lower, exhale as you drive up.",
            mistakes: [
                "Letting the knees drift inward on the way up.",
                "Turning the toes out further than the knees can track over.",
                "Leaning forward, which quietly turns the squat into a hinge."
            ],
            easier: "Do it bodyweight, holding a rail for balance until the stance feels natural.",
            harder: "Pause two counts at the bottom, or hold a heavier dumbbell."
        ),

        "lb-adduct-5": ExerciseForm(      // Lateral Band Walk
            steps: [
                "Loop a band just above your knees — around the ankles makes it harder.",
                "Sit into a quarter squat and stay at that height for the whole set.",
                "Step sideways, keeping tension on the band the entire time.",
                "Take small controlled steps rather than long ones."
            ],
            breathing: "Breathe steadily throughout — don't hold your breath in the squat position.",
            mistakes: [
                "Standing up between steps, which resets the tension and the point of the exercise.",
                "Letting the trailing leg snap inward instead of controlling it.",
                "Taking steps so long that the torso sways side to side."
            ],
            easier: "Move the band above the knees rather than down at the ankles.",
            harder: "Move the band to your ankles, or use a heavier band."
        ),

        // MARK: Full body — Compound Lifts

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

        "fb-compound-2": ExerciseForm(    // Clean and Press
            steps: [
                "Set up as for a deadlift with the bar over your mid-foot, hands just outside your legs.",
                "Pull the bar up your thighs, then extend hips, knees and ankles hard to accelerate it.",
                "Drop under the bar and catch it on your front delts with your elbows driven high.",
                "Stand fully upright out of the catch before you press.",
                "Brace and press overhead, finishing with the bar over your mid-foot."
            ],
            breathing: "Breath and brace before the pull, exhale after the catch, breath again before the press.",
            mistakes: [
                "Trying to muscle the bar up with the arms instead of accelerating it with the hips.",
                "Catching with low elbows, which drops the bar onto the wrists and collapses the rack position.",
                "Pressing before you have finished standing up out of the catch."
            ],
            easier: "Split it into two separate lifts — practise the clean and the press on their own.",
            harder: "Add load only once the catch is consistent; technique caps this lift, not strength."
        ),

        "fb-compound-3": ExerciseForm(    // Thruster
            steps: [
                "Hold the bar in a front rack position with elbows high and the bar resting on your delts.",
                "Squat down to full depth, keeping your elbows up and your chest tall.",
                "Drive up out of the bottom and let that momentum carry into the press.",
                "Finish with the bar locked out overhead, then lower it back to the rack position."
            ],
            breathing: "Breath at the top, hold through the squat, exhale as you lock out overhead.",
            mistakes: [
                "Letting the elbows drop in the squat, which dumps the bar forward.",
                "Pausing at the top of the squat, which throws away the drive that makes the press possible.",
                "Pressing with the arms alone rather than riding the leg drive."
            ],
            easier: "Use dumbbells at the shoulders instead of a barbell.",
            harder: "Add load, or cycle the reps continuously without resetting at the top."
        ),

        "fb-compound-4": ExerciseForm(    // Barbell Complex
            steps: [
                "Pick a sequence of lifts you can all perform with the same weight — the weakest lift sets the load.",
                "Complete every rep of the first movement before moving to the next.",
                "Do not set the bar down between movements; that is the point of a complex.",
                "Rest fully once the whole sequence is finished, then repeat."
            ],
            breathing: "Breathe between reps, not between movements — you won't get a break at the handover.",
            mistakes: [
                "Loading for your strongest lift in the sequence rather than your weakest.",
                "Setting the bar down mid-complex, which turns it into ordinary straight sets.",
                "Choosing so many movements that form falls apart before the end."
            ],
            easier: "Use an empty bar and three movements until the sequence flows.",
            harder: "Add a movement, add reps per movement, or add weight — one at a time."
        ),

        "fb-compound-5": ExerciseForm(    // Snatch
            steps: [
                "Take a wide grip with the bar over your mid-foot and your hips low, chest up.",
                "Pull the bar off the floor in a controlled way, keeping it close to your legs.",
                "As it passes your thighs, extend hips, knees and ankles violently to accelerate it upward.",
                "Pull yourself under the bar and catch it overhead with locked arms in a partial squat.",
                "Stand up out of the catch under control."
            ],
            breathing: "Breath and brace before the pull, exhale once you have stood up from the catch.",
            mistakes: [
                "Trying to lift the bar with the arms rather than launching it with the hips.",
                "Letting the bar swing away from the body, which puts it in front of the catch position.",
                "Being slow under the bar — speed into the catch matters more than raw strength."
            ],
            easier: "Practise with a dowel or empty bar, from the hang position, until the path is consistent.",
            harder: "Add load slowly. Technique caps this lift long before strength does."
        ),

        // MARK: Full body — Circuit Training

        "fb-circuit-1": ExerciseForm(     // Burpees
            steps: [
                "From standing, squat down and place your hands on the floor in front of your feet.",
                "Jump or step your feet back into a plank with your body in a straight line.",
                "Lower your chest to the floor, then press back up.",
                "Jump or step your feet back to your hands and stand, finishing with a jump."
            ],
            breathing: "Exhale on the way up out of each rep; find a rhythm rather than holding your breath.",
            mistakes: [
                "Letting the hips sag as you hit the floor, which is where lower backs complain.",
                "Sprinting the first round, which guarantees the last one falls apart.",
                "Skipping the chest-to-floor portion once tired."
            ],
            easier: "Step the feet back and forward instead of jumping, and drop the push-up.",
            harder: "Add a tuck jump at the top, or chain them without pausing between reps."
        ),

        "fb-circuit-2": ExerciseForm(     // Mountain Climbers
            steps: [
                "Start in a push-up position with hands under your shoulders.",
                "Keep your hips level with your shoulders — no piking up.",
                "Drive one knee toward your chest, then switch legs.",
                "Build speed only once the hips stay still."
            ],
            breathing: "Breathe steadily and rhythmically rather than holding your breath through the set.",
            mistakes: [
                "Hips rising into a pike, which makes the movement much easier than it looks.",
                "Bouncing the hips up and down with each drive.",
                "Going for speed before the position is stable."
            ],
            easier: "Slow the pace right down and focus on holding the plank between knee drives.",
            harder: "Increase the pace, or bring the knee toward the opposite elbow."
        ),

        "fb-circuit-3": ExerciseForm(     // Jumping Jacks
            steps: [
                "Stand tall with your feet together and arms at your sides.",
                "Jump your feet out wider than your shoulders while raising your arms overhead.",
                "Jump back to the start in one motion.",
                "Stay on the balls of your feet and land softly."
            ],
            breathing: "Breathe steadily in rhythm with the reps.",
            mistakes: [
                "Landing flat-footed and heavily, which jars the knees.",
                "Only half-raising the arms once fatigue sets in.",
                "Locking the knees on landing rather than absorbing with a soft bend."
            ],
            easier: "Step one foot out at a time instead of jumping.",
            harder: "Increase the pace, or switch to seal jacks with the arms meeting in front."
        ),

        "fb-circuit-4": ExerciseForm(     // Squat to Press
            steps: [
                "Hold a dumbbell in each hand at shoulder height, palms facing in.",
                "Squat to full depth with your chest up and elbows in front.",
                "Drive up out of the bottom and let that momentum carry into the press.",
                "Lock the dumbbells out overhead, then lower them back to your shoulders."
            ],
            breathing: "Inhale into the squat, exhale as you drive up and press.",
            mistakes: [
                "Pausing at the top of the squat, which wastes the leg drive.",
                "Pressing with the arms alone once the legs tire.",
                "Letting the chest drop in the squat so the dumbbells pull you forward."
            ],
            easier: "Split it into squats and presses done separately.",
            harder: "Use heavier dumbbells, or move continuously without pausing at the top."
        ),

        "fb-circuit-5": ExerciseForm(     // Bear Crawl
            steps: [
                "Start on all fours with your hands under your shoulders and knees under your hips.",
                "Lift your knees so they hover just off the floor.",
                "Crawl forward moving the opposite hand and foot together.",
                "Keep your hips low and your back flat throughout."
            ],
            breathing: "Breathe steadily; the position makes it tempting to hold your breath.",
            mistakes: [
                "Letting the hips swing side to side with each step.",
                "Raising the hips high, which turns it into a walking downward dog.",
                "Moving the same-side hand and foot together, which destabilises the whole pattern."
            ],
            easier: "Keep the knees on the floor and just practise the opposite hand-and-foot pattern.",
            harder: "Crawl backward, or add a pause with the knees hovering between steps."
        ),

        // MARK: Full body — Functional

        "fb-func-1": ExerciseForm(        // Farmer's Carry
            steps: [
                "Stand between two heavy dumbbells and deadlift them up with a flat back.",
                "Stand tall with your shoulders pulled back and down, arms hanging straight.",
                "Walk with short, controlled steps, keeping your torso upright.",
                "Set the weights down under control rather than dropping them."
            ],
            breathing: "Breathe steadily as you walk; don't hold your breath for the whole carry.",
            mistakes: [
                "Letting the shoulders round forward under the load.",
                "Leaning back to counterbalance the weight.",
                "Taking long strides, which makes the load swing."
            ],
            easier: "Use lighter weights and carry for a shorter distance.",
            harder: "Go heavier — grip usually fails first, and building it is most of the point."
        ),

        "fb-func-2": ExerciseForm(        // Sled Push
            steps: [
                "Set your hands on the uprights at chest height, or low for more leg drive.",
                "Lean into the sled with a straight line from head to heels.",
                "Drive with short, powerful steps, keeping your hips low.",
                "Keep the sled moving rather than restarting it from a stop."
            ],
            breathing: "Breathe hard and steadily through the push; this is a conditioning effort.",
            mistakes: [
                "Standing too upright, which turns leg drive into a shove from the arms.",
                "Taking long strides that stall the sled between steps.",
                "Going so heavy the sled stops, which trains nothing useful."
            ],
            easier: "Reduce the load until you can keep it moving continuously.",
            harder: "Add weight, or do shorter, harder pushes with full rest between."
        ),

        "fb-func-3": ExerciseForm(        // Tire Flip
            steps: [
                "Set your feet back from the tire and grip under the edge with a flat back.",
                "Drop your hips and drive through your legs to lift the edge, keeping your chest against it.",
                "As it comes up, step in and switch to pushing rather than pulling.",
                "Push it over and reset your position before the next flip."
            ],
            breathing: "Big breath and brace before each lift, exhale as the tire goes over.",
            mistakes: [
                "Lifting with a rounded lower back rather than driving through the legs.",
                "Standing too close, which leaves no room to drive.",
                "Trying to curl the tire up with the arms."
            ],
            easier: "Use a lighter tire until the leg drive and the switch to pushing feel natural.",
            harder: "Use a heavier tire, or flip for distance with no rest between."
        ),

        "fb-func-4": ExerciseForm(        // Sandbag Carry
            steps: [
                "Deadlift the bag up with a flat back, then hug it against your chest.",
                "Stand tall with your elbows tucked under the bag.",
                "Walk with short controlled steps as the load shifts.",
                "Set it down under control rather than dropping it."
            ],
            breathing: "Breathe steadily; the bag against your chest makes deep breaths harder, which is part of it.",
            mistakes: [
                "Letting the bag slip down, which pulls you into a rounded back.",
                "Leaning back to balance rather than bracing.",
                "Rushing, when the shifting load is exactly what you're training for."
            ],
            easier: "Use a lighter bag and carry it over a shorter distance.",
            harder: "Go heavier, or carry it over uneven ground."
        ),

        "fb-func-5": ExerciseForm(        // Battle Ropes
            steps: [
                "Hold one rope end in each hand and stand in a quarter squat, feet shoulder width.",
                "Keep your chest up and your weight through the middle of your feet.",
                "Drive waves down the rope from your shoulders, not your wrists.",
                "Keep the waves reaching the anchor for the whole interval."
            ],
            breathing: "Breathe hard and steadily; this is conditioning work.",
            mistakes: [
                "Standing upright, which removes the legs and leaves it an arm exercise.",
                "Letting the waves die out halfway down the rope as you tire.",
                "Flicking from the wrists rather than driving from the shoulders."
            ],
            easier: "Work in shorter intervals with longer rest.",
            harder: "Alternate wave patterns, or extend the interval."
        ),

        // MARK: Full body — Kettlebell

        "fb-kb-1": ExerciseForm(          // Kettlebell Swing
            steps: [
                "Stand with the bell about a foot in front of you, feet slightly wider than your shoulders.",
                "Hinge at the hips and hike the bell back between your legs.",
                "Snap your hips forward hard and let the bell float up on its own.",
                "Let it fall back down and straight into the next hinge."
            ],
            breathing: "Exhale sharply as the hips snap, inhale as the bell falls.",
            mistakes: [
                "Squatting the bell up instead of hinging, which makes it a front raise.",
                "Lifting with the arms rather than letting the hips throw it.",
                "Leaning back at the top, which loads the lower back."
            ],
            easier: "Practise the hinge with no bell until the movement is automatic.",
            harder: "Use a heavier bell, or swing one-handed."
        ),

        "fb-kb-2": ExerciseForm(          // Kettlebell Goblet Squat
            steps: [
                "Hold the bell by the horns against your chest, elbows tucked in.",
                "Stand with your feet a little wider than your shoulders, toes slightly out.",
                "Squat down until your elbows brush the inside of your knees.",
                "Drive up through your whole foot, keeping the bell tight to your chest."
            ],
            breathing: "Inhale as you descend, exhale as you drive up.",
            mistakes: [
                "Letting the bell drift away from the chest, which pulls you forward.",
                "Rounding the lower back at the bottom of the squat.",
                "Cutting depth once the bell gets heavy."
            ],
            easier: "Use a lighter bell and squat to a box to learn the depth.",
            harder: "Pause two counts at the bottom, or use a heavier bell."
        ),

        "fb-kb-3": ExerciseForm(          // Kettlebell Snatch
            steps: [
                "Start with the bell between your feet and hike it back as you would for a swing.",
                "Snap your hips and pull the bell up close to your body.",
                "As it reaches chest height, punch your hand through and around the handle.",
                "Lock out overhead with the bell resting on the back of your forearm, then guide it back down."
            ],
            breathing: "Exhale on the hip snap, inhale as the bell comes back down.",
            mistakes: [
                "Letting the bell flip over and bang the wrist instead of punching through it.",
                "Muscling the bell up with the arm rather than driving with the hips.",
                "Letting it swing wide away from the body on the way up."
            ],
            easier: "Practise high pulls first, stopping at chest height without going overhead.",
            harder: "Use a heavier bell, or work in longer continuous sets."
        ),

        "fb-kb-4": ExerciseForm(          // Kettlebell Clean
            steps: [
                "Hike the bell back between your legs as you would for a swing.",
                "Snap your hips and pull the bell in close, keeping it near your body.",
                "Guide your hand around the handle so the bell rolls onto your forearm rather than flipping onto it.",
                "Finish in the rack position with the bell resting between your forearm and chest."
            ],
            breathing: "Exhale on the hip snap, inhale as you drop the bell back down.",
            mistakes: [
                "Letting the bell arc away from the body, which lands it hard on the wrist.",
                "Gripping tightly through the catch instead of letting the handle rotate.",
                "Using the arm to curl the bell up into the rack."
            ],
            easier: "Practise the catch from a dead stop at hip height until the bell lands softly.",
            harder: "Use a heavier bell, or clean one bell in each hand at the same time."
        ),

        "fb-kb-5": ExerciseForm(          // Turkish Get-Up
            steps: [
                "Lie on your back with the bell pressed straight up in one hand, that side's knee bent.",
                "Roll onto your opposite elbow, then up onto that hand, keeping the bell locked overhead.",
                "Bridge your hips up and sweep your straight leg back into a half-kneeling position.",
                "Stand up, keeping your eyes on the bell, then reverse every step to return to the floor."
            ],
            breathing: "Breathe steadily at each stage; this is slow, deliberate work, not a single effort.",
            mistakes: [
                "Rushing, which is how the shoulder gets caught out of position.",
                "Letting the arm holding the bell drift out of vertical.",
                "Skipping a step in the sequence, particularly the hip bridge."
            ],
            easier: "Practise the whole sequence with a shoe balanced on your fist instead of a bell.",
            harder: "Use a heavier bell, or pause for a count at each stage of the sequence."
        ),

        // MARK: Full body — Bodyweight Flow

        "fb-flow-1": ExerciseForm(        // Push-Up to Squat
            steps: [
                "Start in a push-up position and perform one push-up.",
                "Jump or step your feet forward to your hands.",
                "Stand up into a full squat position, chest tall.",
                "Reverse it back down to the push-up position without resetting."
            ],
            breathing: "Exhale on each effort — the push-up and the stand.",
            mistakes: [
                "Resetting between the two halves, which breaks the flow the exercise is built on.",
                "Letting the hips sag during the push-up portion.",
                "Standing without actually squatting, which skips half the movement."
            ],
            easier: "Step the feet rather than jumping, and do the push-up from your knees.",
            harder: "Add a jump at the top of the squat."
        ),

        "fb-flow-2": ExerciseForm(        // Inchworm
            steps: [
                "Stand tall, then hinge forward and place your hands on the floor.",
                "Walk your hands out until you reach a plank position.",
                "Hold the plank for a beat, keeping your hips level.",
                "Walk your hands back to your feet and stand up."
            ],
            breathing: "Exhale as you walk out, inhale as you walk back.",
            mistakes: [
                "Letting the hips sag as you reach the plank.",
                "Bending the knees deeply to avoid the hamstring stretch, which is half the value.",
                "Rushing the walk-out so the plank position is never really reached."
            ],
            easier: "Bend the knees as much as you need to get your hands down comfortably.",
            harder: "Add a push-up at the plank, or walk the hands out further."
        ),

        "fb-flow-3": ExerciseForm(        // Plank Jacks
            steps: [
                "Start in a plank on your hands or forearms, body in a straight line.",
                "Jump both feet out wide, then back together.",
                "Keep your hips level throughout — they should not bounce.",
                "Land softly on the balls of your feet."
            ],
            breathing: "Breathe steadily in rhythm with the jumps.",
            mistakes: [
                "Hips piking up with each jump, which is the most common fault here.",
                "Landing heavily, which jars the shoulders.",
                "Speeding up until the plank position collapses."
            ],
            easier: "Step the feet out one at a time instead of jumping.",
            harder: "Increase the pace, or perform them from a forearm plank."
        ),

        "fb-flow-4": ExerciseForm(        // Animal Flow Crawl
            steps: [
                "Start on all fours with your knees hovering just off the floor.",
                "Move opposite hand and foot together, keeping your hips low.",
                "Travel forward, backward and sideways rather than only in one direction.",
                "Move deliberately — this is about control, not speed."
            ],
            breathing: "Breathe steadily throughout rather than holding your breath.",
            mistakes: [
                "Raising the hips, which removes most of the demand.",
                "Rushing, which turns a control drill into scrambling.",
                "Moving same-side hand and foot together, which breaks the pattern."
            ],
            easier: "Keep the knees down and practise the crawling pattern alone.",
            harder: "Add direction changes, or pause with the knees hovering between steps."
        ),

        "fb-flow-5": ExerciseForm(        // Burpee Broad Jump
            steps: [
                "Perform a burpee: squat, hands down, feet back, chest to floor, feet in.",
                "From the standing position, immediately jump forward as far as you can.",
                "Land softly with both feet, absorbing through the knees and hips.",
                "Reset fully to standing before starting the next rep."
            ],
            breathing: "Exhale on the jump, then take a full breath before the next rep.",
            mistakes: [
                "Landing stiff-legged, which is where this movement hurts people.",
                "Rushing the reset and starting the next burpee off balance.",
                "Jumping for distance at the cost of a controlled landing."
            ],
            easier: "Step back the burpee and replace the broad jump with a small hop forward.",
            harder: "Chain the reps continuously, or jump for maximum distance each rep."
        ),

        // MARK: Core — Upper Abs

        "core-upper-1": ExerciseForm(     // Crunches
            steps: [
                "Lie on your back with knees bent and feet flat.",
                "Rest your hands lightly behind your ears or cross them on your chest.",
                "Curl your shoulder blades off the floor by shortening the distance between ribs and hips.",
                "Lower under control without resting your head between reps."
            ],
            breathing: "Exhale as you curl up, inhale as you lower.",
            mistakes: [
                "Pulling on the neck with your hands, which is what makes people's necks ache the next day.",
                "Bouncing off the floor to start each rep.",
                "Trying to sit all the way up, which hands the work to the hip flexors."
            ],
            easier: "Cross your arms on your chest rather than putting your hands behind your head.",
            harder: "Hold a plate on your chest, or pause two counts at the top."
        ),

        "core-upper-2": ExerciseForm(     // Sit-Ups
            steps: [
                "Lie on your back with knees bent and feet flat or anchored.",
                "Curl up starting with your head and shoulders, one section of spine at a time.",
                "Come up until your torso is close to vertical.",
                "Lower with the same control rather than dropping back down."
            ],
            breathing: "Exhale as you come up, inhale as you lower.",
            mistakes: [
                "Yanking the head forward with the hands.",
                "Throwing the arms to generate the momentum to get up.",
                "Dropping flat onto the floor and bouncing into the next rep."
            ],
            easier: "Do crunches instead until you can curl up without momentum.",
            harder: "Hold a weight at your chest, or slow the lowering to four counts."
        ),

        "core-upper-3": ExerciseForm(     // Cable Crunch
            steps: [
                "Kneel facing a high pulley, holding a rope beside your head.",
                "Hinge slightly forward so there is tension before you start.",
                "Crunch by rounding your spine and bringing your elbows toward your knees.",
                "Keep your hips still — only your torso moves — then return under control."
            ],
            breathing: "Exhale as you crunch down, inhale as you return.",
            mistakes: [
                "Rocking at the hips, which turns an ab exercise into a hip hinge.",
                "Pulling with the arms rather than rounding the spine.",
                "Letting the stack drag you upright between reps."
            ],
            easier: "Reduce the weight and shorten the range until the hips stay locked.",
            harder: "Pause two counts in the fully crunched position."
        ),

        "core-upper-4": ExerciseForm(     // Weighted Crunch
            steps: [
                "Lie on your back with knees bent, holding a dumbbell against your chest.",
                "Curl your shoulder blades off the floor.",
                "Keep the weight tight to your chest for the whole rep.",
                "Lower under control."
            ],
            breathing: "Exhale as you curl up, inhale as you lower.",
            mistakes: [
                "Letting the weight drift away from the chest, which strains the neck.",
                "Using the weight's momentum to start each rep.",
                "Adding load before bodyweight crunches are clean."
            ],
            easier: "Drop the weight entirely until three sets of twenty bodyweight crunches feel easy.",
            harder: "Hold the weight straight overhead rather than at your chest."
        ),

        "core-upper-5": ExerciseForm(     // Toe Touches
            steps: [
                "Lie on your back with your legs straight up toward the ceiling.",
                "Reach your hands toward your toes by curling your shoulder blades off the floor.",
                "Keep your legs still — they are a target, not a lever.",
                "Lower under control."
            ],
            breathing: "Exhale as you reach up, inhale as you lower.",
            mistakes: [
                "Swinging the arms to reach further than the abs actually lift you.",
                "Letting the legs drift back toward your head to shorten the distance.",
                "Jerking off the floor rather than curling up."
            ],
            easier: "Bend your knees slightly to take the hamstring stretch out of it.",
            harder: "Hold a light weight in both hands as you reach."
        ),

        // MARK: Core — Lower Abs

        "core-lower-1": ExerciseForm(     // Leg Raises
            steps: [
                "Lie on your back with legs straight and hands under your glutes or flat at your sides.",
                "Press your lower back into the floor and keep it there for every rep.",
                "Raise your legs until they are vertical.",
                "Lower slowly, stopping the moment your back starts to arch."
            ],
            breathing: "Exhale as you raise, inhale as you lower.",
            mistakes: [
                "Letting the lower back arch off the floor as the legs come down — that is the entire exercise.",
                "Swinging the legs up with momentum.",
                "Dropping the legs rather than lowering them."
            ],
            easier: "Bend your knees, or lower only as far as 45 degrees.",
            harder: "Lower all the way to just above the floor and pause there."
        ),

        "core-lower-2": ExerciseForm(     // Reverse Crunch
            steps: [
                "Lie on your back with knees bent at 90 degrees and thighs vertical.",
                "Press your lower back flat into the floor.",
                "Curl your hips off the floor, bringing your knees toward your chest.",
                "Lower under control without letting your feet touch down."
            ],
            breathing: "Exhale as you curl, inhale as you lower.",
            mistakes: [
                "Swinging the legs to generate momentum.",
                "Pushing off the floor with your hands.",
                "Lifting only the knees rather than curling the hips, which moves nothing."
            ],
            easier: "Keep the range small and concentrate on lifting the hips at all.",
            harder: "Slow the lowering to three counts."
        ),

        "core-lower-3": ExerciseForm(     // Flutter Kicks
            steps: [
                "Lie on your back with hands under your glutes and legs straight, a few inches off the floor.",
                "Press your lower back down into the floor.",
                "Alternate small, quick kicks up and down.",
                "Keep the movement small and the back flat throughout."
            ],
            breathing: "Breathe steadily rather than holding your breath — this set feels twice as hard if you do.",
            mistakes: [
                "Letting the lower back arch as fatigue sets in.",
                "Kicking too high, which takes the tension off the abs.",
                "Holding the breath, which shortens the set for no useful reason."
            ],
            easier: "Raise the legs higher, which shortens the leverage.",
            harder: "Lower the legs closer to the floor, or extend the set."
        ),

        "core-lower-4": ExerciseForm(     // Hanging Knee Raise
            steps: [
                "Hang from a bar with straight arms and your shoulders pulled down away from your ears.",
                "Without swinging, curl your knees up toward your chest.",
                "Round your lower back slightly at the top to finish the movement with the abs.",
                "Lower under control and stop any swing before the next rep."
            ],
            breathing: "Exhale as you raise, inhale as you lower.",
            mistakes: [
                "Swinging the body and using the backswing to throw the knees up.",
                "Lifting only to hip height, which makes it a hip flexor exercise rather than an ab one.",
                "Letting the shoulders shrug up toward the ears."
            ],
            easier: "Do them on a captain's chair with your forearms supported.",
            harder: "Keep the legs straight, or pause two counts at the top."
        ),

        "core-lower-5": ExerciseForm(     // Bicycle Crunch
            steps: [
                "Lie on your back with hands lightly behind your ears and legs raised, knees bent.",
                "Curl your shoulder blades off the floor and keep them there.",
                "Bring one elbow toward the opposite knee while extending the other leg.",
                "Alternate slowly and deliberately."
            ],
            breathing: "Exhale on each twist, inhale as you pass through the middle.",
            mistakes: [
                "Racing through reps, which turns it into an arm movement.",
                "Pulling on the neck to get the elbow across.",
                "Letting the shoulders drop back to the floor between reps."
            ],
            easier: "Keep both feet on the floor and just perform the twist.",
            harder: "Slow each rep and pause where the elbow meets the knee."
        ),

        // MARK: Core — Obliques

        "core-oblique-1": ExerciseForm(   // Russian Twist
            steps: [
                "Sit with your knees bent and feet on the floor or raised.",
                "Lean back to around 45 degrees with your back flat, holding a dumbbell at your chest.",
                "Rotate your torso side to side, moving from the ribs rather than just swinging your arms.",
                "Touch the weight down beside each hip if your range allows."
            ],
            breathing: "Exhale on each rotation, inhale as you pass through the middle.",
            mistakes: [
                "Moving only the arms while the torso stays square — the most common way this is done wrong.",
                "Rounding the lower back as you lean.",
                "Going fast enough that the rotation becomes a swing."
            ],
            easier: "Keep your feet on the floor and use no weight at all.",
            harder: "Raise your feet off the floor, or hold a heavier weight."
        ),

        "core-oblique-2": ExerciseForm(   // Side Plank
            steps: [
                "Lie on your side with your elbow directly under your shoulder.",
                "Stack your feet, or stagger them for a wider base.",
                "Lift your hips until your body forms a straight line from ankle to head.",
                "Hold, keeping the hips from drifting down."
            ],
            breathing: "Breathe steadily — holding your breath shortens the hold for no benefit.",
            mistakes: [
                "Letting the hips sag toward the floor as the hold goes on.",
                "Rotating the chest down toward the floor.",
                "Propping on a shoulder that sits ahead of or behind the elbow."
            ],
            easier: "Drop to your bottom knee, keeping the line from knee to head.",
            harder: "Raise the top leg, or rest a weight on your hip."
        ),

        "core-oblique-3": ExerciseForm(   // Woodchopper
            steps: [
                "Set a cable high or low and stand side-on with feet shoulder width.",
                "Grip the handle with both hands and brace your midsection.",
                "Rotate through your torso, pulling the handle diagonally across your body.",
                "Let your hips pivot naturally with the rotation, then return under control."
            ],
            breathing: "Exhale through the chop, inhale as you return.",
            mistakes: [
                "Pulling with the arms rather than rotating through the torso.",
                "Locking the hips so the lower back absorbs the rotation.",
                "Letting the cable snap you back to the start."
            ],
            easier: "Reduce the weight and shorten the arc.",
            harder: "Pause at the end of the chop for two counts."
        ),

        "core-oblique-4": ExerciseForm(   // Bicycle Crunch Oblique Focus
            steps: [
                "Set up as for a bicycle crunch, hands behind your ears and legs raised.",
                "Rotate further than a standard bicycle crunch, driving the shoulder rather than the elbow toward the knee.",
                "Pause briefly at the fully rotated position.",
                "Alternate slowly, one side at a time."
            ],
            breathing: "Exhale on each twist, inhale between reps.",
            mistakes: [
                "Leading with the elbow instead of rotating the shoulder, which skips the obliques entirely.",
                "Speeding up until the rotation disappears.",
                "Pulling on the neck to get further round."
            ],
            easier: "Keep your feet on the floor and rotate without the leg action.",
            harder: "Hold each rotated position for two counts."
        ),

        "core-oblique-5": ExerciseForm(   // Standing Oblique Crunch
            steps: [
                "Stand holding a dumbbell in one hand at your side.",
                "Keep your hips square and facing forward throughout.",
                "Bend sideways at the waist toward the weighted side.",
                "Pull back up using the opposite obliques, then finish all reps before switching."
            ],
            breathing: "Exhale as you pull up, inhale as you bend down.",
            mistakes: [
                "Leaning forward or backward instead of straight out to the side.",
                "Using a weight heavy enough that it simply drags you down.",
                "Holding a dumbbell in each hand, which cancels the resistance out completely."
            ],
            easier: "Use a lighter dumbbell and a smaller range.",
            harder: "Pause at the bottom of the stretch for two counts."
        ),

        // MARK: Core — Deep Core & Stability

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

        "core-deep-2": ExerciseForm(      // Dead Bug
            steps: [
                "Lie on your back with arms straight up and knees bent at 90 degrees over your hips.",
                "Press your lower back flat into the floor and keep it there.",
                "Slowly extend one arm overhead and the opposite leg toward the floor.",
                "Return under control and repeat on the other side."
            ],
            breathing: "Exhale as you extend, inhale as you return.",
            mistakes: [
                "Letting the lower back lift off the floor as the limbs extend — that is the whole exercise.",
                "Rushing, which turns a control drill into a stretch.",
                "Extending further than you can hold the back down for."
            ],
            easier: "Move only the legs, keeping your arms still.",
            harder: "Slow each extension to four counts, or hold a light weight in each hand."
        ),

        "core-deep-3": ExerciseForm(      // Bird Dog
            steps: [
                "Start on all fours with hands under your shoulders and knees under your hips.",
                "Brace your midsection and set your back flat.",
                "Extend one arm forward and the opposite leg back until both are level with your torso.",
                "Hold, then return under control and switch sides."
            ],
            breathing: "Breathe steadily through the hold rather than bracing against a held breath.",
            mistakes: [
                "Letting the hips rotate open as the leg extends.",
                "Arching the lower back to get the leg higher.",
                "Rushing, so the position is never actually held."
            ],
            easier: "Extend only the leg, or only the arm, until the balance is there.",
            harder: "Hold each rep longer, or draw the elbow and knee together under your body between reps."
        ),

        "core-deep-4": ExerciseForm(      // Pallof Press
            steps: [
                "Stand side-on to a cable set at chest height, holding the handle at your chest.",
                "Step away until there is real tension trying to rotate you.",
                "Brace, then press the handle straight out in front of you.",
                "Resist the rotation the whole time, then return to your chest under control."
            ],
            breathing: "Exhale as you press out, inhale as you return.",
            mistakes: [
                "Letting the torso rotate toward the machine as you press.",
                "Leaning away to counterbalance instead of bracing against the pull.",
                "Going heavy enough that your feet shift position."
            ],
            easier: "Stand closer to the machine, which reduces the rotational pull.",
            harder: "Step further away, or hold the pressed-out position for five counts."
        ),

        "core-deep-5": ExerciseForm(      // Hollow Body Hold
            steps: [
                "Lie on your back and press your lower back flat into the floor.",
                "Lift your shoulder blades and your legs off the floor at the same time.",
                "Reach your arms past your ears if you can hold the position there.",
                "Keep the lower back pressed down for the entire hold."
            ],
            breathing: "Breathe shallowly and steadily — the position makes deep breaths difficult by design.",
            mistakes: [
                "Letting the lower back arch, which is the moment the hold stops doing anything.",
                "Lifting the head with the neck rather than raising the shoulders.",
                "Holding on past the point where the position has already broken."
            ],
            easier: "Tuck your knees and keep your arms by your sides.",
            harder: "Extend the arms overhead and lower the legs closer to the floor."
        ),

        // MARK: Core — Lower Back

        "core-lowback-1": ExerciseForm(   // Superman
            steps: [
                "Lie face down with your arms extended overhead.",
                "Squeeze your glutes before you lift.",
                "Raise your arms, chest and legs off the floor at the same time.",
                "Hold, then lower under control."
            ],
            breathing: "Breathe steadily; don't hold your breath in the lifted position.",
            mistakes: [
                "Cranking the neck back to get the head higher.",
                "Lifting only the legs and leaving the chest on the floor.",
                "Bouncing between reps rather than holding each one."
            ],
            easier: "Lift only the arms, or only the legs, alternating between reps.",
            harder: "Hold each rep longer, or hold a light weight in your hands."
        ),

        "core-lowback-2": ExerciseForm(   // Back Extension
            steps: [
                "Set the pad just below your hip bones so you can hinge freely.",
                "Cross your arms on your chest, or hold a plate there.",
                "Hinge down at the hips with a flat back.",
                "Raise until your body forms a straight line, and stop there."
            ],
            breathing: "Inhale as you lower, exhale as you rise.",
            mistakes: [
                "Hyperextending past straight at the top, which compresses the lower back.",
                "Rounding the back on the way down instead of hinging.",
                "Setting the pad too high, which blocks the hip hinge entirely."
            ],
            easier: "Use no weight and a smaller range until the hinge is clean.",
            harder: "Hold a plate at your chest, or pause two counts at the top."
        ),

        "core-lowback-3": ExerciseForm(   // Good Morning
            steps: [
                "Set the bar on your upper back, feet hip width, knees soft.",
                "Brace hard before you move at all.",
                "Push your hips straight back and hinge with a flat back.",
                "Stop when your hamstrings limit the range, then drive the hips forward to stand."
            ],
            breathing: "Breath at the top, hold and stay braced through the hinge, exhale once standing.",
            mistakes: [
                "Adding weight before the hinge pattern is automatic.",
                "Letting the back round, which is exactly what makes this lift risky.",
                "Bending the knees enough that it becomes a squat."
            ],
            easier: "Do it with your hands crossed on your chest and no bar at all.",
            harder: "Add five pounds at a time, and pause briefly at the bottom."
        ),

        "core-lowback-4": ExerciseForm(   // Bird Dog Row
            steps: [
                "Set up with one hand and both knees down, or in a three-point stance with a dumbbell in one hand.",
                "Brace so your back stays flat and your hips stay square to the floor.",
                "Row the dumbbell to your hip.",
                "Lower under control without letting the torso rotate."
            ],
            breathing: "Exhale as you row, inhale as you lower.",
            mistakes: [
                "Rotating the torso to lift a heavier weight, which defeats the anti-rotation purpose.",
                "Letting the hips drop or twist during the row.",
                "Rushing, so the bracing never really happens."
            ],
            easier: "Use a lighter dumbbell and concentrate on keeping the hips square.",
            harder: "Extend the opposite leg, or pause at the top of every row."
        ),

        "core-lowback-5": ExerciseForm(   // Cat-Cow
            steps: [
                "Start on all fours with hands under your shoulders and knees under your hips.",
                "Exhale and round your spine, tucking your chin and your pelvis.",
                "Inhale and reverse it, lifting your chest and tailbone.",
                "Move slowly between the two positions."
            ],
            breathing: "Exhale into the rounded position, inhale into the arched one — the breath sets the pace.",
            mistakes: [
                "Rushing, so the spine never moves through its full range.",
                "Moving only the lower back and leaving the upper spine stiff.",
                "Forcing the range rather than easing into it."
            ],
            easier: "Reduce the range and move only within what feels comfortable.",
            harder: "Slow each direction to five counts and pause at each end."
        ),

        // MARK: Cardio — Steady-State

        "cardio-steady-1": ExerciseForm(  // Treadmill Jog
            steps: [
                "Start with a few minutes of walking before you pick up the pace.",
                "Run in the middle of the belt, not crowding the console.",
                "Keep your steps light and land under your hips rather than out in front.",
                "Hold a pace you could just about talk at, and finish with a walking cool-down."
            ],
            breathing: "Steady and rhythmic. If you can't speak a short sentence, you're going too fast.",
            mistakes: [
                "Holding the handrails, which changes your gait and cuts the work.",
                "Drifting to the back of the belt and then surging to catch up.",
                "Setting a pace that only lasts five minutes of a thirty-minute run."
            ],
            easier: "Alternate jogging and walking in blocks rather than running the whole time.",
            harder: "Add a one or two percent incline, which better matches running outdoors."
        ),

        "cardio-steady-2": ExerciseForm(  // Outdoor Run
            steps: [
                "Start slower than feels natural for the first five minutes.",
                "Keep your posture tall with a slight forward lean from the ankles, not the waist.",
                "Land with your foot under your hips and keep your steps quiet.",
                "Ease off before you're spent, and walk the last few minutes."
            ],
            breathing: "Settle into a rhythm you can hold. Nose or mouth is fine; consistency matters more.",
            mistakes: [
                "Setting off at a pace set by how you feel in minute one.",
                "Overstriding, reaching the foot far out in front, which brakes every step.",
                "Adding distance faster than about ten percent a week."
            ],
            easier: "Run and walk in intervals, and build the running blocks over weeks.",
            harder: "Add distance or introduce hills — one variable at a time, not both."
        ),

        "cardio-steady-3": ExerciseForm(  // Elliptical
            steps: [
                "Stand tall with your feet flat on the pedals and your weight through the middle of each foot.",
                "Hold the moving handles lightly and drive with your legs.",
                "Keep a smooth continuous stroke rather than surging and coasting.",
                "Set resistance high enough that you're driving the pedals, not being carried by them."
            ],
            breathing: "Steady and rhythmic, matched to your stride.",
            mistakes: [
                "Leaning on the fixed handles, which takes your bodyweight out of the work.",
                "Setting resistance so low that momentum does the pedalling.",
                "Bouncing up onto the toes rather than keeping the feet flat."
            ],
            easier: "Reduce resistance and hold a comfortable stride rate.",
            harder: "Raise the resistance, or drive backward for a set to shift the emphasis."
        ),

        "cardio-steady-4": ExerciseForm(  // Stationary Bike
            steps: [
                "Set the saddle so your knee stays slightly bent at the bottom of the stroke.",
                "Sit upright with a relaxed grip and your elbows soft.",
                "Pedal in smooth circles rather than stamping down.",
                "Hold a cadence you can sustain, adjusting resistance rather than speed."
            ],
            breathing: "Steady throughout; you should be able to speak in short sentences.",
            mistakes: [
                "A saddle too low, which is the most common cause of sore knees on a bike.",
                "Resistance so low the legs spin without effort.",
                "Gripping the bars hard and hunching the shoulders."
            ],
            easier: "Lower the resistance and keep the cadence comfortable.",
            harder: "Raise the resistance, or hold a higher cadence for timed blocks."
        ),

        "cardio-steady-5": ExerciseForm(  // Stair Climber
            steps: [
                "Stand tall and let your hands rest lightly on the rails for balance only.",
                "Place your whole foot on each step, not just the toes.",
                "Take full steps rather than short shuffling ones.",
                "Keep the pace steady rather than chasing the machine."
            ],
            breathing: "Steady and controlled; this gets hard quickly if you go out fast.",
            mistakes: [
                "Leaning heavily on the rails, which removes most of the work.",
                "Taking tiny quick steps to keep up with a speed that's too high.",
                "Rising onto the toes so the calves take everything."
            ],
            easier: "Lower the speed and concentrate on full, flat steps.",
            harder: "Take the steps two at a time, or let go of the rails entirely."
        ),

        // MARK: Cardio — Intervals

        "cardio-int-1": ExerciseForm(     // Treadmill Sprints
            steps: [
                "Warm up for at least five minutes before the first hard effort.",
                "Set the speed while straddling the belt with your feet on the side rails.",
                "Step on carefully with the belt already moving, holding the rails until you're up to speed.",
                "Step back off to the rails to rest rather than slowing the belt each time."
            ],
            breathing: "Breathe hard during the effort and recover fully between; don't cut the rest short.",
            mistakes: [
                "Jumping onto a fast-moving belt without holding on first.",
                "Cutting rest intervals, which turns sprints into a mediocre steady run.",
                "Skipping the warm-up, which is how hamstrings get pulled."
            ],
            easier: "Use a lower top speed and longer recovery between efforts.",
            harder: "Increase speed or add an incline, and shorten the rest slightly."
        ),

        "cardio-int-2": ExerciseForm(     // Bike Intervals
            steps: [
                "Warm up for five minutes at an easy resistance.",
                "For each effort, raise the resistance and hold a strong steady cadence.",
                "Drop the resistance right down for the recovery — keep the legs turning.",
                "Finish with several easy minutes."
            ],
            breathing: "Hard through the effort, and let it settle fully during recovery.",
            mistakes: [
                "Increasing cadence but not resistance, which spins the legs without loading them.",
                "Stopping dead in the recovery, which makes the next effort worse.",
                "Going so hard on the first interval that the last three collapse."
            ],
            easier: "Shorten the efforts and lengthen the recoveries.",
            harder: "Raise the resistance for each effort, or shorten the recovery."
        ),

        "cardio-int-3": ExerciseForm(     // Rowing Intervals
            steps: [
                "Set the damper around 4 or 5 — higher is not harder, just slower and heavier.",
                "Drive with the legs first, then swing the torso back, then pull the handle to your ribs.",
                "Reverse that order on the recovery: arms away, torso forward, then bend the knees.",
                "Hold that sequence at pace for each effort, and paddle lightly between."
            ],
            breathing: "Exhale on the drive, inhale on the recovery, and keep it rhythmic under fatigue.",
            mistakes: [
                "Pulling with the arms before the legs have driven — the single most common rowing fault.",
                "Setting the damper to 10 in the belief it's a strength setting.",
                "Rushing the recovery so the stroke rate climbs while power falls."
            ],
            easier: "Row at a lower rate with longer rests, focusing on the sequence.",
            harder: "Extend the efforts, or hold a target split rather than just going hard."
        ),

        "cardio-int-4": ExerciseForm(     // Assault Bike Intervals
            steps: [
                "Set the seat height as you would for a normal bike.",
                "Drive with both arms and legs together rather than favouring one.",
                "Go hard from the first second of each effort — the fan builds resistance as you speed up.",
                "Keep the legs turning slowly through the recovery."
            ],
            breathing: "Breathe hard; recovery on this machine takes longer than it feels like it should.",
            mistakes: [
                "Pacing the first effort as though it were a long ride.",
                "Using only the legs and letting the arms go along for the ride.",
                "Stopping completely in recovery, which makes restarting brutal."
            ],
            easier: "Shorter efforts with double the recovery time.",
            harder: "Lengthen the effort by ten seconds at a time, not more."
        ),

        "cardio-int-5": ExerciseForm(     // Track Intervals
            steps: [
                "Warm up with at least ten minutes of easy running plus some strides.",
                "Run each repetition at a pace you could hold for all of them, not just the first.",
                "Jog or walk the recovery rather than standing still.",
                "Cool down with easy running afterwards."
            ],
            breathing: "Hard through each repetition; use the recovery to bring it back under control.",
            mistakes: [
                "Running the first repetition far faster than the rest, which ruins the session.",
                "Skipping the warm-up before fast running.",
                "Standing still between efforts, which stiffens the legs."
            ],
            easier: "Fewer repetitions with longer recoveries.",
            harder: "Add repetitions, or shorten the recovery while holding the same pace."
        ),

        // MARK: Cardio — Incline & Stairs

        "cardio-incl-1": ExerciseForm(    // Incline Treadmill Walk
            steps: [
                "Start flat for a couple of minutes, then raise the incline.",
                "Walk tall without leaning into the console.",
                "Keep your whole foot landing on the belt, heel included.",
                "Choose an incline you can walk at without holding on."
            ],
            breathing: "Steady; this should feel like sustained work, not an all-out effort.",
            mistakes: [
                "Gripping the rails, which removes most of the benefit of the incline.",
                "Setting an incline so steep you have to hold on to stay on.",
                "Rising onto the toes rather than keeping the heels down."
            ],
            easier: "Reduce the incline until you can walk hands-free comfortably.",
            harder: "Raise the incline before you raise the speed."
        ),

        "cardio-incl-2": ExerciseForm(    // StairMaster
            steps: [
                "Stand tall with your hands resting lightly on the rails.",
                "Put your whole foot on each step.",
                "Take full steps and let the machine set a steady rhythm.",
                "Keep your torso upright rather than folding over the console."
            ],
            breathing: "Steady and controlled — this climbs in difficulty faster than it looks.",
            mistakes: [
                "Leaning your bodyweight onto the rails, which is most of the work gone.",
                "Short shuffling steps to keep up with too high a speed.",
                "Staying on the toes, which loads the calves and nothing else."
            ],
            easier: "Slow the speed and concentrate on full flat steps.",
            harder: "Take two steps at a time, or take your hands off the rails."
        ),

        "cardio-incl-3": ExerciseForm(    // Hill Sprints
            steps: [
                "Warm up thoroughly — at least ten minutes including some faster running.",
                "Pick a hill steep enough to slow you down but not so steep you can't run tall.",
                "Sprint up with short powerful steps and strong arm drive.",
                "Walk all the way back down as recovery, and start the next only when ready."
            ],
            breathing: "All out during the climb; take as long as you need walking down.",
            mistakes: [
                "Skipping the warm-up, which is how hamstrings tear on the first rep.",
                "Running the descent, which is where hill sessions cause injuries.",
                "Adding reps until form falls apart rather than stopping while sharp."
            ],
            easier: "Use a gentler hill and fewer repetitions.",
            harder: "Add repetitions gradually, or find a steeper hill — not both at once."
        ),

        "cardio-incl-4": ExerciseForm(    // Incline Bike
            steps: [
                "Set the saddle height so your knee stays slightly bent at the bottom.",
                "Raise the resistance to simulate a climb rather than increasing cadence.",
                "Stay seated for most of it, keeping your upper body still.",
                "Drop the resistance for a few easy minutes at the end."
            ],
            breathing: "Steady and deep; climbing efforts reward a settled rhythm.",
            mistakes: [
                "Rocking the hips side to side as the resistance climbs.",
                "Standing up on the pedals for long stretches, which tires you without adding much.",
                "Choosing a resistance that drops your cadence below a turnable pace."
            ],
            easier: "Lower the resistance and hold a steady cadence.",
            harder: "Raise the resistance in blocks, alternating with easier recovery minutes."
        ),

        "cardio-incl-5": ExerciseForm(    // Stadium Stairs
            steps: [
                "Warm up with a few easy laps or a gentle jog before climbing.",
                "Drive up with your whole foot landing on each step.",
                "Use your arms — they do more of the work than people expect.",
                "Walk down carefully, taking the descent as recovery."
            ],
            breathing: "Hard on the way up; use the descent to bring your breathing back down.",
            mistakes: [
                "Running down the steps, which is where ankles get rolled.",
                "Landing only on the toes, which fatigues the calves early.",
                "Setting off at a pace only the first climb can sustain."
            ],
            easier: "Climb every other flight, walking the rest.",
            harder: "Take two steps at a time, or reduce the rest between climbs."
        ),

        // MARK: Cardio — Cycling

        "cardio-cycle-1": ExerciseForm(   // Spin Class
            steps: [
                "Set your saddle height and fore-aft position before the class starts.",
                "Keep a firm but relaxed grip; your weight belongs on the pedals, not the bars.",
                "Add resistance when told to rather than just spinning faster.",
                "Sit back down and recover when you need to — the class pace is a guide, not a rule."
            ],
            breathing: "Follow the effort; hard in the intervals and settled in the recoveries.",
            mistakes: [
                "Riding with almost no resistance and very high cadence, which bounces you in the saddle.",
                "Not setting the bike up before the lights go down.",
                "Standing for long stretches with too little resistance to support you."
            ],
            easier: "Take the recoveries fully and skip the standing sections.",
            harder: "Add resistance during the efforts rather than chasing the cadence."
        ),

        "cardio-cycle-2": ExerciseForm(   // Road Cycling
            steps: [
                "Check tyres and brakes before you set off.",
                "Ride with a relaxed upper body and soft elbows to absorb the road.",
                "Keep a smooth cadence, changing gear before hills rather than during them.",
                "Ride predictably in traffic and signal your turns clearly."
            ],
            breathing: "Steady on the flat, deeper on the climbs; settle it again on descents.",
            mistakes: [
                "Grinding a heavy gear at low cadence, which is hard on the knees.",
                "Locking the elbows, so every bump goes straight into your shoulders.",
                "Leaving gear changes until you're already on the climb."
            ],
            easier: "Ride flatter routes and shorter distances while you build up.",
            harder: "Add distance or add hills, increasing by roughly ten percent a week."
        ),

        "cardio-cycle-3": ExerciseForm(   // Indoor Cycling
            steps: [
                "Set the saddle so your knee is slightly bent at the bottom of the stroke.",
                "Sit upright with relaxed shoulders.",
                "Pedal in smooth circles, thinking about pulling through the bottom as well as pushing down.",
                "Use resistance rather than raw speed to make it harder."
            ],
            breathing: "Steady; you should be able to hold a short conversation on easy sections.",
            mistakes: [
                "Bouncing in the saddle, which means the resistance is too low for the cadence.",
                "A saddle set too low, which is the usual cause of knee pain.",
                "Holding the bars tightly and hunching over them."
            ],
            easier: "Lower resistance, shorter sessions, and build the time first.",
            harder: "Add resistance blocks, or hold a higher cadence at the same resistance."
        ),

        "cardio-cycle-4": ExerciseForm(   // Hill Cycling
            steps: [
                "Shift into an easier gear before the gradient starts.",
                "Stay seated where you can, sliding slightly back to use the glutes.",
                "Stand only for short steep sections, keeping the bike steady beneath you.",
                "Settle back into a rhythm as soon as the gradient eases."
            ],
            breathing: "Deep and steady; panic breathing on a climb usually means the gear is too big.",
            mistakes: [
                "Changing gear mid-climb under load, which is hard on the drivetrain and your legs.",
                "Standing for the entire climb and burning out halfway.",
                "Starting the climb at a pace set by the flat road before it."
            ],
            easier: "Use easier gears and take climbs at a pace you could talk at.",
            harder: "Ride longer climbs, or hold a seated position where you'd normally stand."
        ),

        "cardio-cycle-5": ExerciseForm(   // Recovery Ride
            steps: [
                "Set an easy gear and keep resistance low throughout.",
                "Spin at a comfortable cadence without pushing.",
                "Keep your breathing entirely conversational.",
                "Finish feeling looser than when you started, not tired."
            ],
            breathing: "Easy and conversational the whole way. If it isn't, you're riding too hard.",
            mistakes: [
                "Turning a recovery ride into a moderate one because you feel good.",
                "Chasing segments or other riders.",
                "Riding long enough that it stops being recovery."
            ],
            easier: "Ride for less time; the intensity is already as low as it should be.",
            harder: "There is no harder version — that's the point of the session."
        ),

        // MARK: Cardio — Rowing

        "cardio-row-1": ExerciseForm(     // Rowing Machine Steady
            steps: [
                "Set the damper around 4 or 5 and strap your feet so the strap crosses the ball of the foot.",
                "Start compressed with shins vertical, arms straight, shoulders in front of the hips.",
                "Drive with the legs, then swing the torso back, then pull the handle to the bottom of your ribs.",
                "Recover in reverse: arms away, torso forward, then bend the knees."
            ],
            breathing: "Exhale on the drive, inhale on the recovery.",
            mistakes: [
                "Pulling with the arms before the legs have driven, which is the classic rowing error.",
                "Cranking the damper to 10 thinking it makes the workout harder.",
                "Rushing the recovery so the ratio inverts and the stroke rate climbs pointlessly."
            ],
            easier: "Row at a low rate and focus purely on the order of the sequence.",
            harder: "Hold a target split for the whole piece rather than letting it drift."
        ),

        "cardio-row-2": ExerciseForm(     // Rowing Sprints
            steps: [
                "Warm up with several easy minutes and a few build strokes.",
                "Start each sprint from a controlled catch rather than a lunge at the handle.",
                "Drive hard with the legs; the arms finish the stroke, they don't start it.",
                "Paddle lightly between efforts rather than stopping."
            ],
            breathing: "Hard through the effort; recover fully before the next.",
            mistakes: [
                "Winding the rate up while power drops, so the split gets worse as you row faster.",
                "Yanking with the arms and back at the catch.",
                "Sitting still between sprints, which stiffens the legs."
            ],
            easier: "Shorter sprints with double the rest.",
            harder: "Lengthen the sprints, or hold a target split across all of them."
        ),

        "cardio-row-3": ExerciseForm(     // Rowing Pyramid
            steps: [
                "Plan the ladder before you start — for example 250, 500, 750, 500, 250 metres.",
                "Hold the same technique at every distance; only the pace changes.",
                "Rest in proportion to the piece just finished.",
                "Row the descending half at least as fast as the ascending half."
            ],
            breathing: "Match the effort of each piece; the longer ones should feel controlled.",
            mistakes: [
                "Going out too hard on the short pieces and fading through the middle.",
                "Letting technique slip on the longest piece.",
                "Cutting rest as the pyramid descends, which turns it into a grind."
            ],
            easier: "Use a shorter ladder with more rest between pieces.",
            harder: "Extend the ladder, or keep rest fixed regardless of piece length."
        ),

        "cardio-row-4": ExerciseForm(     // SkiErg
            steps: [
                "Stand a comfortable arm's length from the machine with feet hip width.",
                "Reach up and grip the handles high, then hinge at the hips as you pull down.",
                "Drive the pull through your torso and lats rather than just your arms.",
                "Stand back up and reach tall for the next stroke."
            ],
            breathing: "Exhale on the pull down, inhale as you reach back up.",
            mistakes: [
                "Pulling with the arms alone and leaving the hips out of it.",
                "Squatting rather than hinging, which shortens the pull.",
                "Not reaching tall at the top, which cuts the stroke short."
            ],
            easier: "Shorter intervals, focusing on the hinge and full reach.",
            harder: "Longer pieces, or hold a target split throughout."
        ),

        "cardio-row-5": ExerciseForm(     // Row + Bike Combo
            steps: [
                "Set both machines up before you start so transitions are quick.",
                "Row the first block at a controlled pace you can repeat.",
                "Move straight to the bike and keep the legs turning from the first second.",
                "Alternate for the planned number of rounds, finishing with easy minutes on either."
            ],
            breathing: "Steady across both; the transition is where breathing usually gets ragged.",
            mistakes: [
                "Attacking the row and having nothing left for the bike.",
                "Taking a long break at each transition, which breaks the session's purpose.",
                "Letting rowing technique fall apart once the legs are tired from the bike."
            ],
            easier: "Shorter blocks on each machine, with a minute of easy work between.",
            harder: "Extend the blocks, or remove the transition rest entirely."
        ),

        // MARK: Flexibility — Static Stretching

        "flex-static-1": ExerciseForm(    // Hamstring Stretch
            steps: [
                "Sit or stand with one leg straight and the foot flexed.",
                "Hinge forward from the hips, keeping your back flat rather than rounding.",
                "Stop where you feel a strong but tolerable stretch behind the thigh.",
                "Hold, easing slightly deeper on each exhale."
            ],
            breathing: "Breathe slowly. Ease deeper on the exhale rather than forcing on the inhale.",
            mistakes: [
                "Rounding the back to reach further, which stretches the spine instead of the hamstring.",
                "Bouncing in and out of the position.",
                "Pushing to the point of pain, which makes the muscle guard against the stretch."
            ],
            easier: "Bend the knee slightly, or loop a strap around the foot.",
            harder: "Hold longer rather than pushing deeper — time does more here than force."
        ),

        "flex-static-2": ExerciseForm(    // Quad Stretch
            steps: [
                "Stand tall and hold a wall or chair for balance.",
                "Bend one knee and take that ankle behind you.",
                "Keep your knees level with each other and your hips square.",
                "Gently push the hip forward until you feel the front of the thigh lengthen."
            ],
            breathing: "Slow and steady; don't hold your breath to hold the balance.",
            mistakes: [
                "Letting the bent knee drift out to the side, which loses the stretch.",
                "Arching the lower back to feel more, rather than tucking the pelvis.",
                "Pulling the heel hard into the glute, which strains the knee."
            ],
            easier: "Lie on your side to do it, which removes the balance element.",
            harder: "Tuck the pelvis under before pushing the hip forward."
        ),

        "flex-static-3": ExerciseForm(    // Chest Doorway Stretch
            steps: [
                "Place your forearm on a doorframe with your elbow at about shoulder height.",
                "Step forward through the doorway until you feel the chest open.",
                "Keep your ribs down and your shoulder blade drawn back, not shrugged.",
                "Hold, then repeat with the elbow higher and lower to reach different fibres."
            ],
            breathing: "Breathe into the ribs; the stretch eases as the chest relaxes.",
            mistakes: [
                "Letting the ribs flare and the lower back arch to get further.",
                "Shrugging the shoulder up toward the ear.",
                "Cranking hard into it rather than stepping through gradually."
            ],
            easier: "Step through less far and hold for longer.",
            harder: "Rotate the torso slightly away from the arm at the end range."
        ),

        "flex-static-4": ExerciseForm(    // Shoulder Cross-Body Stretch
            steps: [
                "Bring one arm across your chest at about shoulder height.",
                "Use the opposite forearm to draw it closer, hooking above the elbow.",
                "Keep the shoulder of the stretching arm down, not lifted toward your ear.",
                "Hold, then swap sides."
            ],
            breathing: "Slow and relaxed; tension in the neck defeats the stretch.",
            mistakes: [
                "Pulling on the elbow joint itself rather than above it.",
                "Letting the stretching shoulder ride up toward the ear.",
                "Rotating the torso to fake more range."
            ],
            easier: "Take the arm slightly lower across the body.",
            harder: "Hold longer, or add a gentle rotation away at the end."
        ),

        "flex-static-5": ExerciseForm(    // Calf Wall Stretch
            steps: [
                "Stand facing a wall with hands on it at chest height.",
                "Step one foot back, keeping that leg straight and the heel down.",
                "Lean into the wall until you feel the calf lengthen.",
                "Then bend the back knee slightly to shift the stretch lower toward the achilles."
            ],
            breathing: "Slow and steady throughout the hold.",
            mistakes: [
                "Letting the back heel lift, which removes the stretch entirely.",
                "Turning the back foot out, which lets the ankle avoid the range.",
                "Only doing the straight-leg version and skipping the bent-knee one."
            ],
            easier: "Step back less far and keep the lean gentle.",
            harder: "Step further back, or do it with the ball of the foot on a step."
        ),

        // MARK: Flexibility — Dynamic Mobility

        "flex-dyn-1": ExerciseForm(       // Leg Swings
            steps: [
                "Hold a wall or post for balance and stand tall.",
                "Swing one leg forward and back in a controlled arc.",
                "Start small and let the range grow over the first several swings.",
                "Switch to side-to-side swings, then repeat on the other leg."
            ],
            breathing: "Breathe normally; this is a warm-up, not a held stretch.",
            mistakes: [
                "Starting at full range on the first swing.",
                "Letting the torso swing to throw the leg higher.",
                "Swinging so fast the leg is being flung rather than moved."
            ],
            easier: "Keep the range small and the pace slow.",
            harder: "Increase the range gradually, and add the side-to-side direction."
        ),

        "flex-dyn-2": ExerciseForm(       // Arm Circles
            steps: [
                "Stand tall with your arms out to the sides at shoulder height.",
                "Make small circles forward, gradually growing them.",
                "Reverse the direction and repeat.",
                "Keep your shoulders down rather than letting them creep up."
            ],
            breathing: "Breathe normally throughout.",
            mistakes: [
                "Starting with large circles before the shoulders are warm.",
                "Shrugging the shoulders toward the ears as the circles grow.",
                "Arching the lower back as the arms travel behind you."
            ],
            easier: "Keep the circles small throughout.",
            harder: "Grow to full range in both directions, and slow the tempo down."
        ),

        "flex-dyn-3": ExerciseForm(       // Walking Lunges with Twist
            steps: [
                "Step forward into a lunge, lowering until the back knee is just off the floor.",
                "With the front foot planted, rotate your torso toward the front leg.",
                "Rotate back to centre, then drive up and step into the next lunge.",
                "Alternate sides as you travel forward."
            ],
            breathing: "Exhale as you rotate, inhale as you return to centre.",
            mistakes: [
                "Rotating from the shoulders alone rather than through the whole torso.",
                "Letting the front knee drift inward under load.",
                "Rushing so the rotation never really happens."
            ],
            easier: "Do it stationary rather than walking, and reduce the rotation.",
            harder: "Hold a light weight at the chest while rotating."
        ),

        "flex-dyn-4": ExerciseForm(       // Hip Openers
            steps: [
                "Stand tall holding something for balance.",
                "Lift one knee to hip height, then rotate it out to the side and back down.",
                "Reverse the direction, taking the knee out to the side first.",
                "Keep the torso upright rather than leaning away."
            ],
            breathing: "Breathe normally; this is preparation, not a stretch to hold.",
            mistakes: [
                "Leaning the torso away to get the knee higher.",
                "Rushing so the rotation is a swing rather than a controlled circle.",
                "Only going in one direction."
            ],
            easier: "Lower the knee height and keep the circles small.",
            harder: "Do it without holding on, which adds a balance demand."
        ),

        "flex-dyn-5": ExerciseForm(       // World's Greatest Stretch
            steps: [
                "Step into a deep lunge with your front foot flat and hands on the floor inside it.",
                "Drop the back knee toward the floor to open the hip flexor.",
                "Place the inside hand down and rotate the outside arm up toward the ceiling.",
                "Return the hand down, then straighten the front leg into a hamstring stretch before switching sides."
            ],
            breathing: "Exhale as you rotate open, inhale as you return.",
            mistakes: [
                "Rushing through the positions rather than pausing in each one.",
                "Rotating from the arm rather than the torso.",
                "Skipping the hamstring portion at the end, which is half the value."
            ],
            easier: "Drop the back knee to the floor and skip the rotation at first.",
            harder: "Hold each position for several breaths before moving on."
        ),

        // MARK: Flexibility — Yoga Flow

        "flex-yoga-1": ExerciseForm(      // Sun Salutation Flow
            steps: [
                "Start standing tall, then reach overhead on an inhale.",
                "Fold forward on the exhale, then half-lift the chest on the next inhale.",
                "Step or jump back to a plank, lower down, then press to upward dog.",
                "Push back to downward dog, hold for a breath or two, then step forward and rise."
            ],
            breathing: "One movement per breath. The breath sets the pace, not the other way round.",
            mistakes: [
                "Moving faster than the breath, which turns a flow into a rushed circuit.",
                "Letting the hips sag in plank and upward dog.",
                "Locking the knees in the forward fold rather than keeping a soft bend."
            ],
            easier: "Step rather than jump between positions, and bend the knees in the fold.",
            harder: "Slow it down and add a breath in each position rather than speeding up."
        ),

        "flex-yoga-2": ExerciseForm(      // Vinyasa Flow
            steps: [
                "Begin with a few rounds of sun salutation to warm up.",
                "Link each posture to a breath, moving continuously.",
                "Hold the standing postures for several breaths before transitioning.",
                "Finish lying still for a few minutes."
            ],
            breathing: "Continuous and even. If you're holding your breath, the pace is too fast.",
            mistakes: [
                "Pushing into end range in every posture rather than finding a sustainable one.",
                "Losing the breath rhythm and turning it into a workout.",
                "Skipping the final rest, which is part of the practice."
            ],
            easier: "Take a child's pose whenever you need one; it's always available.",
            harder: "Hold each posture longer rather than adding more of them."
        ),

        "flex-yoga-3": ExerciseForm(      // Restorative Yoga Flow
            steps: [
                "Set up each posture with whatever props you have — cushions, blankets, a rolled towel.",
                "Get into the position so it requires no muscular effort to stay there.",
                "Hold for several minutes rather than seconds.",
                "Move slowly between postures with no rush."
            ],
            breathing: "Slow, quiet and nasal if comfortable. The breath is the point of the session.",
            mistakes: [
                "Treating it like stretching and pushing into range.",
                "Holding postures for too short a time to have any effect.",
                "Skipping props, which makes relaxing into the shape impossible."
            ],
            easier: "Use more support under the hips, knees and head.",
            harder: "Extend the holds; there is no intensity to add here, only time."
        ),

        "flex-yoga-4": ExerciseForm(      // Power Yoga Flow
            steps: [
                "Warm up with several rounds of sun salutation.",
                "Move through standing and balancing postures, holding each for several breaths.",
                "Keep the transitions controlled rather than dropping into each shape.",
                "Finish with floor postures and a few minutes lying still."
            ],
            breathing: "Steady and strong; expect to be working, but not gasping.",
            mistakes: [
                "Chasing the deepest version of every posture rather than a stable one.",
                "Holding the breath through the harder holds.",
                "Skipping the cool-down because the session already felt like a workout."
            ],
            easier: "Take the modified version of each posture and rest when you need to.",
            harder: "Hold the standing postures for longer before transitioning."
        ),

        "flex-yoga-5": ExerciseForm(      // Yin Yoga Flow
            steps: [
                "Take each posture to about seventy percent of your available range.",
                "Settle in and stop actively stretching — let gravity do the work.",
                "Hold for two to five minutes per posture.",
                "Come out of each shape slowly, and rest before the next."
            ],
            breathing: "Slow and quiet. Long exhales help the tissue release.",
            mistakes: [
                "Going to full range immediately, which makes long holds impossible.",
                "Fidgeting and readjusting, which resets the hold every time.",
                "Coming out of a long hold quickly, which the joints don't appreciate."
            ],
            easier: "Use props to support the shape and shorten the holds.",
            harder: "Extend the holds toward five minutes rather than deepening the position."
        ),

        // MARK: Flexibility — Foam Rolling

        "flex-roll-1": ExerciseForm(      // Foam Roll Quads
            steps: [
                "Lie face down with the roller under the front of one thigh.",
                "Support your weight on your forearms and the other leg.",
                "Roll slowly from just above the knee to the top of the thigh.",
                "Pause on any tender spot and breathe until it eases."
            ],
            breathing: "Breathe steadily. Holding your breath on a tender spot keeps the muscle tense.",
            mistakes: [
                "Rolling fast, which does little beyond feeling busy.",
                "Rolling directly over the kneecap or the hip bone.",
                "Pushing into pain rather than pressure you can breathe through."
            ],
            easier: "Take more weight through your forearms to reduce the pressure.",
            harder: "Stack the other leg on top, or pause longer on tender spots."
        ),

        "flex-roll-2": ExerciseForm(      // Foam Roll Back
            steps: [
                "Lie on your back with the roller across your upper back.",
                "Support your head with your hands and lift your hips slightly.",
                "Roll between the shoulder blades and the mid back only.",
                "Stop before you reach the lower back."
            ],
            breathing: "Breathe out as you roll over a tight area.",
            mistakes: [
                "Rolling the lower back, which has no rib support and doesn't want the pressure.",
                "Letting the head drop back unsupported.",
                "Rolling the neck, which should never take a roller."
            ],
            easier: "Keep the hips on the floor to reduce the pressure.",
            harder: "Pause and gently extend over the roller at the tightest point."
        ),

        "flex-roll-3": ExerciseForm(      // Foam Roll IT Band
            steps: [
                "Lie on your side with the roller under the outside of your thigh.",
                "Cross the top leg over in front for support and to control the pressure.",
                "Roll slowly from just above the knee to just below the hip.",
                "Pause on tender areas and breathe rather than gritting through."
            ],
            breathing: "Slow and deliberate; this one is notoriously uncomfortable.",
            mistakes: [
                "Loading full bodyweight straight away, which makes it unbearable rather than useful.",
                "Rolling over the knee joint or the hip bone.",
                "Expecting it to feel comfortable quickly — this takes weeks."
            ],
            easier: "Put more weight through the top foot to lighten the pressure.",
            harder: "Stack the legs to increase pressure, once the area tolerates it."
        ),

        "flex-roll-4": ExerciseForm(      // Foam Roll Calves
            steps: [
                "Sit with the roller under one calf and your hands on the floor behind you.",
                "Lift your hips to load the calf onto the roller.",
                "Roll slowly from just above the ankle to just below the knee.",
                "Rotate the leg in and out to reach the inner and outer calf."
            ],
            breathing: "Steady throughout; pause and breathe on tight spots.",
            mistakes: [
                "Rolling straight over without rotating, which misses most of the muscle.",
                "Rolling over the back of the knee.",
                "Going so fast the tissue never actually releases."
            ],
            easier: "Keep the hips on the floor for less pressure.",
            harder: "Cross the other leg on top to add weight."
        ),

        "flex-roll-5": ExerciseForm(      // Foam Roll Glutes
            steps: [
                "Sit on the roller with one ankle crossed over the opposite knee.",
                "Lean toward the crossed side to target that glute.",
                "Roll slowly in small ranges rather than long sweeps.",
                "Shift side to side to cover the whole muscle."
            ],
            breathing: "Breathe out as you settle onto a tender spot.",
            mistakes: [
                "Long fast sweeps that skip over the areas that need it.",
                "Rolling directly on the sit bone.",
                "Sitting square rather than leaning into the side being rolled."
            ],
            easier: "Reduce the lean and keep more weight on your hands.",
            harder: "Lean further into the crossed side, or use a ball for more focused pressure."
        ),

        // MARK: Flexibility — Hip & Shoulder Mobility

        "flex-hip-1": ExerciseForm(       // 90/90 Hip Stretch
            steps: [
                "Sit with your front leg bent at 90 degrees in front and your back leg bent at 90 degrees to the side.",
                "Sit up tall rather than collapsing back onto your hands.",
                "Lean gently forward over the front shin to deepen the stretch.",
                "Switch sides, then try rotating between the two positions without using your hands."
            ],
            breathing: "Slow, easing forward on each exhale.",
            mistakes: [
                "Rounding the back to fold further, which stretches the spine instead of the hip.",
                "Letting the front knee collapse inward from 90 degrees.",
                "Forcing the back leg into position rather than working within your range."
            ],
            easier: "Sit on a cushion to raise the hips, and keep the torso upright.",
            harder: "Rotate between sides without using your hands for support."
        ),

        "flex-hip-2": ExerciseForm(       // Pigeon Pose
            steps: [
                "From all fours, bring one knee forward behind the same-side wrist.",
                "Angle the shin toward the opposite hand as far as is comfortable.",
                "Extend the back leg straight behind you with the hip pointing down.",
                "Stay upright or fold forward, and support the hip with a cushion if it doesn't reach the floor."
            ],
            breathing: "Slow and even. Fold a little further on the exhale, never on the inhale.",
            mistakes: [
                "Letting the hips tilt so all the weight falls onto one side.",
                "Forcing the front shin parallel before the hip allows it.",
                "Skipping the support under the hip, which is why this pose hurts knees."
            ],
            easier: "Put a cushion or block under the front hip, and keep the shin angled back.",
            harder: "Bring the shin closer to parallel and fold forward over it."
        ),

        "flex-hip-3": ExerciseForm(       // Shoulder Dislocates
            steps: [
                "Hold a band or stick with a very wide grip in front of your thighs.",
                "Keeping your arms straight, raise it overhead and continue back behind you.",
                "Go only as far as you can without bending the elbows or shrugging.",
                "Return along the same path."
            ],
            breathing: "Exhale as the arms travel back, inhale as they return.",
            mistakes: [
                "Gripping too narrow, which forces the elbows to bend or the shoulders to strain.",
                "Arching the lower back to get the arms further behind.",
                "Rushing, when this movement rewards slow control."
            ],
            easier: "Widen the grip. If it's still hard, widen it further — there's no prize for a narrow grip.",
            harder: "Narrow the grip gradually over weeks, never in one session."
        ),

        "flex-hip-4": ExerciseForm(       // Couch Stretch
            steps: [
                "Kneel with your back foot up against a wall or couch, shin vertical.",
                "Bring the other foot forward into a half-kneeling position.",
                "Tuck your pelvis under and squeeze the glute of the back leg.",
                "Bring your torso upright only as far as you can hold the pelvic tuck."
            ],
            breathing: "Slow and steady; this one is intense and breath control keeps it tolerable.",
            mistakes: [
                "Arching the lower back to get upright, which fakes the range entirely.",
                "Going straight to a fully upright torso before the hip allows it.",
                "Holding so long it becomes unpleasant rather than useful."
            ],
            easier: "Keep the torso leaning forward, and put a cushion under the back knee.",
            harder: "Work the torso more upright while keeping the pelvis tucked."
        ),

        "flex-hip-5": ExerciseForm(       // Thread the Needle
            steps: [
                "Start on all fours with your hands under your shoulders.",
                "Slide one arm under your body and across, palm facing up.",
                "Lower that shoulder and the side of your head toward the floor.",
                "Hold, then unwind slowly and repeat on the other side."
            ],
            breathing: "Exhale as you thread through, breathe steadily in the hold.",
            mistakes: [
                "Letting the hips drift away from over the knees, which loses the rotation.",
                "Pushing the head into the floor rather than letting it rest.",
                "Coming out of the position quickly."
            ],
            easier: "Thread less far and keep more weight on the supporting arm.",
            harder: "Reach the top arm overhead as you thread, to add more rotation."
        ),

        // MARK: HIIT — Bodyweight HIIT

        "hiit-body-1": ExerciseForm(      // Burpee Intervals
            steps: [
                "Warm up properly — five minutes of easy movement before the first round.",
                "Set a timer for the work and rest periods so you're not watching a clock.",
                "Work at a pace you could repeat for the final round, not the first.",
                "Stand and breathe through the rest; don't fold over your knees."
            ],
            breathing: "Find a rhythm within the work period rather than holding your breath through reps.",
            mistakes: [
                "Sprinting round one, which makes the last three rounds a shuffle.",
                "Cutting the rest short because you feel fine after round two.",
                "Letting the hips sag in the plank once fatigue arrives."
            ],
            easier: "Step the feet rather than jumping, and drop the push-up.",
            harder: "Add rounds before you shorten the rest — volume first, density second."
        ),

        "hiit-body-2": ExerciseForm(      // Jump Squat Intervals
            steps: [
                "Warm up the legs with bodyweight squats before jumping.",
                "Squat to a comfortable depth and jump, landing softly with soft knees.",
                "Reset your stance briefly between reps rather than bouncing continuously.",
                "Use the rest to let your breathing settle before the next round."
            ],
            breathing: "Exhale on each jump; keep breathing through the work period.",
            mistakes: [
                "Landing stiff-legged, which is where knees and shins complain.",
                "Going straight into jumps with no warm-up.",
                "Chasing rep count as form degrades through the later rounds."
            ],
            easier: "Do bodyweight squats at pace instead of jumping.",
            harder: "Add rounds, or pause briefly at the bottom before each jump."
        ),

        "hiit-body-3": ExerciseForm(      // Mountain Climber Intervals
            steps: [
                "Set up in a solid plank with your hands under your shoulders.",
                "Drive the knees alternately, keeping the hips level with the shoulders.",
                "Hold the pace you can maintain with still hips for the whole work period.",
                "Come off the hands entirely during the rest."
            ],
            breathing: "Steady and rhythmic; this is where people hold their breath and blow up.",
            mistakes: [
                "Hips rising into a pike, which makes the round easier than it should be.",
                "Bouncing the hips with each knee drive.",
                "Starting at a sprint and dropping to a crawl within fifteen seconds."
            ],
            easier: "Slow the pace and prioritise a still plank over speed.",
            harder: "Add rounds, or drive the knee toward the opposite elbow."
        ),

        "hiit-body-4": ExerciseForm(      // High Knees Intervals
            steps: [
                "Stand tall and run on the spot, driving the knees to hip height.",
                "Stay on the balls of your feet and keep the contacts light and quick.",
                "Pump the arms in time with the legs.",
                "Walk or march gently through the rest rather than standing still."
            ],
            breathing: "Quick and rhythmic; match it to your cadence.",
            mistakes: [
                "Leaning back to get the knees higher.",
                "Landing heavily and flat-footed.",
                "Dropping knee height to keep the speed up as you tire."
            ],
            easier: "March at pace with lower knees.",
            harder: "Increase the cadence, or add rounds."
        ),

        "hiit-body-5": ExerciseForm(      // Plank Jack Intervals
            steps: [
                "Start in a plank with your body in a straight line.",
                "Jump the feet wide and back together, keeping the hips level.",
                "Land softly on the balls of your feet.",
                "Come out of the plank fully during the rest."
            ],
            breathing: "Steady and rhythmic; don't hold your breath through the jumps.",
            mistakes: [
                "Hips piking up with each jump.",
                "Landing heavily, which jars the shoulders.",
                "Holding the plank through the rest, which sabotages the next round."
            ],
            easier: "Step the feet out one at a time instead of jumping.",
            harder: "Add rounds, or perform them from a forearm plank."
        ),

        // MARK: HIIT — Equipment HIIT

        "hiit-equip-1": ExerciseForm(     // Kettlebell Swing Intervals
            steps: [
                "Warm up the hinge with light swings before the first working round.",
                "Swing with a hard hip snap; the arms guide the bell, they don't lift it.",
                "Set the bell down safely at the end of each round rather than dropping it.",
                "Stand tall and breathe through the rest."
            ],
            breathing: "Exhale sharply on each hip snap; recover fully in the rest.",
            mistakes: [
                "Squatting the bell up rather than hinging, which worsens as you tire.",
                "Using a bell heavy enough that form breaks by round three.",
                "Holding the breath through a whole round."
            ],
            easier: "Use a lighter bell and shorter work periods.",
            harder: "Add rounds, or move up one bell size once the hinge holds for every round."
        ),

        "hiit-equip-2": ExerciseForm(     // Battle Rope Intervals
            steps: [
                "Stand in a quarter squat with your feet shoulder width and chest up.",
                "Drive waves from the shoulders, keeping them reaching the anchor.",
                "Hold the athletic stance for the whole work period.",
                "Drop the ropes and breathe during the rest."
            ],
            breathing: "Hard and rhythmic; the rest is where you get it back.",
            mistakes: [
                "Standing upright, which turns it into an arms-only exercise.",
                "Waves dying out halfway down the rope as the round goes on.",
                "Gripping so hard the forearms fail before the conditioning does."
            ],
            easier: "Shorter work periods with longer rest.",
            harder: "Alternate wave patterns within a round, or extend the work period."
        ),

        "hiit-equip-3": ExerciseForm(     // Sled Sprint Intervals
            steps: [
                "Load the sled light enough that you can actually sprint rather than grind.",
                "Set your hands low on the uprights and lean in with a straight line from head to heels.",
                "Drive with short powerful steps, keeping the sled moving throughout.",
                "Walk back slowly as your rest."
            ],
            breathing: "All out on the push; use the walk back to bring it down.",
            mistakes: [
                "Loading it so heavy the sprint becomes a slow push, which trains something else entirely.",
                "Standing too upright and shoving with the arms.",
                "Cutting the walk-back rest short."
            ],
            easier: "Reduce the load and shorten the distance.",
            harder: "Add distance before you add weight."
        ),

        "hiit-equip-4": ExerciseForm(     // Box Jump Intervals
            steps: [
                "Pick a box height you can land on with your feet flat and hips above knees.",
                "Swing the arms and jump, landing softly in a quarter squat.",
                "Stand fully upright on the box, then step down — always step down, never jump down.",
                "Reset your stance before the next rep."
            ],
            breathing: "Exhale on the jump; keep breathing between reps.",
            mistakes: [
                "Jumping down from the box, which is how achilles tendons get injured.",
                "Choosing a box so high you land in a deep crumple rather than a controlled squat.",
                "Rushing reps as fatigue arrives, which is when shins meet the box."
            ],
            easier: "Use a lower box, or step up rather than jumping.",
            harder: "Raise the box slightly, or add rounds — never both in one session."
        ),

        "hiit-equip-5": ExerciseForm(     // Med Ball Slam Intervals
            steps: [
                "Stand with feet shoulder width, holding the ball at chest height.",
                "Reach the ball overhead, rising onto your toes.",
                "Slam it down hard in front of you, hinging at the hips as you follow through.",
                "Catch or pick it up and reset for the next rep."
            ],
            breathing: "Exhale sharply on each slam.",
            mistakes: [
                "Throwing with the arms only rather than driving through the whole body.",
                "Rounding the back to pick the ball up between reps.",
                "Using a bouncy ball, which sends it back into your face."
            ],
            easier: "Use a lighter ball and a shorter work period.",
            harder: "Use a heavier ball, or extend the work period."
        ),

        // MARK: HIIT — Tabata

        "hiit-tabata-1": ExerciseForm(    // Tabata Squats
            steps: [
                "Tabata is a fixed protocol: 20 seconds of work, 10 seconds of rest, eight rounds, four minutes total.",
                "Warm up for at least five minutes first — four minutes is short but genuinely hard.",
                "Squat at a pace you can hold for all eight rounds, counting your reps in round one.",
                "Aim to match that round-one count every round; the score is your lowest round."
            ],
            breathing: "Keep breathing through the work; ten seconds is not long enough to recover if you don't.",
            mistakes: [
                "Treating round one as a max effort, which is the classic Tabata error.",
                "Cutting depth as the rounds go on rather than slowing the pace.",
                "Extending the rest past ten seconds, at which point it isn't Tabata."
            ],
            easier: "Squat to a box, or use a slower target rep count.",
            harder: "Raise the target count you hold across all eight rounds."
        ),

        "hiit-tabata-2": ExerciseForm(    // Tabata Push-Ups
            steps: [
                "Twenty seconds of work, ten of rest, eight rounds.",
                "Set a target rep count in round one you believe you can repeat eight times.",
                "Hold full range on every rep; a half push-up doesn't count.",
                "Drop to your knees mid-protocol rather than shortening the range."
            ],
            breathing: "Breathe on every rep; holding your breath makes round five impossible.",
            mistakes: [
                "Going to failure in round one, leaving nothing for the remaining seven.",
                "Shortening the range instead of reducing the count as you tire.",
                "Letting the hips sag once the shoulders fatigue."
            ],
            easier: "Do them from your knees or with hands elevated from the start.",
            harder: "Elevate the feet, or hold a higher rep count across all rounds."
        ),

        "hiit-tabata-3": ExerciseForm(    // Tabata Bike
            steps: [
                "Set the bike up and warm up for five minutes before starting.",
                "Set a resistance you can turn hard for twenty seconds, not one you grind.",
                "Go hard from the first second of each work period.",
                "Keep the legs turning slowly through the ten-second rest."
            ],
            breathing: "As hard as you need; the rest is far too short to fully recover, which is the point.",
            mistakes: [
                "Resistance so low the legs just spin without loading.",
                "Stopping dead in the rest, which makes each restart worse.",
                "Pacing it like a longer interval session."
            ],
            easier: "Reduce the resistance and treat it as a cadence effort.",
            harder: "Raise the resistance slightly, holding the same cadence across all rounds."
        ),

        "hiit-tabata-4": ExerciseForm(    // Tabata Burpees
            steps: [
                "Twenty seconds of work, ten of rest, eight rounds.",
                "Pick a rep target for round one that you can genuinely repeat.",
                "Keep the chest touching the floor and the jump at the top on every rep.",
                "Stand tall in the rest rather than folding over your knees."
            ],
            breathing: "Steady rhythm within each round; use every second of the rest.",
            mistakes: [
                "Round one at maximum, which turns rounds five through eight into a crawl.",
                "Dropping the chest-to-floor or the jump as the rounds go on.",
                "Bending over in the rest, which restricts breathing when you need it most."
            ],
            easier: "Step the feet and drop the push-up and the jump.",
            harder: "Raise the rep target you can hold for all eight rounds."
        ),

        "hiit-tabata-5": ExerciseForm(    // Tabata Row
            steps: [
                "Set the damper around 4 or 5 and warm up with several easy minutes.",
                "Note your metres or calories in round one — that's the number to repeat.",
                "Hold the drive sequence even at high rate: legs, torso, arms.",
                "Paddle very lightly through the ten-second rest rather than stopping."
            ],
            breathing: "Exhale on the drive; ten seconds isn't recovery, just a chance to reset.",
            mistakes: [
                "Winding the stroke rate up while power falls, so the split worsens.",
                "Opening the back early once tired, which is where lower backs complain.",
                "Going all out in round one and losing thirty percent by round four."
            ],
            easier: "Row for a lower target and prioritise holding the sequence.",
            harder: "Hold a higher target that stays consistent across all eight rounds."
        ),

        // MARK: HIIT — EMOM

        "hiit-emom-1": ExerciseForm(      // EMOM Kettlebell Swings
            steps: [
                "EMOM means every minute on the minute: start a set at the top of each minute.",
                "Pick a rep count that leaves you fifteen to twenty seconds of rest each minute.",
                "Complete the reps, then rest until the next minute begins.",
                "If a minute leaves you no rest, the count is too high — stop or reduce it."
            ],
            breathing: "Recover through the remainder of each minute; that gap is the whole design.",
            mistakes: [
                "Choosing a rep count that eats the whole minute, which removes the rest entirely.",
                "Letting the hinge turn into a squat as the minutes accumulate.",
                "Pushing on through minutes where form has already gone."
            ],
            easier: "Lower the rep count, or use a lighter bell.",
            harder: "Add reps per minute, or add minutes to the total."
        ),

        "hiit-emom-2": ExerciseForm(      // EMOM Burpees
            steps: [
                "Start a set of burpees at the top of every minute.",
                "Choose a count that leaves you at least fifteen seconds of rest.",
                "Keep the chest to the floor and the jump on every rep.",
                "Use the remainder of each minute standing and breathing."
            ],
            breathing: "Settle your breathing in the gap; the gap shrinks fast if you don't.",
            mistakes: [
                "Setting a count so high the rest disappears by minute four.",
                "Starting the next set early because you feel fine in minute two.",
                "Letting reps get shallow rather than reducing the count."
            ],
            easier: "Reduce the reps per minute, or step rather than jump.",
            harder: "Add a rep per minute, or extend the total number of minutes."
        ),

        "hiit-emom-3": ExerciseForm(      // EMOM Thrusters
            steps: [
                "Choose a weight you could do roughly double the target reps with when fresh.",
                "Start a set at the top of each minute.",
                "Hold the front rack with elbows high and drive out of the squat into the press.",
                "Rest for the remainder of the minute with the weights down."
            ],
            breathing: "Breathe at the top of each rep, and recover through the gap.",
            mistakes: [
                "Choosing a weight based on a fresh single set rather than repeated ones.",
                "Letting the elbows drop in the squat, which dumps the weight forward.",
                "Holding the dumbbells at the shoulders through the rest instead of setting them down."
            ],
            easier: "Reduce the weight or the reps per minute.",
            harder: "Add a rep per minute, or add minutes — not weight, first."
        ),

        "hiit-emom-4": ExerciseForm(      // EMOM Row Calories
            steps: [
                "Set the damper around 4 or 5 and warm up first.",
                "Pull a target calorie count at the top of each minute.",
                "Hold the drive sequence; calories come from power, not stroke rate.",
                "Rest on the machine for the remainder of each minute."
            ],
            breathing: "Exhale on the drive and use the gap to bring your breathing back down.",
            mistakes: [
                "Chasing calories with a high rate and low power, which is slower not faster.",
                "Setting a target that leaves no rest by minute three.",
                "Letting the sequence collapse into an arms-first pull as you tire."
            ],
            easier: "Lower the calorie target per minute.",
            harder: "Raise the target by one calorie at a time across the whole session."
        ),

        "hiit-emom-5": ExerciseForm(      // EMOM Air Squats
            steps: [
                "Start a set of squats at the top of each minute.",
                "Hit full depth on every rep — this is the first thing to go.",
                "Choose a count that leaves you real rest within each minute.",
                "Stand and breathe for the remainder."
            ],
            breathing: "Breathe on every rep, and recover through the gap.",
            mistakes: [
                "Cutting depth as the minutes stack up rather than reducing the count.",
                "Setting a count that removes the rest entirely.",
                "Rushing reps so the knees cave inward under fatigue."
            ],
            easier: "Squat to a box to guarantee consistent depth, and lower the count.",
            harder: "Add reps per minute, or extend the total minutes."
        ),

        // MARK: HIIT — Circuit HIIT

        "hiit-circuit-1": ExerciseForm(   // Full Body Circuit
            steps: [
                "Pick four to six exercises covering push, pull, legs and core.",
                "Set up everything you need before starting so transitions are quick.",
                "Work through each station for the set time, then move on with minimal rest.",
                "Rest fully at the end of a full round before starting the next."
            ],
            breathing: "Steady throughout; the transitions are where breathing usually goes ragged.",
            mistakes: [
                "Stacking two exercises for the same muscle back to back, which limits both.",
                "Attacking the first station and fading across the rest of the round.",
                "Resting between stations rather than at the end of the round."
            ],
            easier: "Fewer stations, shorter work periods, longer rest between rounds.",
            harder: "Add a station, or extend the work period at each."
        ),

        "hiit-circuit-2": ExerciseForm(   // Upper Body HIIT Circuit
            steps: [
                "Choose alternating pushing and pulling movements so no one muscle stalls the circuit.",
                "Set the dumbbells out in station order before you start.",
                "Work each station for the set time, moving straight on.",
                "Rest fully between rounds."
            ],
            breathing: "Keep it steady; upper body circuits are where people hold their breath under strain.",
            mistakes: [
                "Two pressing movements back to back, so the triceps end the round early.",
                "Choosing weights that only work for the first round.",
                "Letting the range shorten rather than slowing down."
            ],
            easier: "Lighter dumbbells and shorter work periods.",
            harder: "Extend the work period or add a round — weight last."
        ),

        "hiit-circuit-3": ExerciseForm(   // Lower Body HIIT Circuit
            steps: [
                "Alternate squat-pattern and hinge-pattern movements across the stations.",
                "Work each station for the set time with minimal transition.",
                "Keep depth and knee tracking consistent as fatigue builds.",
                "Rest fully between rounds — legs need more than upper body circuits do."
            ],
            breathing: "Steady and deep; leg circuits raise your heart rate faster than expected.",
            mistakes: [
                "Stacking several squat-pattern stations in a row.",
                "Letting the knees cave inward once the legs are tired.",
                "Cutting the between-round rest, which legs recover from more slowly."
            ],
            easier: "Fewer stations and longer rest between rounds.",
            harder: "Add a station, or add a round."
        ),

        "hiit-circuit-4": ExerciseForm(   // Core HIIT Circuit
            steps: [
                "Pick stations that cover flexion, rotation and anti-movement holds.",
                "Work each for the set time, moving straight to the next.",
                "Keep the lower back pressed down or the spine neutral, depending on the movement.",
                "Rest fully between rounds."
            ],
            breathing: "Breathe throughout. Core work is where breath-holding is most common and least useful.",
            mistakes: [
                "Choosing four flexion exercises and calling it a core circuit.",
                "Letting the lower back arch on the floor-based stations once tired.",
                "Rushing reps so the movement becomes momentum."
            ],
            easier: "Shorter work periods and a longer rest between rounds.",
            harder: "Extend the work periods, or add an anti-rotation station."
        ),

        "hiit-circuit-5": ExerciseForm(   // Cardio Strength Circuit
            steps: [
                "Alternate a cardio station with a strength station around the circuit.",
                "Set both up in advance so you're not adjusting equipment mid-round.",
                "Hold a pace on the cardio stations that leaves you able to lift on the next.",
                "Rest fully at the end of each round."
            ],
            breathing: "The cardio stations set the rhythm; use them to settle rather than redline.",
            mistakes: [
                "Redlining on the cardio station so the strength station falls apart.",
                "Choosing loads that only work when fresh.",
                "Skipping the between-round rest because the cardio felt easy."
            ],
            easier: "Shorter stations, fewer rounds, and lighter loads on the strength stations.",
            harder: "Add a round, or extend the cardio stations while holding the same loads."
        ),

        // MARK: Recovery — Breathwork

        "rec-breath-1": ExerciseForm(     // Box Breathing
            steps: [
                "Sit upright somewhere comfortable, or lie down.",
                "Breathe in through the nose for a count of four.",
                "Hold for four, breathe out for four, then hold empty for four.",
                "Repeat that square for the length of the session."
            ],
            breathing: "The pattern is the exercise: four in, four hold, four out, four hold.",
            mistakes: [
                "Picking a count so long it becomes a struggle — four is a starting point, not a target to beat.",
                "Forcing a full lungful on the inhale, which makes the hold uncomfortable.",
                "Tensing the shoulders and neck on each hold."
            ],
            easier: "Drop to a count of three, or remove the empty hold and use three sides instead of four.",
            harder: "Extend the count to five or six once four feels genuinely easy."
        ),

        "rec-breath-2": ExerciseForm(     // 4-7-8 Breathing
            steps: [
                "Sit or lie down and rest the tip of your tongue behind your top front teeth.",
                "Breathe in quietly through the nose for a count of four.",
                "Hold for a count of seven.",
                "Breathe out through the mouth for a count of eight, then repeat."
            ],
            breathing: "The long exhale is the active ingredient — it should be roughly twice the inhale.",
            mistakes: [
                "Speeding up the count so the exhale is no longer the longest phase.",
                "Taking a huge inhale, which makes the seven-count hold a struggle.",
                "Doing many rounds on the first attempt; four is plenty to begin with."
            ],
            easier: "Halve the counts to 2-3.5-4, keeping the same ratio.",
            harder: "Extend the counts proportionally rather than adding rounds."
        ),

        "rec-breath-3": ExerciseForm(     // Diaphragmatic Breathing
            steps: [
                "Lie on your back with your knees bent, one hand on your chest and one on your belly.",
                "Breathe in slowly through the nose and aim to move the lower hand, not the upper one.",
                "Let the belly rise and the ribs widen sideways.",
                "Breathe out slowly and let it fall, without forcing the air out."
            ],
            breathing: "Slow and nasal. The belly hand should move noticeably more than the chest hand.",
            mistakes: [
                "Lifting the chest and shoulders on every inhale, which is the habit this exercise exists to change.",
                "Pushing the belly out with the abdominal muscles instead of letting the breath fill it.",
                "Forcing the exhale rather than letting it release."
            ],
            easier: "Practise lying down with your knees supported, where the pattern is easiest to feel.",
            harder: "Do it seated, then standing, then during light activity."
        ),

        "rec-breath-4": ExerciseForm(     // Guided Breath Reset
            steps: [
                "Stop whatever you're doing and sit or stand still.",
                "Take one slow breath in through the nose, and a longer breath out.",
                "Repeat for six to ten breaths, keeping the exhale longer than the inhale.",
                "Return to what you were doing."
            ],
            breathing: "Longer out than in. That ratio is what shifts the nervous system, not the number of breaths.",
            mistakes: [
                "Breathing fast and deep, which does the opposite of what's intended.",
                "Treating it as something that needs a special time and place.",
                "Skipping it on the days that would benefit most from it."
            ],
            easier: "Three breaths is enough to be worth doing.",
            harder: "Extend the exhale further, or use it several times across a day."
        ),

        "rec-breath-5": ExerciseForm(     // Cold Exposure Breathing
            steps: [
                "Sit or lie down somewhere safe before you begin — never stand.",
                "Take 20 to 30 deeper-than-normal breaths, in through the nose and out through the mouth.",
                "After the last exhale, hold empty for as long as is comfortable, without straining.",
                "Take a deep breath in, hold briefly, then return to normal breathing before the next round."
            ],
            breathing: "Deeper than usual but never forced. Light-headedness means stop, not push on.",
            mistakes: [
                "Doing this in or near water. This style of breathing can cause blackout, and blackout in water drowns people — never in a bath, pool, shower or open water.",
                "Doing it standing, driving, or anywhere a faint would cause injury.",
                "Treating tingling and dizziness as a goal rather than a signal to stop."
            ],
            easier: "Fewer breaths per round and a much shorter hold, or skip the hold entirely.",
            harder: "Add rounds gradually. Never extend the hold past comfortable."
        ),

        "rec-sleep-5": ExerciseForm(      // Bedtime Breathing
            steps: [
                "Lie in bed on your back or your side, whichever you sleep in.",
                "Breathe in through the nose for a comfortable count.",
                "Breathe out for roughly twice that count.",
                "Keep going without counting rounds — falling asleep partway through is the intended outcome."
            ],
            breathing: "Exhale about twice as long as the inhale. Nothing else about it matters much.",
            mistakes: [
                "Counting rounds and checking progress, which keeps you alert.",
                "Making the inhale big, which is stimulating rather than settling.",
                "Doing it sitting up on your phone rather than lying down ready to sleep."
            ],
            easier: "Use any comfortable ratio where the exhale is simply longer than the inhale.",
            harder: "There is no harder version — this one is meant to end in sleep."
        ),

        // MARK: Recovery — Restorative Yoga

        "rec-restore-1": ExerciseForm(    // Legs Up The Wall
            steps: [
                "Sit side-on with one hip against the wall.",
                "Swing your legs up the wall as you lie back, shuffling your hips close.",
                "Let your arms rest wide and your legs stay relaxed, not locked straight.",
                "Stay for several minutes, then roll to your side before getting up."
            ],
            breathing: "Slow and nasal. Long exhales make the position do more.",
            mistakes: [
                "Locking the knees hard, which turns rest into a hamstring stretch.",
                "Sitting so far from the wall the lower back arches off the floor.",
                "Standing straight up at the end, which can leave you light-headed."
            ],
            easier: "Move your hips further from the wall, or put a cushion under them.",
            harder: "Stay longer. There is no intensity to add here, only time."
        ),

        "rec-restore-2": ExerciseForm(    // Child's Pose
            steps: [
                "Kneel and bring your big toes together, letting your knees fall wide.",
                "Sit your hips back toward your heels.",
                "Walk your hands forward and rest your forehead on the floor.",
                "Let your shoulders soften and stay for several breaths or minutes."
            ],
            breathing: "Breathe into your back ribs — you'll feel them widen against the position.",
            mistakes: [
                "Forcing the hips onto the heels when the range isn't there.",
                "Holding tension in the shoulders rather than letting the arms rest.",
                "Treating it as a stretch to push into rather than a position to settle in."
            ],
            easier: "Put a cushion between your hips and heels, and another under your forehead.",
            harder: "Widen the knees further, or walk the hands to one side for a side-body stretch."
        ),

        "rec-restore-3": ExerciseForm(    // Supported Bridge
            steps: [
                "Lie on your back with knees bent and feet flat, hip width apart.",
                "Lift your hips and slide a block or firm cushion under your sacrum — the flat bone, not your lower back.",
                "Lower your weight onto the support so no muscular effort is needed.",
                "Rest your arms wide and stay for several minutes."
            ],
            breathing: "Slow and steady. The chest is open here, so breathing should feel easy.",
            mistakes: [
                "Placing the block under the lower back rather than the sacrum, which compresses the spine.",
                "Using a block on its tallest setting straight away.",
                "Holding the hips up with the glutes instead of resting on the support."
            ],
            easier: "Use a folded blanket or the block on its lowest height.",
            harder: "Raise the block height gradually, or extend one leg at a time."
        ),

        "rec-restore-4": ExerciseForm(    // Reclined Twist
            steps: [
                "Lie on your back and draw both knees toward your chest.",
                "Let both knees fall to one side, keeping both shoulders on the floor.",
                "Extend the opposite arm out wide and turn your head away from the knees.",
                "Stay for several breaths, then switch sides."
            ],
            breathing: "Slow. Let the knees settle a little lower on each exhale rather than pushing them down.",
            mistakes: [
                "Letting the opposite shoulder lift off the floor, which loses the twist entirely.",
                "Pushing the knees down with a hand rather than letting gravity work.",
                "Coming out of the twist quickly."
            ],
            easier: "Put a cushion under the knees so they don't have to reach the floor.",
            harder: "Extend the top leg, or stay considerably longer on each side."
        ),

        "rec-restore-5": ExerciseForm(    // Savasana
            steps: [
                "Lie flat on your back with your legs a comfortable distance apart.",
                "Let your feet fall open and rest your arms slightly away from your sides, palms up.",
                "Close your eyes and let your whole bodyweight settle into the floor.",
                "Stay still for at least five minutes."
            ],
            breathing: "Let it find its own rhythm. This is the one position where you don't manage the breath.",
            mistakes: [
                "Skipping it because nothing appears to be happening — this is the pose that consolidates the rest.",
                "Fidgeting and readjusting, which restarts the settling every time.",
                "Cutting it to under a couple of minutes, which is too short to do anything."
            ],
            easier: "Put a cushion under your knees to take pressure off the lower back.",
            harder: "Stay longer, and resist the urge to move."
        ),

    ]
}

// MARK: - Template convenience

extension ExerciseTemplate {
    /// Form guidance, when it has been written for this exercise.
    var form: ExerciseForm? { ExerciseFormLibrary.form(for: id) }
    var hasForm: Bool { form != nil }
}

extension ExerciseLibrary {
    /// Name-and-category index, so a logged entry can find the template it came
    /// from. Built once rather than scanning 250 templates on every render.
    private static let byNameIndex: [String: ExerciseTemplate] = {
        Dictionary(all.map { ("\($0.category.rawValue)|\($0.name)", $0) }, uniquingKeysWith: { first, _ in first })
    }()

    static func template(named name: String, category: WorkoutCategory) -> ExerciseTemplate? {
        byNameIndex["\(category.rawValue)|\(name)"]
    }
}

extension WorkoutEntry {
    /// Form guidance for a logged entry, resolved back through the library.
    /// Custom exercises have no template and so no guidance, which is expected.
    var form: ExerciseForm? {
        ExerciseLibrary.template(named: name, category: category)?.form
    }
}
