import Foundation

/// What a home row says under the name: when it renews or the trial ends, in days and as a date, or why it doesn't.
nonisolated enum RenewalStatus: Hashable, Sendable {
    case renews(inDays: Int, on: Date)
    case trialEnds(inDays: Int, on: Date)
    case paused
    case cancelled
    /// Paid off, or a one-off already paid.
    case finished

    /// - Parameters:
    ///   - status: The subscription's state.
    ///   - trialEnd: The day its free trial ends, if it is in one.
    ///   - nextPayment: Its next payment, or `nil` when there is none.
    ///   - today: The day the row is for.
    init(status: SubscriptionStatus, trialEnd: Date?, nextPayment: Date?, today: Date, calendar: Calendar) {
        switch status {
        case .paused: self = .paused
        case .cancelled: self = .cancelled
        case .active:
            if let trialEnd {
                self = .trialEnds(inDays: Self.days(from: today, to: trialEnd, calendar: calendar), on: calendar.startOfDay(for: trialEnd))
            } else if let nextPayment {
                self = .renews(inDays: Self.days(from: today, to: nextPayment, calendar: calendar), on: calendar.startOfDay(for: nextPayment))
            } else {
                self = .finished
            }
        }
    }

    /// Whole days between the two days, never below zero.
    private static func days(from today: Date, to day: Date, calendar: Calendar) -> Int {
        max(0, calendar.dateComponents([.day], from: calendar.startOfDay(for: today), to: calendar.startOfDay(for: day)).day ?? 0)
    }
}
