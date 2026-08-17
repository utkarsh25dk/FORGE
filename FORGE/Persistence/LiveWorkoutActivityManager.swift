import Foundation
import ActivityKit

/// Owns the single Live Activity for the workout session currently on screen.
/// All calls are no-ops if the user has Live Activities disabled system-wide.
@MainActor
final class LiveWorkoutActivityManager: ObservableObject {
    private var activity: Activity<WorkoutActivityAttributes>?

    func start(exerciseName: String, index: Int, total: Int) {
        guard activity == nil, ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        let attributes = WorkoutActivityAttributes(startedAt: Date())
        let state = WorkoutActivityAttributes.ContentState(
            exerciseName: exerciseName, exerciseIndex: index, totalExercises: total,
            isResting: false, restEndDate: nil
        )
        activity = try? Activity.request(attributes: attributes, content: .init(state: state, staleDate: nil))
    }

    func update(exerciseName: String, index: Int, total: Int, isResting: Bool, restEndDate: Date?) {
        guard let activity else { return }
        let state = WorkoutActivityAttributes.ContentState(
            exerciseName: exerciseName, exerciseIndex: index, totalExercises: total,
            isResting: isResting, restEndDate: restEndDate
        )
        Task { await activity.update(.init(state: state, staleDate: nil)) }
    }

    func end() {
        guard let activity else { return }
        Task { await activity.end(nil, dismissalPolicy: .immediate) }
        self.activity = nil
    }
}
