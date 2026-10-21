import Foundation
import Observation

/// The accounts on every Platform and the one in use on each, kept in UserDefaults.
@Observable
final class AccountStore {
    /// SocialLite's ceiling: up to 10 accounts per Platform.
    static let limit = 10

    private(set) var accounts: [Account]
    private var selection: [Platform: UUID]
    @ObservationIgnored private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        accounts = defaults.data(forKey: "accounts").flatMap { try? JSONDecoder().decode([Account].self, from: $0) } ?? []
        selection = defaults.data(forKey: "selectedAccounts").flatMap { try? JSONDecoder().decode([Platform: UUID].self, from: $0) } ?? [:]
    }

    func accounts(on platform: Platform) -> [Account] {
        accounts.filter { $0.platform == platform }
    }

    /// The account in use on a Platform: the one you chose, or the first; `nil` before the first.
    func current(on platform: Platform) -> Account? {
        let mine = accounts(on: platform)
        return mine.first { $0.id == selection[platform] } ?? mine.first
    }

    func canAdd(on platform: Platform) -> Bool {
        accounts(on: platform).count < Self.limit
    }

    /// A new account on a Platform, made the one in use.
    @discardableResult
    func add(on platform: Platform) -> Account {
        let number = (accounts(on: platform).map(\.number).max() ?? 0) + 1
        let account = Account(id: UUID(), platform: platform, number: number)
        accounts.append(account)
        select(account)
        return account
    }

    func select(_ account: Account) {
        selection[account.platform] = account.id
        save()
    }

    /// Forgets the account; the browser deletes its cookies.
    func remove(_ account: Account) {
        accounts.removeAll { $0.id == account.id }
        if selection[account.platform] == account.id { selection[account.platform] = nil }
        save()
    }

    private func save() {
        defaults.set(try? JSONEncoder().encode(accounts), forKey: "accounts")
        defaults.set(try? JSONEncoder().encode(selection), forKey: "selectedAccounts")
    }
}
