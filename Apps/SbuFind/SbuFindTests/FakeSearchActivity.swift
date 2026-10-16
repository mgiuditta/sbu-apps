@testable import SbuFind

/// Records the Live Activity steps that do something, and the background changes.
final class FakeSearchActivity: SearchActivityPresenter {
    private(set) var steps: [SearchActivityPlan.Step] = []
    private(set) var isBackground = false

    func apply(_ step: SearchActivityPlan.Step) {
        if step != .none {
            steps.append(step)
        }
    }

    func setBackground(_ isBackground: Bool) {
        self.isBackground = isBackground
    }
}
