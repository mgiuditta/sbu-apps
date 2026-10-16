/// Whether a TV is reached over TLS (`wss://`) or in plain text (`ws://`), decided once at
/// pairing and never downgraded on its own.
///
/// Plain text exists only for legacy models that have no TLS port (Samsung before token
/// support, the first webOS), and only after the user confirms it on the pairing screen.
/// Device info read over HTTP before pairing is unauthenticated, so it can ask for that
/// confirmation but never skip it. A missing certificate pin never means plain text.
nonisolated enum TransportPolicy {
    enum Transport: Equatable, Sendable {
        case secure
        case plain
    }

    enum Decision: Equatable, Sendable {
        case use(Transport)
        /// Ask the user before connecting in plain text.
        case askUserForPlain
    }

    /// The transport for pairing.
    /// - Parameters:
    ///   - reportsLegacyPlainOnly: The TV said it has no TLS (Samsung `TokenAuthSupport` false),
    ///     or a TLS attempt failed and the TV may be a legacy model. `false` when unknown.
    ///   - userConfirmedPlain: The user chose "connect without encryption" on the pairing screen.
    static func pairing(reportsLegacyPlainOnly: Bool, userConfirmedPlain: Bool) -> Decision {
        guard reportsLegacyPlainOnly else { return .use(.secure) }
        return userConfirmedPlain ? .use(.plain) : .askUserForPlain
    }

    /// The transport for every later connection: what pairing chose, with no fallback.
    /// A TV paired over TLS that does not answer over TLS is unreachable, not plain.
    static func reconnect(requiresSecure: Bool) -> Transport {
        requiresSecure ? .secure : .plain
    }

    /// Whether a token or client key may travel on a transport: never in plain text.
    static func mayCarryToken(on transport: Transport) -> Bool {
        transport == .secure
    }
}
