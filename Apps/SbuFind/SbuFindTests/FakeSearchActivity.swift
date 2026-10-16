@testable import SbuFind

/// Records the Live Activity steps that do something.
final class FakeSearchActivity: SearchActivityPresenter {
    private(set) var steps: [SearchActivityPlan.Step] = []

    func apply(_ step: SearchActivityPlan.Step) {
        if step != .none {
            steps.append(step)
        }
    }
}
