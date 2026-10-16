import Foundation

/// Android TV and Google TV client (Remote v2). Pairing on 6467 with the code the TV shows,
/// then commands on 6466; the same client certificate on both, the TV's certificate pinned.
final class AndroidTVClient: TVClient {
    static let pairingPort: UInt16 = 6467
    static let remotePort: UInt16 = 6466

    let tv: SavedTV
    var onDisconnect: (@MainActor () -> Void)?
    let reportedDetails: TVDetails? = nil

    let supportedKeys = Set(RemoteKey.allCases)
    let holdsKeysNatively = true

    private let credentials: CredentialStore
    private let identities: AndroidTVIdentityStore
    private var channel: TLSChannel?
    private var pairing: TLSChannel?
    private var pairingIdentity: AndroidTVIdentityStore.Identity?
    private var listener: Task<Void, Never>?
    private var imeCounter = 0
    private var fieldCounter = 0

    init(tv: SavedTV, credentials: CredentialStore = .shared, identities: AndroidTVIdentityStore = .shared) {
        self.tv = tv
        self.credentials = credentials
        self.identities = identities
    }

    func connect() async throws {
        guard let pin = await credentials.credential(for: tv.id)?.certificateSHA256 else { throw TVClientError.notPaired }
        let identity = try await identities.identity()
        disconnect()
        let channel = TLSChannel(host: tv.host, port: Self.remotePort, identity: identity, pinned: pin)
        channel.onClose = { [weak self] in
            self?.channel = nil
            self?.onDisconnect?()
        }
        self.channel = channel
        try await channel.open()
        listen(on: channel)
    }

    func startPairing(allowingPlain: Bool) async throws -> PairingStep {
        let identity = try await identities.identity()
        pairing?.close()
        let pairing = TLSChannel(host: tv.host, port: Self.pairingPort, identity: identity, pinned: nil)
        self.pairing = pairing
        pairingIdentity = identity
        try await pairing.open()
        try await pairing.send(PoloMessage.pairingRequest(clientName: "Sbu Remote"))
        try await expect(.pairingRequestAck, on: pairing)
        try await pairing.send(PoloMessage.options())
        try await expect(.options, on: pairing)
        try await pairing.send(PoloMessage.configuration())
        try await expect(.configurationAck, on: pairing)
        return .code(length: PoloMessage.codeLength, isHexadecimal: true)
    }

    func finishPairing(code: String) async throws {
        guard let pairing, let identity = pairingIdentity, let server = pairing.serverCertificate, let serverKey = server.publicKey else {
            throw TVClientError.notPaired
        }
        // A typo fails the code's own check digit here, before the TV sees it.
        guard let secret = PairingSecret.secret(client: identity.publicKey, server: serverKey, code: code) else {
            throw TVClientError.rejected
        }
        try await pairing.send(PoloMessage.secret(secret))
        try await expect(.secretAck, on: pairing)
        try await credentials.save(TVCredential(certificateSHA256: server.fingerprint, requiresSecure: true), for: tv.id)
        pairing.close()
        self.pairing = nil
        pairingIdentity = nil
        try await connect()
    }

    func disconnect() {
        listener?.cancel()
        listener = nil
        channel?.onClose = nil
        channel?.close()
        channel = nil
    }

    func send(_ key: RemoteKey, _ action: KeyAction) async throws {
        guard let code = AndroidKeyCode.code(for: key) else { throw TVClientError.unsupported }
        try await write(AndroidRemoteMessage.key(code, action: action))
    }

    func sendText(_ text: String) async throws {
        try await write(AndroidRemoteMessage.text(text, imeCounter: imeCounter, fieldCounter: fieldCounter))
    }

    func submitText() async throws {
        try await write(AndroidRemoteMessage.key(AndroidKeyCode.enter, action: .click))
    }

    func apps() async throws -> [TVShortcut] {
        AndroidAppLinks.all
    }

    func launch(_ app: TVShortcut) async throws {
        try await write(AndroidRemoteMessage.appLink(app.id))
    }

    /// Works when the TV keeps the remote service up in standby (model dependent).
    func powerOn() async throws {
        if channel == nil { try await connect() }
        try await write(AndroidRemoteMessage.key(AndroidKeyCode.wakeUp, action: .click))
    }

    // MARK: - Channel

    private func expect(_ kind: PoloReply.Kind, on channel: TLSChannel) async throws {
        let reply = try await withTimeout(.seconds(10)) {
            while true {
                if let reply = PoloReply(try await channel.receive()) { return reply }
            }
        }
        guard reply.isOK else { throw TVClientError.rejected }
        guard reply.kind == kind else { throw TVClientError.unexpectedReply }
    }

    private func listen(on channel: TLSChannel) {
        listener = Task { [weak self] in
            while !Task.isCancelled {
                guard let data = try? await channel.receive() else { return }
                await self?.handle(AndroidRemoteEvent(data), on: channel)
            }
        }
    }

    private func handle(_ event: AndroidRemoteEvent, on channel: TLSChannel) async {
        switch event {
        case .configure:
            try? await channel.send(AndroidRemoteMessage.configure())
        case .setActive:
            try? await channel.send(AndroidRemoteMessage.setActive())
        case .ping(let value):
            try? await channel.send(AndroidRemoteMessage.pingResponse(value))
        case .ime(let ime, let field):
            imeCounter = ime
            fieldCounter = field
        case .error, .other:
            break
        }
    }

    private func write(_ message: Data) async throws {
        guard let channel else { throw TVClientError.unreachable }
        try await channel.send(message)
    }
}
