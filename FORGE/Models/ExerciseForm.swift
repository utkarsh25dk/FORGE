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
