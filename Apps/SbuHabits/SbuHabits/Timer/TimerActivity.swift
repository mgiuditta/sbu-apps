import ActivityKit
import Foundation

/// Starts, follows and ends the countdown's Live Activity with ActivityKit, as
/// `TimerActivityPlan` decides. Updates and ends run one after the other in the order they come,
/// so a quick pause and resume never land swapped.
enum TimerActivity {
    /// The last change handed to ActivityKit; the next one waits for it.
    private static var pending: Task<Void, Never>?

    /// Brings the Live Activities on the device in line with `update`. A new activity starts
    /// only while the app is in front, as a countdown does, and only if Live Activities are on.
    static func apply(_ update: TimerActivityUpdate) {
        let activities = Activity<HabitTimerAttributes>.activities.filter { $0.activityState == .active || $0.activityState == .stale }
        let plan = TimerActivityPlan(update: update, running: activities.map { TimerActivityPlan.Running(id: $0.id, habitID: $0.attributes.habitID) })

        if let attributes = plan.started, let state = plan.state, ActivityAuthorizationInfo().areActivitiesEnabled {
            let face = TimerActivityFace(attributes: attributes, state: state)
            // ponytail: a refused request leaves the countdown without its activity; the Timer and the notification still work.
            _ = try? Activity.request(attributes: attributes, content: ActivityContent(state: state, staleDate: face.staleDate))
        }

        let previous = pending
        pending = Task {
            await previous?.value
            await carry(out: plan)
        }
    }

    /// Ends and updates the activities `plan` names, found again by their ids: ActivityKit's
    /// handles stay in this one call.
    private nonisolated static func carry(out plan: TimerActivityPlan) async {
        for activity in Activity<HabitTimerAttributes>.activities {
            if plan.dismissed.contains(activity.id) {
                await activity.end(nil, dismissalPolicy: .immediate)
            } else if plan.finished.contains(activity.id) {
                let content = ActivityContent(state: HabitTimerAttributes.ContentState.done, staleDate: nil)
                await activity.end(content, dismissalPolicy: .after(.now.addingTimeInterval(TimerActivityPlan.doneLinger)))
            } else if plan.followed.contains(activity.id), let state = plan.state {
                let face = TimerActivityFace(attributes: activity.attributes, state: state)
                await activity.update(ActivityContent(state: state, staleDate: face.staleDate))
            }
        }
    }
}
