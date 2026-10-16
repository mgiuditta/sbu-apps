import Foundation

/// What a TV gave Sbu Remote at pairing, kept in the Keychain under the TV's id.
nonisolated struct TVCredential: Codable, Equatable, Sendable {
    /// Samsung token or LG client key.
    var token: String?
    /// Sony: the `auth` cookie from PIN pairing.
    var cookie: String?
    /// Sony: the pre-shared key set under Controllo IP.
    var preSharedKey: String?
    /// SHA-256 of the TV's TLS certificate, seen at pairing: later connections must show the same one.
    var certificateSHA256: String?

    init(token: String? = nil, cookie: String? = nil, preSharedKey: String? = nil, certificateSHA256: String? = nil) {
        self.token = token
        self.cookie = cookie
        self.preSharedKey = preSharedKey
        self.certificateSHA256 = certificateSHA256
    }
}
