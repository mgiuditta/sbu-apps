import Foundation
import Observation

/// "Now" for the screens: moves on when the app comes back, after a mark and each minute a dose
/// can turn late, so a list left open is right without touching it.
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

    /// Ticks at the start of every minute until cancelled: doses turn late on the minute.
    func run(calendar: Calendar = .current) async {
        while !Task.isCancelled {
            let second = calendar.component(.second, from: .now)
            try? await Task.sleep(for: .seconds(60 - second))
            refresh()
        }
    }
}
