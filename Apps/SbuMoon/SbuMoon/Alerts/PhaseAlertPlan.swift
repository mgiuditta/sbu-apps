import Foundation

/// Which phase alerts to schedule: one on the day of each chosen principal phase, at the chosen
/// time, from now for about a year, never more than iOS keeps pending for an app.
nonisolated enum PhaseAlertPlan {
    /// iOS keeps at most 64 pending local notifications per app and drops the rest.
    static let pendingLimit = 64
    /// How far ahead to plan; the app plans again every time it comes to the foreground.
    static let horizon: TimeInterval = 366 * 86_400

    /// The alerts after `now`, in order.
    /// - Parameters:
    ///   - phases: The phases the user wants to hear about.
    ///   - hour: Hour of the day the alert arrives, in `calendar`'s time zone.
    ///   - minute: Minute of that hour.
    ///   - limit: The most alerts to return.
    static func alerts(
        for phases: Set<PrincipalPhase>,
        hour: Int,
        minute: Int,
        after now: Date,
        calendar: Calendar,
        limit: Int = pendingLimit
    ) -> [PlannedPhaseAlert] {
        guard phases.isEmpty == false, limit > 0 else { return [] }
        let end = now.addingTimeInterval(horizon)
        var alerts: [PlannedPhaseAlert] = []
        // One lunation back: a phase from late yesterday can still have its alert later today.
        var lunation = MoonAstronomy.lunation(containing: now) - 1

        while alerts.count < limit {
            for phase in PrincipalPhase.allCases where phases.contains(phase) {
                let instant = MoonAstronomy.instant(of: phase, lunation: lunation)
                if instant > end {
                    return alerts
                }
                guard let fireDate = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: instant),
                      fireDate > now
                else { continue }
                alerts.append(PlannedPhaseAlert(phase: phase, eventDate: instant, fireDate: fireDate))
                if alerts.count == limit {
                    return alerts
                }
            }
            lunation += 1
        }
        return alerts
    }
}
