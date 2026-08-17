import Foundation

struct ExerciseTemplate: Identifiable, Hashable {
    let id: String
    let name: String
    let category: WorkoutCategory
    let subgroup: String
    let kind: ExerciseKind
    let equipment: String
    var sets: Int? = nil
    var reps: Int? = nil
    var durationMin: Int? = nil
    var inclinePercent: Int? = nil
    var intensity: Int? = nil
    var holdSec: Int? = nil
    var distanceMiles: Double? = nil
    var rounds: Int? = nil
    var workSec: Int? = nil
    var restSec: Int? = nil
    let tip: String
}

enum ExerciseLibrary {

    // MARK: factories

    private static func strength(_ id: String, _ name: String, _ cat: WorkoutCategory, _ sub: String, _ equip: String, _ sets: Int, _ reps: Int, _ tip: String) -> ExerciseTemplate {
        ExerciseTemplate(id: id, name: name, category: cat, subgroup: sub, kind: .strength, equipment: equip, sets: sets, reps: reps, tip: tip)
    }
    private static func cardio(_ id: String, _ name: String, _ cat: WorkoutCategory, _ sub: String, _ equip: String, _ dur: Int, _ incline: Int, _ intensity: Int, _ tip: String) -> ExerciseTemplate {
        ExerciseTemplate(id: id, name: name, category: cat, subgroup: sub, kind: .cardio, equipment: equip, durationMin: dur, inclinePercent: incline, intensity: intensity, tip: tip)
    }
    private static func hold(_ id: String, _ name: String, _ cat: WorkoutCategory, _ sub: String, _ equip: String, _ sets: Int, _ sec: Int, _ tip: String) -> ExerciseTemplate {
        ExerciseTemplate(id: id, name: name, category: cat, subgroup: sub, kind: .hold, equipment: equip, sets: sets, holdSec: sec, tip: tip)
    }
    private static func distance(_ id: String, _ name: String, _ cat: WorkoutCategory, _ sub: String, _ equip: String, _ miles: Double, _ dur: Int, _ tip: String) -> ExerciseTemplate {
        ExerciseTemplate(id: id, name: name, category: cat, subgroup: sub, kind: .distance, equipment: equip, durationMin: dur, distanceMiles: miles, tip: tip)
    }
    private static func interval(_ id: String, _ name: String, _ cat: WorkoutCategory, _ sub: String, _ equip: String, _ rounds: Int, _ work: Int, _ rest: Int, _ intensity: Int, _ tip: String) -> ExerciseTemplate {
        ExerciseTemplate(id: id, name: name, category: cat, subgroup: sub, kind: .interval, equipment: equip, intensity: intensity, rounds: rounds, workSec: work, restSec: rest, tip: tip)
    }
    private static func session(_ id: String, _ name: String, _ cat: WorkoutCategory, _ sub: String, _ equip: String, _ dur: Int, _ intensity: Int, _ tip: String) -> ExerciseTemplate {
        ExerciseTemplate(id: id, name: name, category: cat, subgroup: sub, kind: .session, equipment: equip, durationMin: dur, intensity: intensity, tip: tip)
    }

    // MARK: - Upper Body

    private static let upperBody: [ExerciseTemplate] = [
        strength("ub-chest-1", "Barbell Bench Press", .upperBody, "Chest", "Barbell", 4, 8, "Add 5 lbs once all sets land at the top of your rep range."),
        strength("ub-chest-2", "Incline Dumbbell Press", .upperBody, "Chest", "Dumbbell", 3, 10, "Increase weight in small steps — dumbbells jump fast in total load."),
        strength("ub-chest-3", "Push-Ups", .upperBody, "Chest", "Bodyweight", 3, 15, "Elevate your feet to add difficulty once 3x15 feels easy."),
        strength("ub-chest-4", "Cable Chest Fly", .upperBody, "Chest", "Cable", 3, 12, "Focus on a slow stretch at the bottom before adding load."),
        strength("ub-chest-5", "Dumbbell Pullover", .upperBody, "Chest", "Dumbbell", 3, 10, "Keep a slight elbow bend and control the descent."),

        strength("ub-back-1", "Pull-Ups", .upperBody, "Back", "Bodyweight", 4, 6, "Add a weighted vest once bodyweight sets exceed 4x10."),
        strength("ub-back-2", "Bent-Over Barbell Row", .upperBody, "Back", "Barbell", 4, 8, "Keep your torso angle consistent as weight climbs."),
        strength("ub-back-3", "Lat Pulldown", .upperBody, "Back", "Cable", 3, 12, "Pause at full stretch for a beat before pulling."),
        strength("ub-back-4", "Seated Cable Row", .upperBody, "Back", "Cable", 3, 12, "Drive elbows back rather than shrugging to add load."),
        strength("ub-back-5", "Single-Arm Dumbbell Row", .upperBody, "Back", "Dumbbell", 3, 10, "Match reps on both sides before increasing weight."),

        strength("ub-shoulders-1", "Overhead Press", .upperBody, "Shoulders", "Barbell", 4, 6, "A slow, controlled press builds the base for heavier loads."),
        strength("ub-shoulders-2", "Lateral Raise", .upperBody, "Shoulders", "Dumbbell", 3, 15, "Light weight, strict form — this one punishes momentum."),
        strength("ub-shoulders-3", "Arnold Press", .upperBody, "Shoulders", "Dumbbell", 3, 10, "Rotate through the full range for complete delt coverage."),
        strength("ub-shoulders-4", "Rear Delt Fly", .upperBody, "Shoulders", "Dumbbell", 3, 15, "Squeeze shoulder blades together at the top of each rep."),
        strength("ub-shoulders-5", "Front Raise", .upperBody, "Shoulders", "Dumbbell", 3, 12, "Stop at shoulder height — higher just recruits traps."),

        strength("ub-biceps-1", "Barbell Curl", .upperBody, "Biceps", "Barbell", 3, 10, "Add weight only once your elbows stop drifting forward."),
        strength("ub-biceps-2", "Dumbbell Hammer Curl", .upperBody, "Biceps", "Dumbbell", 3, 12, "Great forearm carryover — bump weight every couple weeks."),
        strength("ub-biceps-3", "Incline Dumbbell Curl", .upperBody, "Biceps", "Dumbbell", 3, 10, "The incline removes momentum, so progress will feel slower."),
        strength("ub-biceps-4", "Cable Curl", .upperBody, "Biceps", "Cable", 3, 12, "Constant tension makes this a great finisher — chase reps first."),
        strength("ub-biceps-5", "Concentration Curl", .upperBody, "Biceps", "Dumbbell", 3, 12, "Slow the eccentric down to two full seconds."),

        strength("ub-triceps-1", "Close-Grip Bench Press", .upperBody, "Triceps", "Barbell", 4, 8, "Keep elbows tucked; this doubles as a chest builder too."),
        strength("ub-triceps-2", "Tricep Rope Pushdown", .upperBody, "Triceps", "Cable", 3, 12, "Flare the rope at lockout for a full contraction."),
        strength("ub-triceps-3", "Skull Crushers", .upperBody, "Triceps", "Barbell", 3, 10, "Keep elbows fixed in place — only the forearm moves."),
        strength("ub-triceps-4", "Overhead Tricep Extension", .upperBody, "Triceps", "Dumbbell", 3, 12, "Full stretch behind the head builds long-head size."),
        strength("ub-triceps-5", "Dips", .upperBody, "Triceps", "Bodyweight", 3, 10, "Lean forward slightly to spare the shoulders as reps climb."),
    ]

    // MARK: - Lower Body

    private static let lowerBody: [ExerciseTemplate] = [
        strength("lb-quads-1", "Barbell Back Squat", .lowerBody, "Quads", "Barbell", 4, 6, "Depth first, then load — never trade one for the other."),
        strength("lb-quads-2", "Leg Press", .lowerBody, "Quads", "Machine", 4, 10, "Safe to push heavier here since stability is fixed."),
        strength("lb-quads-3", "Walking Lunges", .lowerBody, "Quads", "Dumbbell", 3, 12, "Add reps per leg before reaching for heavier dumbbells."),
        strength("lb-quads-4", "Leg Extension", .lowerBody, "Quads", "Machine", 3, 15, "Pause at the top for a one-count squeeze."),
        strength("lb-quads-5", "Bulgarian Split Squat", .lowerBody, "Quads", "Dumbbell", 3, 10, "Balance improves fast — load will follow soon after."),

        strength("lb-hams-1", "Romanian Deadlift", .lowerBody, "Hamstrings", "Barbell", 4, 8, "Push hips back, not down — you'll feel the stretch immediately."),
        strength("lb-hams-2", "Leg Curl", .lowerBody, "Hamstrings", "Machine", 3, 12, "Slow the release; the eccentric is where hamstrings grow."),
        strength("lb-hams-3", "Good Mornings", .lowerBody, "Hamstrings", "Barbell", 3, 10, "Start light — this move rewards patience over ego."),
        strength("lb-hams-4", "Kettlebell Swing", .lowerBody, "Hamstrings", "Kettlebell", 4, 15, "Power comes from the hip snap, not the arms."),
        strength("lb-hams-5", "Single-Leg RDL", .lowerBody, "Hamstrings", "Dumbbell", 3, 10, "Master bodyweight balance before adding dumbbells."),

        strength("lb-glutes-1", "Hip Thrust", .lowerBody, "Glutes", "Barbell", 4, 10, "Drive through the heels and pause hard at lockout."),
        strength("lb-glutes-2", "Glute Bridge", .lowerBody, "Glutes", "Bodyweight", 3, 15, "Add a band above the knees once bodyweight feels easy."),
        strength("lb-glutes-3", "Cable Kickback", .lowerBody, "Glutes", "Cable", 3, 15, "Small range, big squeeze — resist swinging the leg."),
        strength("lb-glutes-4", "Sumo Deadlift", .lowerBody, "Glutes", "Barbell", 4, 6, "Wide stance, chest tall — sit into the pull."),
        strength("lb-glutes-5", "Step-Ups", .lowerBody, "Glutes", "Dumbbell", 3, 10, "A taller box shifts more work to the glutes."),

        strength("lb-calves-1", "Standing Calf Raise", .lowerBody, "Calves", "Machine", 4, 15, "Full stretch at the bottom, hard pause at the top."),
        strength("lb-calves-2", "Seated Calf Raise", .lowerBody, "Calves", "Machine", 4, 15, "This angle hits the soleus — don't skip it for standing raises alone."),
        strength("lb-calves-3", "Donkey Calf Raise", .lowerBody, "Calves", "Machine", 3, 15, "The forward-bent angle deepens the stretch considerably."),
        strength("lb-calves-4", "Single-Leg Calf Raise", .lowerBody, "Calves", "Bodyweight", 3, 12, "Match reps per side before adding a dumbbell."),
        strength("lb-calves-5", "Jump Rope Calf Pumps", .lowerBody, "Calves", "Jump Rope", 4, 30, "Stay light on your feet — quantity builds calf endurance."),

        strength("lb-adduct-1", "Cable Hip Adduction", .lowerBody, "Adductors & Abductors", "Cable", 3, 15, "Control the return — don't let the cable snap you back."),
        strength("lb-adduct-2", "Cable Hip Abduction", .lowerBody, "Adductors & Abductors", "Cable", 3, 15, "Keep the torso still; isolate the hip only."),
        strength("lb-adduct-3", "Side-Lying Leg Raise", .lowerBody, "Adductors & Abductors", "Bodyweight", 3, 15, "Add an ankle weight once bodyweight reps feel easy."),
        strength("lb-adduct-4", "Sumo Squat", .lowerBody, "Adductors & Abductors", "Dumbbell", 3, 12, "Toes out, knees tracking over toes through the whole rep."),
        strength("lb-adduct-5", "Lateral Band Walk", .lowerBody, "Adductors & Abductors", "Resistance Band", 3, 12, "Stay low the entire set — standing up resets the tension."),
    ]

    // MARK: - Full Body

    private static let fullBody: [ExerciseTemplate] = [
        strength("fb-compound-1", "Deadlift", .fullBody, "Compound Lifts", "Barbell", 4, 5, "The king of loading — add small plates once form is locked in."),
        strength("fb-compound-2", "Clean and Press", .fullBody, "Compound Lifts", "Barbell", 4, 5, "Technique caps your load here more than strength does."),
        strength("fb-compound-3", "Thruster", .fullBody, "Compound Lifts", "Barbell", 4, 8, "Front squat depth feeds directly into the press."),
        strength("fb-compound-4", "Barbell Complex", .fullBody, "Compound Lifts", "Barbell", 3, 6, "Chain the moves without setting the bar down."),
        strength("fb-compound-5", "Snatch", .fullBody, "Compound Lifts", "Barbell", 5, 3, "Speed under the bar matters more than raw weight."),

        strength("fb-circuit-1", "Burpees", .fullBody, "Circuit Training", "Bodyweight", 4, 12, "Pace yourself — burpees punish anyone who sprints the first round."),
        strength("fb-circuit-2", "Mountain Climbers", .fullBody, "Circuit Training", "Bodyweight", 4, 20, "Keep hips low and driven — speed comes after form."),
        strength("fb-circuit-3", "Jumping Jacks", .fullBody, "Circuit Training", "Bodyweight", 4, 25, "A reliable warm-up staple that also holds up as a finisher."),
        strength("fb-circuit-4", "Squat to Press", .fullBody, "Circuit Training", "Dumbbell", 3, 12, "Let the squat's momentum help drive the press upward."),
        strength("fb-circuit-5", "Bear Crawl", .fullBody, "Circuit Training", "Bodyweight", 3, 15, "Keep knees hovering just off the floor the entire crawl."),

        hold("fb-func-1", "Farmer's Carry", .fullBody, "Functional", "Dumbbell", 4, 40, "Grip fails first — heavier carries build it fast."),
        hold("fb-func-2", "Sled Push", .fullBody, "Functional", "Sled", 4, 30, "Short, hard pushes beat one long grinding push."),
        hold("fb-func-3", "Tire Flip", .fullBody, "Functional", "Tire", 4, 20, "Drive through the legs, not the lower back."),
        hold("fb-func-4", "Sandbag Carry", .fullBody, "Functional", "Sandbag", 3, 45, "The shifting weight builds stability faster than fixed loads."),
        hold("fb-func-5", "Battle Ropes", .fullBody, "Functional", "Battle Ropes", 4, 30, "Alternate wave patterns to keep the stimulus fresh."),

        strength("fb-kb-1", "Kettlebell Swing", .fullBody, "Kettlebell", "Kettlebell", 4, 15, "Snap the hips — the arms are just along for the ride."),
        strength("fb-kb-2", "Kettlebell Goblet Squat", .fullBody, "Kettlebell", "Kettlebell", 3, 12, "Elbows brush the inside of your knees at the bottom."),
        strength("fb-kb-3", "Kettlebell Snatch", .fullBody, "Kettlebell", "Kettlebell", 4, 8, "Punch through at the top instead of pressing."),
        strength("fb-kb-4", "Kettlebell Clean", .fullBody, "Kettlebell", "Kettlebell", 3, 8, "Keep the bell close to the body on the way up."),
        strength("fb-kb-5", "Turkish Get-Up", .fullBody, "Kettlebell", "Kettlebell", 3, 5, "Slow is smooth — rushing the get-up is how form breaks."),

        strength("fb-flow-1", "Push-Up to Squat", .fullBody, "Bodyweight Flow", "Bodyweight", 3, 12, "Keep the transition smooth — no wasted resets."),
        strength("fb-flow-2", "Inchworm", .fullBody, "Bodyweight Flow", "Bodyweight", 3, 10, "Walk hands out slow to add a hamstring stretch bonus."),
        strength("fb-flow-3", "Plank Jacks", .fullBody, "Bodyweight Flow", "Bodyweight", 3, 20, "Keep hips level — don't let them pike up as you tire."),
        strength("fb-flow-4", "Animal Flow Crawl", .fullBody, "Bodyweight Flow", "Bodyweight", 3, 30, "Move deliberately — this is about control, not speed."),
        strength("fb-flow-5", "Burpee Broad Jump", .fullBody, "Bodyweight Flow", "Bodyweight", 3, 8, "Reset fully between reps to protect the landing."),
    ]

    // MARK: - Core

    private static let core: [ExerciseTemplate] = [
        strength("core-upper-1", "Crunches", .core, "Upper Abs", "Bodyweight", 3, 20, "Add a slow 2-second squeeze at the top of each rep."),
        strength("core-upper-2", "Sit-Ups", .core, "Upper Abs", "Bodyweight", 3, 15, "Hold a light plate on your chest once bodyweight is easy."),
        strength("core-upper-3", "Cable Crunch", .core, "Upper Abs", "Cable", 3, 15, "Curl the spine — don't just hinge from the hips."),
        strength("core-upper-4", "Weighted Crunch", .core, "Upper Abs", "Dumbbell", 3, 15, "Add weight in small increments; abs fatigue quickly."),
        strength("core-upper-5", "Toe Touches", .core, "Upper Abs", "Bodyweight", 3, 15, "Reach with control instead of using momentum to swing up."),

        strength("core-lower-1", "Leg Raises", .core, "Lower Abs", "Bodyweight", 3, 12, "Keep the lower back pressed to the floor throughout."),
        strength("core-lower-2", "Reverse Crunch", .core, "Lower Abs", "Bodyweight", 3, 15, "Curl the hips up and off the ground, not just the knees."),
        strength("core-lower-3", "Flutter Kicks", .core, "Lower Abs", "Bodyweight", 3, 30, "Keep legs a few inches off the floor the entire set."),
        strength("core-lower-4", "Hanging Knee Raise", .core, "Lower Abs", "Pull-Up Bar", 3, 12, "Avoid swinging — control both the raise and the lower."),
        strength("core-lower-5", "Bicycle Crunch", .core, "Lower Abs", "Bodyweight", 3, 20, "Slow the tempo down for a much harder version of this classic."),

        strength("core-oblique-1", "Russian Twist", .core, "Obliques", "Dumbbell", 3, 20, "Rotate from the ribs, not just the arms."),
        hold("core-oblique-2", "Side Plank", .core, "Obliques", "Bodyweight", 3, 30, "Stack hips vertically — sagging cuts the work in half."),
        strength("core-oblique-3", "Woodchopper", .core, "Obliques", "Cable", 3, 12, "Pivot the back foot to let the rotation flow through."),
        strength("core-oblique-4", "Bicycle Crunch Oblique Focus", .core, "Obliques", "Bodyweight", 3, 16, "Pause briefly at each elbow-to-knee touch."),
        strength("core-oblique-5", "Standing Oblique Crunch", .core, "Obliques", "Dumbbell", 3, 15, "Crunch sideways, not forward — isolate the oblique."),

        hold("core-deep-1", "Plank", .core, "Deep Core & Stability", "Bodyweight", 3, 45, "Add 10 seconds per side once form stays clean start to finish."),
        strength("core-deep-2", "Dead Bug", .core, "Deep Core & Stability", "Bodyweight", 3, 12, "Press the low back into the floor on every rep."),
        hold("core-deep-3", "Bird Dog", .core, "Deep Core & Stability", "Bodyweight", 3, 20, "Move slow enough that your hips never rock side to side."),
        hold("core-deep-4", "Pallof Press", .core, "Deep Core & Stability", "Cable", 3, 20, "Resist the rotation — that's the entire point of the move."),
        hold("core-deep-5", "Hollow Body Hold", .core, "Deep Core & Stability", "Bodyweight", 3, 25, "Press the low back flat and keep breathing steady."),

        hold("core-lowback-1", "Superman", .core, "Lower Back", "Bodyweight", 3, 20, "Lift chest and legs together for balanced extension."),
        strength("core-lowback-2", "Back Extension", .core, "Lower Back", "Machine", 3, 12, "Rise until your body is a straight line — no hyperextending."),
        strength("core-lowback-3", "Good Morning", .core, "Lower Back", "Barbell", 3, 10, "Very light load to start; this move humbles egos fast."),
        strength("core-lowback-4", "Bird Dog Row", .core, "Lower Back", "Dumbbell", 3, 10, "Row while staying balanced on the opposite hand and knee."),
        session("core-lowback-5", "Cat-Cow", .core, "Lower Back", "Bodyweight", 3, 2, "Move with your breath — inhale to arch, exhale to round."),
    ]

    // MARK: - Cardio

    private static let cardioCat: [ExerciseTemplate] = [
        cardio("cardio-steady-1", "Treadmill Jog", .cardio, "Steady-State", "Treadmill", 30, 1, 5, "Extend by 5 minutes before you reach for more pace."),
        cardio("cardio-steady-2", "Outdoor Run", .cardio, "Steady-State", "None", 30, 0, 5, "Negative-split your route once distance stops feeling hard."),
        cardio("cardio-steady-3", "Elliptical", .cardio, "Steady-State", "Elliptical", 25, 2, 4, "Add resistance level before adding time."),
        cardio("cardio-steady-4", "Stationary Bike", .cardio, "Steady-State", "Bike", 30, 0, 5, "Increase cadence for a few minutes each session."),
        cardio("cardio-steady-5", "Stair Climber", .cardio, "Steady-State", "Stair Climber", 20, 0, 6, "Resist gripping the rails — let your legs do the work."),

        cardio("cardio-int-1", "Treadmill Sprints", .cardio, "Intervals", "Treadmill", 20, 1, 8, "Add one more sprint round before increasing top speed."),
        cardio("cardio-int-2", "Bike Intervals", .cardio, "Intervals", "Bike", 25, 0, 8, "Match your rest to your work — don't shortchange recovery."),
        cardio("cardio-int-3", "Rowing Intervals", .cardio, "Intervals", "Rower", 20, 0, 8, "Watch the split time, not just stroke count."),
        cardio("cardio-int-4", "Assault Bike Intervals", .cardio, "Intervals", "Assault Bike", 15, 0, 9, "Brutal by design — hold pace instead of going all-out early."),
        cardio("cardio-int-5", "Track Intervals", .cardio, "Intervals", "None", 25, 0, 8, "Hit consistent lap splits before chasing a faster pace."),

        cardio("cardio-incl-1", "Incline Treadmill Walk", .cardio, "Incline & Stairs", "Treadmill", 30, 10, 5, "Add one incline percent per week rather than speed."),
        cardio("cardio-incl-2", "StairMaster", .cardio, "Incline & Stairs", "StairMaster", 20, 0, 6, "Keep torso upright to keep glutes and hamstrings in charge."),
        cardio("cardio-incl-3", "Hill Sprints", .cardio, "Incline & Stairs", "None", 15, 8, 9, "Walk down for full recovery between reps."),
        cardio("cardio-incl-4", "Incline Bike", .cardio, "Incline & Stairs", "Bike", 25, 5, 6, "Raise resistance gradually to simulate steeper climbs."),
        cardio("cardio-incl-5", "Stadium Stairs", .cardio, "Incline & Stairs", "None", 20, 0, 7, "Take single steps until balance and pace feel automatic."),

        cardio("cardio-cycle-1", "Spin Class", .cardio, "Cycling", "Bike", 45, 3, 7, "Match instructor cadence before chasing their resistance."),
        cardio("cardio-cycle-2", "Road Cycling", .cardio, "Cycling", "Bike", 60, 2, 6, "Build duration first, hills second."),
        cardio("cardio-cycle-3", "Indoor Cycling", .cardio, "Cycling", "Bike", 40, 0, 6, "Structured intervals beat random effort for steady gains."),
        cardio("cardio-cycle-4", "Hill Cycling", .cardio, "Cycling", "Bike", 45, 6, 7, "Stay seated longer before standing to climb."),
        cardio("cardio-cycle-5", "Recovery Ride", .cardio, "Cycling", "Bike", 30, 0, 3, "Keep effort easy — this ride is about blood flow, not gains."),

        cardio("cardio-row-1", "Rowing Machine Steady", .cardio, "Rowing", "Rower", 25, 0, 5, "Lengthen the stroke before increasing stroke rate."),
        cardio("cardio-row-2", "Rowing Sprints", .cardio, "Rowing", "Rower", 15, 0, 9, "Drive with legs first, then back, then arms — in that order."),
        cardio("cardio-row-3", "Rowing Pyramid", .cardio, "Rowing", "Rower", 20, 0, 7, "Climb the pyramid before adding another rung."),
        cardio("cardio-row-4", "SkiErg", .cardio, "Rowing", "SkiErg", 15, 0, 7, "Engage the lats on the pull instead of just the arms."),
        cardio("cardio-row-5", "Row + Bike Combo", .cardio, "Rowing", "Rower", 30, 0, 6, "Split evenly at first, then bias toward your weaker machine."),
    ]

    // MARK: - HIIT

    private static let hiit: [ExerciseTemplate] = [
        interval("hiit-body-1", "Burpee Intervals", .hiit, "Bodyweight HIIT", "Bodyweight", 8, 30, 30, 8, "Add a round before shortening the rest window."),
        interval("hiit-body-2", "Jump Squat Intervals", .hiit, "Bodyweight HIIT", "Bodyweight", 8, 30, 30, 7, "Land soft — quiet landings mean better force absorption."),
        interval("hiit-body-3", "Mountain Climber Intervals", .hiit, "Bodyweight HIIT", "Bodyweight", 8, 30, 20, 7, "Keep hips low the whole round, even as pace drops."),
        interval("hiit-body-4", "High Knees Intervals", .hiit, "Bodyweight HIIT", "Bodyweight", 8, 30, 20, 7, "Drive knees to hip height, not just fast feet."),
        interval("hiit-body-5", "Plank Jack Intervals", .hiit, "Bodyweight HIIT", "Bodyweight", 6, 30, 30, 6, "Keep the plank rigid — don't let hips bounce."),

        interval("hiit-equip-1", "Kettlebell Swing Intervals", .hiit, "Equipment HIIT", "Kettlebell", 8, 30, 30, 8, "Snap the hips hard each rep, even deep into the round."),
        interval("hiit-equip-2", "Battle Rope Intervals", .hiit, "Equipment HIIT", "Battle Ropes", 8, 20, 40, 8, "Alternate wave styles round to round to spread the load."),
        interval("hiit-equip-3", "Sled Sprint Intervals", .hiit, "Equipment HIIT", "Sled", 6, 20, 60, 9, "Full recovery matters more here than round count."),
        interval("hiit-equip-4", "Box Jump Intervals", .hiit, "Equipment HIIT", "Plyo Box", 6, 20, 40, 7, "Step down between reps to protect the knees."),
        interval("hiit-equip-5", "Med Ball Slam Intervals", .hiit, "Equipment HIIT", "Medicine Ball", 8, 30, 30, 7, "Slam from full extension — let the whole body drive the ball."),

        interval("hiit-tabata-1", "Tabata Squats", .hiit, "Tabata", "Bodyweight", 8, 20, 10, 9, "Classic 20/10 — hold pace through round eight."),
        interval("hiit-tabata-2", "Tabata Push-Ups", .hiit, "Tabata", "Bodyweight", 8, 20, 10, 8, "Drop to knees if needed rather than break form."),
        interval("hiit-tabata-3", "Tabata Bike", .hiit, "Tabata", "Bike", 8, 20, 10, 9, "Max effort on the work interval — that's the entire protocol."),
        interval("hiit-tabata-4", "Tabata Burpees", .hiit, "Tabata", "Bodyweight", 8, 20, 10, 9, "One of the hardest combinations on this list — pace round one."),
        interval("hiit-tabata-5", "Tabata Row", .hiit, "Tabata", "Rower", 8, 20, 10, 9, "Focus on stroke power over stroke count."),

        interval("hiit-emom-1", "EMOM Kettlebell Swings", .hiit, "EMOM", "Kettlebell", 10, 15, 45, 7, "Add reps per minute before adding minutes."),
        interval("hiit-emom-2", "EMOM Burpees", .hiit, "EMOM", "Bodyweight", 10, 20, 40, 8, "Keep the target rep count steady across all ten minutes."),
        interval("hiit-emom-3", "EMOM Thrusters", .hiit, "EMOM", "Dumbbell", 10, 20, 40, 8, "Choose a weight you can move for all ten rounds unbroken."),
        interval("hiit-emom-4", "EMOM Row Calories", .hiit, "EMOM", "Rower", 10, 20, 40, 7, "Track calories per minute — consistency beats a hot first round."),
        interval("hiit-emom-5", "EMOM Air Squats", .hiit, "EMOM", "Bodyweight", 12, 15, 45, 6, "A great on-ramp EMOM for building the format's pacing sense."),

        interval("hiit-circuit-1", "Full Body Circuit", .hiit, "Circuit HIIT", "Mixed", 5, 40, 20, 7, "Cycle through stations twice before adding a third round."),
        interval("hiit-circuit-2", "Upper Body HIIT Circuit", .hiit, "Circuit HIIT", "Dumbbell", 5, 40, 20, 7, "Superset push and pull moves to keep pace high."),
        interval("hiit-circuit-3", "Lower Body HIIT Circuit", .hiit, "Circuit HIIT", "Bodyweight", 5, 40, 20, 7, "Expect the legs to fatigue fast — that's the intent."),
        interval("hiit-circuit-4", "Core HIIT Circuit", .hiit, "Circuit HIIT", "Bodyweight", 5, 30, 20, 6, "Finish with the hardest core move while still fresh-ish."),
        interval("hiit-circuit-5", "Cardio Strength Circuit", .hiit, "Circuit HIIT", "Mixed", 6, 40, 20, 8, "Alternate a cardio burst with a strength move each station."),
    ]

    // MARK: - Flexibility & Mobility

    private static let flexibility: [ExerciseTemplate] = [
        hold("flex-static-1", "Hamstring Stretch", .flexibility, "Static Stretching", "None", 2, 30, "Ease deeper on the exhale rather than forcing the stretch."),
        hold("flex-static-2", "Quad Stretch", .flexibility, "Static Stretching", "None", 2, 30, "Keep knees together to isolate the quad fully."),
        hold("flex-static-3", "Chest Doorway Stretch", .flexibility, "Static Stretching", "None", 2, 30, "Adjust arm height to shift which chest fibers stretch."),
        hold("flex-static-4", "Shoulder Cross-Body Stretch", .flexibility, "Static Stretching", "None", 2, 30, "Use the opposite arm to gently increase the pull."),
        hold("flex-static-5", "Calf Wall Stretch", .flexibility, "Static Stretching", "None", 2, 30, "Keep the back heel grounded for the deepest stretch."),

        session("flex-dyn-1", "Leg Swings", .flexibility, "Dynamic Mobility", "None", 3, 3, "Controlled range first, then let the swing grow."),
        session("flex-dyn-2", "Arm Circles", .flexibility, "Dynamic Mobility", "None", 3, 2, "Small circles first, building to full range."),
        session("flex-dyn-3", "Walking Lunges with Twist", .flexibility, "Dynamic Mobility", "None", 5, 3, "Rotate toward the front leg on every step."),
        session("flex-dyn-4", "Hip Openers", .flexibility, "Dynamic Mobility", "None", 5, 3, "Great primer before any lower body training day."),
        session("flex-dyn-5", "World's Greatest Stretch", .flexibility, "Dynamic Mobility", "None", 5, 4, "One of the highest value movements for full-body mobility."),

        session("flex-yoga-1", "Sun Salutation Flow", .flexibility, "Yoga Flow", "Mat", 15, 4, "Sync each movement with a full inhale or exhale."),
        session("flex-yoga-2", "Vinyasa Flow", .flexibility, "Yoga Flow", "Mat", 30, 5, "Let breath set the pace, not the pose sequence."),
        session("flex-yoga-3", "Restorative Yoga Flow", .flexibility, "Yoga Flow", "Mat", 25, 2, "Hold each pose far longer than feels necessary at first."),
        session("flex-yoga-4", "Power Yoga Flow", .flexibility, "Yoga Flow", "Mat", 35, 6, "A strength-and-flexibility hybrid — expect to sweat."),
        session("flex-yoga-5", "Yin Yoga Flow", .flexibility, "Yoga Flow", "Mat", 30, 2, "Passive holds of 2-3 minutes target deep connective tissue."),

        hold("flex-roll-1", "Foam Roll Quads", .flexibility, "Foam Rolling", "Foam Roller", 2, 45, "Pause on tender spots instead of rolling straight through."),
        hold("flex-roll-2", "Foam Roll Back", .flexibility, "Foam Rolling", "Foam Roller", 2, 45, "Avoid rolling directly on the lower spine."),
        hold("flex-roll-3", "Foam Roll IT Band", .flexibility, "Foam Rolling", "Foam Roller", 2, 45, "Notoriously tender — ease in gradually over weeks."),
        hold("flex-roll-4", "Foam Roll Calves", .flexibility, "Foam Rolling", "Foam Roller", 2, 45, "Cross one leg over the other to add pressure."),
        hold("flex-roll-5", "Foam Roll Glutes", .flexibility, "Foam Rolling", "Foam Roller", 2, 45, "Shift weight side to side to hit the whole muscle."),

        hold("flex-hip-1", "90/90 Hip Stretch", .flexibility, "Hip & Shoulder Mobility", "None", 2, 40, "Keep the torso tall rather than folding forward."),
        hold("flex-hip-2", "Pigeon Pose", .flexibility, "Hip & Shoulder Mobility", "Mat", 2, 45, "Square the hips to the mat as best you can."),
        session("flex-hip-3", "Shoulder Dislocates", .flexibility, "Hip & Shoulder Mobility", "Resistance Band", 3, 2, "Widen your grip if the range feels restricted."),
        hold("flex-hip-4", "Couch Stretch", .flexibility, "Hip & Shoulder Mobility", "None", 2, 45, "One of the best hip flexor stretches — ease in slowly."),
        hold("flex-hip-5", "Thread the Needle", .flexibility, "Hip & Shoulder Mobility", "Mat", 2, 30, "Great for upper back and shoulder rotation together."),
    ]

    // MARK: - Recovery

    private static let recovery: [ExerciseTemplate] = [
        session("rec-active-1", "Easy Walk", .recovery, "Active Recovery", "None", 25, 2, "Keep a conversational pace — this isn't a workout day."),
        session("rec-active-2", "Light Swim", .recovery, "Active Recovery", "Pool", 20, 3, "Easy, unhurried laps to flush the legs."),
        session("rec-active-3", "Gentle Cycling", .recovery, "Active Recovery", "Bike", 25, 2, "Low resistance, easy cadence — the point is blood flow."),
        session("rec-active-4", "Mobility Flow", .recovery, "Active Recovery", "Mat", 15, 2, "Move through full ranges slowly rather than statically."),
        session("rec-active-5", "Recovery Row", .recovery, "Active Recovery", "Rower", 15, 2, "Aim for smooth, unhurried strokes throughout."),

        session("rec-breath-1", "Box Breathing", .recovery, "Breathwork", "None", 10, 1, "Four seconds in, hold, out, hold — repeat steadily."),
        session("rec-breath-2", "4-7-8 Breathing", .recovery, "Breathwork", "None", 8, 1, "Great before bed to help the body wind down."),
        session("rec-breath-3", "Diaphragmatic Breathing", .recovery, "Breathwork", "None", 10, 1, "Hand on belly — it should rise more than your chest."),
        session("rec-breath-4", "Guided Breath Reset", .recovery, "Breathwork", "None", 10, 1, "Use any calm moment during the day for a quick reset."),
        session("rec-breath-5", "Cold Exposure Breathing", .recovery, "Breathwork", "None", 5, 3, "Stay calm and controlled rather than gasping."),

        session("rec-walk-1", "Neighborhood Walk", .recovery, "Light Walk", "None", 20, 2, "A short daily habit that compounds over months."),
        session("rec-walk-2", "Post-Meal Walk", .recovery, "Light Walk", "None", 15, 2, "Ten to fifteen minutes helps regulate blood sugar."),
        session("rec-walk-3", "Sunrise Walk", .recovery, "Light Walk", "None", 20, 2, "Morning light exposure helps set your sleep rhythm too."),
        session("rec-walk-4", "Dog Walk", .recovery, "Light Walk", "None", 20, 2, "A built-in excuse to move most days of the week."),
        session("rec-walk-5", "Treadmill Recovery Walk", .recovery, "Light Walk", "Treadmill", 20, 2, "Keep the incline flat and the pace easy."),

        hold("rec-restore-1", "Legs Up The Wall", .recovery, "Restorative Yoga", "Mat", 1, 300, "A simple pose with an outsized calming effect."),
        hold("rec-restore-2", "Child's Pose", .recovery, "Restorative Yoga", "Mat", 2, 60, "Let your hips settle back toward your heels."),
        hold("rec-restore-3", "Supported Bridge", .recovery, "Restorative Yoga", "Yoga Block", 1, 120, "A block under the sacrum turns this into deep rest."),
        hold("rec-restore-4", "Reclined Twist", .recovery, "Restorative Yoga", "Mat", 2, 60, "Let gravity do the work rather than forcing the twist."),
        hold("rec-restore-5", "Savasana", .recovery, "Restorative Yoga", "Mat", 1, 300, "The most important pose to never skip."),

        session("rec-sleep-1", "Wind-Down Stretch", .recovery, "Sleep & Rest", "Mat", 10, 1, "A short routine an hour before bed signals it's time to rest."),
        session("rec-sleep-2", "Evening Mobility", .recovery, "Sleep & Rest", "Mat", 12, 1, "Gentle, unhurried movement to close out the day."),
        session("rec-sleep-3", "Nap Reset", .recovery, "Sleep & Rest", "None", 20, 1, "Keep naps under 30 minutes to avoid grogginess."),
        session("rec-sleep-4", "Screen-Free Wind Down", .recovery, "Sleep & Rest", "None", 30, 1, "Dim the lights and step away from screens beforehand."),
        session("rec-sleep-5", "Bedtime Breathing", .recovery, "Sleep & Rest", "None", 8, 1, "Slow exhales longer than inhales to cue the body to relax."),
    ]

    // MARK: - Activity

    private static let activity: [ExerciseTemplate] = [
        distance("act-walk-1", "Neighborhood Walk", .activity, "Walking & Hiking", "None", 2.0, 35, "Extend your usual loop by a block or two."),
        distance("act-walk-2", "Trail Hike", .activity, "Walking & Hiking", "None", 4.0, 90, "Elevation gain matters as much as raw distance here."),
        distance("act-walk-3", "Treadmill Walk", .activity, "Walking & Hiking", "Treadmill", 2.5, 40, "Add incline before adding pace for more benefit."),
        distance("act-walk-4", "Nature Walk", .activity, "Walking & Hiking", "None", 3.0, 50, "An easy way to hit daily movement goals outdoors."),
        distance("act-walk-5", "Summit Hike", .activity, "Walking & Hiking", "None", 6.0, 150, "Pace yourself on the ascent — the summit rewards patience."),

        distance("act-cycle-1", "Road Ride", .activity, "Cycling", "Bike", 12.0, 50, "Build distance gradually — 10% more per week is plenty."),
        distance("act-cycle-2", "Mountain Bike Trail", .activity, "Cycling", "Mountain Bike", 8.0, 60, "Technical terrain slows pace but raises the workload."),
        distance("act-cycle-3", "Bike Commute", .activity, "Cycling", "Bike", 5.0, 25, "Free training time hiding inside your daily commute."),
        distance("act-cycle-4", "Gravel Ride", .activity, "Cycling", "Gravel Bike", 15.0, 75, "Slightly lower tire pressure smooths out the ride."),
        distance("act-cycle-5", "Bikepacking Loop", .activity, "Cycling", "Bike", 25.0, 150, "Load the bike gradually as you build up distance."),

        distance("act-swim-1", "Pool Laps", .activity, "Swimming", "Pool", 0.5, 30, "Alternate strokes to spread the workload evenly."),
        distance("act-swim-2", "Open Water Swim", .activity, "Swimming", "None", 1.0, 40, "Always swim open water with a buddy or safety buoy."),
        distance("act-swim-3", "Ocean Swim", .activity, "Swimming", "None", 0.75, 35, "Respect the current — swim parallel to shore if it's strong."),
        distance("act-swim-4", "Lake Swim", .activity, "Swimming", "None", 0.75, 35, "Calm water is a great place to build open-water confidence."),
        distance("act-swim-5", "Swim Drills", .activity, "Swimming", "Pool", 0.4, 30, "Technique work now pays off in speed and distance later."),

        session("act-dance-1", "Zumba Session", .activity, "Dancing", "None", 45, 6, "High energy, low pressure — just keep moving with the beat."),
        session("act-dance-2", "Hip-Hop Dance Class", .activity, "Dancing", "None", 45, 6, "Learning choreography is its own kind of cognitive workout."),
        session("act-dance-3", "Ballroom Practice", .activity, "Dancing", "None", 40, 4, "Posture and frame matter as much as footwork."),
        session("act-dance-4", "Freestyle Dance Cardio", .activity, "Dancing", "None", 30, 5, "No wrong moves — just keep your heart rate up."),
        session("act-dance-5", "Dance Cardio Circuit", .activity, "Dancing", "None", 35, 6, "Great substitute on days a formal gym session feels like too much."),

        session("act-play-1", "Frisbee in the Park", .activity, "Outdoor Play", "Frisbee", 40, 4, "Sprint the short bursts, walk the recovery between throws."),
        session("act-play-2", "Playground Circuit with Kids", .activity, "Outdoor Play", "None", 30, 4, "Follow their energy — it's a surprisingly great interval workout."),
        session("act-play-3", "Beach Games", .activity, "Outdoor Play", "None", 45, 5, "Sand adds resistance to every single step."),
        session("act-play-4", "Backyard Sports", .activity, "Outdoor Play", "None", 30, 4, "Whatever's on hand — the goal is just to move and enjoy it."),
        session("act-play-5", "Recreational Kayaking", .activity, "Outdoor Play", "Kayak", 45, 4, "Rotate through the torso to save your arms."),
    ]

    // MARK: - Sports

    private static let sports: [ExerciseTemplate] = [
        session("sport-bball-1", "Pickup Game", .sports, "Basketball", "None", 60, 7, "Full games build conditioning that drills alone can't match."),
        session("sport-bball-2", "Shooting Drills", .sports, "Basketball", "None", 30, 4, "Track makes out of attempts to measure real progress."),
        session("sport-bball-3", "1-on-1", .sports, "Basketball", "None", 30, 6, "Great for sharpening both offense and on-ball defense."),
        session("sport-bball-4", "Full Court Scrimmage", .sports, "Basketball", "None", 60, 8, "The closest thing to real game conditioning."),
        session("sport-bball-5", "Layup Drills", .sports, "Basketball", "None", 20, 4, "Work both hands equally, not just your dominant side."),

        session("sport-soccer-1", "Pickup Match", .sports, "Soccer", "None", 60, 7, "Constant movement makes this a stealth cardio session."),
        session("sport-soccer-2", "Dribbling Drills", .sports, "Soccer", "None", 25, 4, "Close touches under control beat speed without it."),
        session("sport-soccer-3", "Passing Practice", .sports, "Soccer", "None", 25, 3, "Both feet, every session — don't favor your strong foot."),
        session("sport-soccer-4", "Shooting Practice", .sports, "Soccer", "None", 25, 5, "Placement beats power more often than people expect."),
        session("sport-soccer-5", "Small-Sided Game", .sports, "Soccer", "None", 40, 7, "Fewer players means more touches and more conditioning."),

        session("sport-tennis-1", "Singles Match", .sports, "Tennis", "Racquet", 60, 7, "Singles is a far bigger conditioning test than doubles."),
        session("sport-tennis-2", "Doubles Match", .sports, "Tennis", "Racquet", 60, 5, "Court positioning matters more than raw speed here."),
        session("sport-tennis-3", "Serve Practice", .sports, "Tennis", "Racquet", 30, 4, "Track first-serve percentage, not just power."),
        session("sport-tennis-4", "Rally Drills", .sports, "Tennis", "Racquet", 30, 5, "Consistency drills build the base for match play."),
        session("sport-tennis-5", "Ball Machine Session", .sports, "Tennis", "Ball Machine", 40, 5, "Increase feed speed once your footwork keeps up easily."),

        session("sport-combat-1", "Boxing Sparring", .sports, "Combat Sports", "Gloves", 30, 8, "Always spar at a controlled pace with a trusted partner."),
        session("sport-combat-2", "Muay Thai Pads", .sports, "Combat Sports", "Pads", 30, 7, "Combos build far more cardio than single strikes."),
        session("sport-combat-3", "BJJ Rolling", .sports, "Combat Sports", "Gi", 40, 7, "Tap early, tap often — longevity beats ego here."),
        session("sport-combat-4", "Wrestling Practice", .sports, "Combat Sports", "None", 40, 8, "Live drilling builds a different fitness than any machine."),
        session("sport-combat-5", "Heavy Bag Work", .sports, "Combat Sports", "Heavy Bag", 25, 6, "Structure rounds like a real fight: work, then rest."),

        session("sport-climb-1", "Bouldering Session", .sports, "Climbing", "Climbing Shoes", 60, 6, "Grip fatigue sneaks up fast — rest between hard attempts."),
        session("sport-climb-2", "Top Rope Climbing", .sports, "Climbing", "Harness", 60, 5, "Focus on footwork; most beginners over-rely on arms."),
        session("sport-climb-3", "Lead Climbing", .sports, "Climbing", "Harness", 60, 7, "Clean clips and calm breathing beat rushing the route."),
        session("sport-climb-4", "Campus Board Training", .sports, "Climbing", "Campus Board", 20, 8, "Advanced and high-strain — warm up thoroughly first."),
        session("sport-climb-5", "Climbing Gym Circuit", .sports, "Climbing", "Climbing Shoes", 60, 6, "Mix grades to balance volume with genuine difficulty."),
    ]

    // MARK: - Aggregate

    static let all: [ExerciseTemplate] = upperBody + lowerBody + fullBody + core + cardioCat + hiit + flexibility + recovery + activity + sports

    static let subgroupOrder: [WorkoutCategory: [String]] = [
        .upperBody: ["Chest", "Back", "Shoulders", "Biceps", "Triceps"],
        .lowerBody: ["Quads", "Hamstrings", "Glutes", "Calves", "Adductors & Abductors"],
        .fullBody: ["Compound Lifts", "Circuit Training", "Functional", "Kettlebell", "Bodyweight Flow"],
        .core: ["Upper Abs", "Lower Abs", "Obliques", "Deep Core & Stability", "Lower Back"],
        .cardio: ["Steady-State", "Intervals", "Incline & Stairs", "Cycling", "Rowing"],
        .hiit: ["Bodyweight HIIT", "Equipment HIIT", "Tabata", "EMOM", "Circuit HIIT"],
        .flexibility: ["Static Stretching", "Dynamic Mobility", "Yoga Flow", "Foam Rolling", "Hip & Shoulder Mobility"],
        .recovery: ["Active Recovery", "Breathwork", "Light Walk", "Restorative Yoga", "Sleep & Rest"],
        .activity: ["Walking & Hiking", "Cycling", "Swimming", "Dancing", "Outdoor Play"],
        .sports: ["Basketball", "Soccer", "Tennis", "Combat Sports", "Climbing"],
    ]

    static func subgroups(for category: WorkoutCategory) -> [String] {
        subgroupOrder[category] ?? []
    }

    static func exercises(category: WorkoutCategory, subgroup: String) -> [ExerciseTemplate] {
        all.filter { $0.category == category && $0.subgroup == subgroup }
    }

    static func byId(_ id: String) -> ExerciseTemplate? {
        all.first { $0.id == id }
    }
}
