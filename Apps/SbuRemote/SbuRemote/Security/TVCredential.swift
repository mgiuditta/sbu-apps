import Foundation

/// What a TV gave Sbu Remote at pairing, kept in the Keychain under the TV's id.
nonisolated struct TVCredential: Codable, Equatable, Sendable {
    /// Samsung token or LG client key. Only ever sent over TLS.
    var token: String?
    /// Sony: the `auth` cookie from PIN pairing.
    var cookie: String?
    /// Sony: the pre-shared key set under Controllo IP.
    var preSharedKey: String?
    /// SHA-256 of the TV's TLS certificate, seen at pairing: later connections must show the same one.
    var certificateSHA256: String?
    /// The TV was paired over TLS, so it is only ever reached over TLS (`TransportPolicy`).
    /// Separate from the pin: a missing pin never means plain text.
    var requiresSecure: Bool

    init(token: String? = nil, cookie: String? = nil, preSharedKey: String? = nil, certificateSHA256: String? = nil, requiresSecure: Bool = true) {
        self.token = token
        self.cookie = cookie
        self.preSharedKey = preSharedKey
        self.certificateSHA256 = certificateSHA256
        self.requiresSecure = requiresSecure
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        token = try container.decodeIfPresent(String.self, forKey: .token)
        cookie = try container.decodeIfPresent(String.self, forKey: .cookie)
        preSharedKey = try container.decodeIfPresent(String.self, forKey: .preSharedKey)
        certificateSHA256 = try container.decodeIfPresent(String.self, forKey: .certificateSHA256)
        // An item without the flag is treated as secure: the safe side.
        requiresSecure = try container.decodeIfPresent(Bool.self, forKey: .requiresSecure) ?? true
    }
}
