import Foundation
import Testing
@testable import SbuSocial

struct AccountStoreTests {
    private let defaults: UserDefaults

    init() {
        let suite = "AccountStoreTests-\(UUID())"
        defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
    }

    @Test func noAccountUntilTheFirstIsAdded() {
        let store = AccountStore(defaults: defaults)
        #expect(store.current(on: .instagram) == nil)
        let first = store.add(on: .instagram)
        #expect(store.current(on: .instagram) == first)
        #expect(first.number == 1)
    }

    @Test func aNewAccountBecomesTheOneInUseAndNumbersAreNeverReused() {
        let store = AccountStore(defaults: defaults)
        let first = store.add(on: .instagram)
        let second = store.add(on: .instagram)
        #expect(store.current(on: .instagram) == second)
        store.remove(second)
        #expect(store.current(on: .instagram) == first)
        #expect(store.add(on: .instagram).number == 2)
        store.remove(first)
        #expect(store.add(on: .instagram).number == 3)
    }

    @Test func eachPlatformKeepsItsOwnAccounts() {
        let store = AccountStore(defaults: defaults)
        store.add(on: .instagram)
        store.add(on: .youtube)
        #expect(store.accounts(on: .instagram).count == 1)
        #expect(store.current(on: .youtube)?.platform == .youtube)
    }

    @Test func accountsAndTheChoiceSurviveARelaunch() {
        let store = AccountStore(defaults: defaults)
        let first = store.add(on: .instagram)
        store.add(on: .instagram)
        store.select(first)
        let relaunched = AccountStore(defaults: defaults)
        #expect(relaunched.accounts == store.accounts)
        #expect(relaunched.current(on: .instagram) == first)
    }

    @Test func tenAccountsAtMostOnAPlatform() {
        let store = AccountStore(defaults: defaults)
        for _ in 0..<AccountStore.limit { store.add(on: .instagram) }
        #expect(!store.canAdd(on: .instagram))
        #expect(store.canAdd(on: .youtube))
    }
}
