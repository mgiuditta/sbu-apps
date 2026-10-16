/// Shows no Live Activity: for the simulator's fixed scanner, UI tests and previews.
struct NoSearchActivity: SearchActivityPresenter {
    func apply(_ step: SearchActivityPlan.Step) {}

    func setBackground(_ isBackground: Bool) {}
}
