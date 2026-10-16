import Foundation

extension Subscription {
    /// Pauses, resumes, cancels or reactivates it, and records the change in its history.
    func setStatus(_ new: SubscriptionStatus) {
        guard let event = StatusChange.event(from: status, to: new) else { return }
        status = new
        record(event)
    }
}
