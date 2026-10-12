@testable import SbuHabits

/// Keeps every reminder plan a `HabitsModel` hands over, in place of the notification center.
final class PlanLog {
    private(set) var plans: [[PlannedReminder]] = []

    var last: [PlannedReminder]? { plans.last }

    func record(_ plan: [PlannedReminder]) {
        plans.append(plan)
    }
}
