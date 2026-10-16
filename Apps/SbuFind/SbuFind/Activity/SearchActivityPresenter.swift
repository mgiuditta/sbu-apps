/// Shows the search's Live Activity: ActivityKit on an iPhone, nothing in tests.
protocol SearchActivityPresenter {
    func apply(_ step: SearchActivityPlan.Step)

    /// In the background iOS reports the device far less often: readings stay current longer.
    func setBackground(_ isBackground: Bool)

    /// Ends at once the activities an earlier run of the app left on the Lock Screen.
    func endLeftovers()
}
