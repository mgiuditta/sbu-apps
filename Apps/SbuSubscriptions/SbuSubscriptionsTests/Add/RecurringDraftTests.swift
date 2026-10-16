import Foundation
import Testing
@testable import SbuSubscriptions

struct RecurringDraftTests {
    @Test func oneOffIsNotRecurring() {
        var draft = SubscriptionDraft(currencyCode: "EUR")
        draft.isRecurring = false
        #expect(draft.cycle == .once)
        #expect(!draft.isRecurring)
    }

    @Test func backToRecurringIsMonthly() {
        var draft = SubscriptionDraft(currencyCode: "EUR")
        draft.isRecurring = false
        draft.isRecurring = true
        #expect(draft.cycle == .monthly)
    }

    @Test func recurringKeepsTheCycleYouChose() {
        var draft = SubscriptionDraft(currencyCode: "EUR")
        draft.cycle = .yearly
        draft.isRecurring = true
        #expect(draft.cycle == .yearly)
    }
}
