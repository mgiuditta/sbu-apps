import Foundation
import Observation

/// "Now" for the screens: moves on when the app comes back and at each midnight, when chores
/// turn due or late, so a list left open overnight is right in the morning.
@Observable
final class Clock {
    private(set) var now: Date

    @ObservationIgnored private let fixed: Bool

    /// - Parameter fixed: A moment that never moves, for screenshots and previews.
    init(fixed: Date? = nil) {
        now = fixed ?? .now
        self.fixed = fixed != nil
    }

    func refresh() {
        guard !fixed else { return }
        now = .now
    }

    /// Ticks at every midnight until cancelled.
    func runMidnights(calendar: Calendar = .current) async {
        while !Task.isCancelled {
            let start = calendar.startOfDay(for: .now)
            let midnight = calendar.date(byAdding: .day, value: 1, to: start) ?? .now.addingTimeInterval(3_600)
            try? await Task.sleep(for: .seconds(max(midnight.timeIntervalSinceNow, 1) + 1))
            refresh()
        }
    }
}
