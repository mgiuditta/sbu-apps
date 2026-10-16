import Foundation
import Security

/// Generic-password items of one service, off the main actor (every `SecItem` call is an IPC round trip).
///
/// Items are `AfterFirstUnlockThisDeviceOnly`: the widget and Shortcuts may send a key while the
/// phone is locked, and a TV credential has no reason to leave this iPhone in a backup.
actor KeychainStore {
    enum Failure: Error, Equatable {
        case status(OSStatus)
    }

    private let service: String
    private let accessGroup: String?

    init(service: String, accessGroup: String? = nil) {
        self.service = service
        self.accessGroup = accessGroup
    }

    func data(for account: String) throws -> Data? {
        var query = baseQuery(account: account)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        switch status {
        case errSecSuccess:
            return result as? Data
        case errSecItemNotFound:
            return nil
        default:
            // errSecInteractionNotAllowed included: report it, never delete on it.
            throw Failure.status(status)
        }
    }

    /// Adds the item, or updates it when it exists (never delete-then-add).
    func set(_ data: Data, for account: String) throws {
        var attributes = baseQuery(account: account)
        attributes[kSecValueData as String] = data
        attributes[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        let status = SecItemAdd(attributes as CFDictionary, nil)
        switch status {
        case errSecSuccess:
            return
        case errSecDuplicateItem:
            let update = [kSecValueData as String: data] as CFDictionary
            let updateStatus = SecItemUpdate(baseQuery(account: account) as CFDictionary, update)
            guard updateStatus == errSecSuccess else { throw Failure.status(updateStatus) }
        default:
            throw Failure.status(status)
        }
    }

    func remove(account: String) throws {
        let status = SecItemDelete(baseQuery(account: account) as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else { throw Failure.status(status) }
    }

    private func baseQuery(account: String) -> [String: Any] {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
        if let accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        return query
    }
}
