import Foundation

/// TV credentials (tokens, client keys, Sony cookie or key, certificate pins) by TV id, in the Keychain.
nonisolated struct CredentialStore: Sendable {
    let keychain: KeychainStore

    static let shared = CredentialStore(keychain: KeychainStore(service: "dev.sbu.remote.tv", accessGroup: AppGroup.keychainAccessGroup))

    func credential(for tvID: UUID) async -> TVCredential? {
        guard let data = try? await keychain.data(for: tvID.uuidString) else { return nil }
        return try? JSONDecoder().decode(TVCredential.self, from: data)
    }

    func save(_ credential: TVCredential, for tvID: UUID) async throws {
        try await keychain.set(try JSONEncoder().encode(credential), for: tvID.uuidString)
    }

    func remove(for tvID: UUID) async throws {
        try await keychain.remove(account: tvID.uuidString)
    }
}
