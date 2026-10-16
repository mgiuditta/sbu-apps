import Foundation

extension Subscription {
    /// What it has cost so far and since when; a paused or cancelled one stops counting on the day it stopped.
    func tally(today: Date = .now, calendar: Calendar = .current) -> SubscriptionTally {
        let stoppedOn = status == .active ? nil : (events ?? [])
            .filter { $0.kind == .paused || $0.kind == .cancelled }
            .map(\.date)
            .max()
        return SubscriptionTally(schedule: schedule, addedOn: createdAt, stoppedOn: stoppedOn, today: today, calendar: calendar) { day in
            price(on: day, calendar: calendar)
        }
    }
}
