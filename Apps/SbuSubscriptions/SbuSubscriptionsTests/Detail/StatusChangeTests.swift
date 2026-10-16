import Testing
@testable import SbuSubscriptions

struct StatusChangeTests {
    @Test(arguments: [
        (SubscriptionStatus.active, SubscriptionStatus.paused, SubscriptionEvent.Kind?.some(.paused)),
        (.active, .cancelled, .cancelled),
        (.paused, .cancelled, .cancelled),
        (.paused, .active, .resumed),
        (.cancelled, .active, .reactivated),
        (.active, .active, nil),
        (.cancelled, .cancelled, nil),
    ])
    func eventForChange(from old: SubscriptionStatus, to new: SubscriptionStatus, expected: SubscriptionEvent.Kind?) {
        #expect(StatusChange.event(from: old, to: new) == expected)
    }
}
