import Foundation

/// LG webOS client: SSAP requests on the main socket, navigation keys and the pointer on the
/// pointer socket the TV hands out. Messages are built by `LGMessage` and `LGPointerMessage`.
final class LGClient: TVClient {
    let tv: SavedTV
    var onDisconnect: (@MainActor () -> Void)?
    private(set) var reportedDetails: TVDetails?

    let supportedKeys: Set<RemoteKey> = Set(RemoteKey.allCases).subtracting([.replay, .source])
    let holdsKeysNatively = false
    let hasPointer = true

    private let credentials: CredentialStore
    private var channel: WebSocketChannel?
    private var pointer: WebSocketChannel?
    private var listener: Task<Void, Never>?
    /// Requests waiting for their reply, by id; replies cross as text, which is `Sendable`.
    private var pending: [String: CheckedContinuation<String, any Error>] = [:]
    private var nextID = 1
    private var isPlaying = true
    /// What the TV's text field holds, to send only the difference.
    private var fieldText = ""

    init(tv: SavedTV, credentials: CredentialStore = .shared) {
        self.tv = tv
        self.credentials = credentials
    }

    func connect() async throws {
        guard let credential = await credentials.credential(for: tv.id) else { throw TVClientError.notPaired }
        // The transport chosen at pairing, never downgraded (`TransportPolicy`).
        let transport = TransportPolicy.reconnect(requiresSecure: credential.requiresSecure)
        let clientKey = TransportPolicy.mayCarryToken(on: transport) ? credential.token : nil
        if transport == .secure, clientKey == nil { throw TVClientError.notPaired }
        // A legacy TV in plain text keeps no client key, so it shows its prompt again each time.
        let key = try await register(transport, clientKey: clientKey, pinned: credential.certificateSHA256, wait: transport == .secure ? .seconds(8) : .seconds(60))
        guard key != nil else { throw TVClientError.notPaired }
        try await openPointer(pinned: credential.certificateSHA256)
    }

    func startPairing(allowingPlain: Bool) async throws -> PairingStep {
        // TLS first. Only if the TV does not answer on 3001 can it be a first-generation webOS,
        // and only the user's explicit yes on the pairing screen lets it go in plain text.
        let transport: TransportPolicy.Transport
        let key: String?
        if allowingPlain, TransportPolicy.pairing(reportsLegacyPlainOnly: true, userConfirmedPlain: true) == .use(.plain) {
            transport = .plain
            key = try await register(.plain, clientKey: nil, pinned: nil, wait: .seconds(60))
        } else {
            transport = .secure
            do {
                key = try await register(.secure, clientKey: nil, pinned: nil, wait: .seconds(60))
            } catch TVClientError.unreachable {
                disconnect()
                throw TVClientError.needsPlainConfirmation
            }
        }
        guard let key else { throw TVClientError.rejected }
        let credential: TVCredential
        if transport == .secure {
            guard let pin = channel?.trust.observedFingerprint else {
                disconnect()
                throw TVClientError.unexpectedReply
            }
            credential = TVCredential(token: key, certificateSHA256: pin, requiresSecure: true)
        } else {
            credential = TVCredential(requiresSecure: false)
        }
        try await credentials.save(credential, for: tv.id)
        reportedDetails = await details()
        try await openPointer(pinned: credential.certificateSHA256)
        return .paired
    }

    func finishPairing(code: String) async throws {
        throw TVClientError.unsupported
    }

    func disconnect() {
        listener?.cancel()
        listener = nil
        channel?.close()
        channel = nil
        pointer?.close()
        pointer = nil
        for continuation in pending.values {
            continuation.resume(throwing: TVClientError.unreachable)
        }
        pending = [:]
    }

    func send(_ key: RemoteKey, _ action: KeyAction) async throws {
        // LG has no press and release: a held key repeats as clicks, so only clicks go out.
        guard action == .click else { return }
        if let name = LGPointerMessage.buttonName(for: key) {
            try await writePointer(LGPointerMessage.button(name))
        } else if let uri = LGMessage.uri(for: key) {
            _ = try await request(uri)
        } else if key == .mute {
            let muted = try await request(LGMessage.URI.audioStatus).isMuted ?? false
            _ = try await request(LGMessage.URI.setMute, payload: ["mute": !muted])
        } else if key == .playPause {
            // webOS has separate play and pause; the remote alternates them.
            isPlaying.toggle()
            _ = try await request(isPlaying ? LGMessage.URI.play : LGMessage.URI.pause)
        } else {
            throw TVClientError.unsupported
        }
    }

    func movePointer(dx: Double, dy: Double) async throws {
        try await writePointer(LGPointerMessage.move(dx: dx, dy: dy))
    }

    func clickPointer() async throws {
        try await writePointer(LGPointerMessage.click)
    }

    func sendText(_ text: String) async throws {
        let edit = TextEdit(from: fieldText, to: text)
        if edit.deleteCount > 0 {
            _ = try await request(LGMessage.URI.deleteCharacters, payload: ["count": edit.deleteCount])
        }
        if !edit.insert.isEmpty {
            _ = try await request(LGMessage.URI.insertText, payload: ["text": edit.insert, "replace": 0])
        }
        fieldText = text
    }

    func submitText() async throws {
        _ = try await request(LGMessage.URI.sendEnter)
        fieldText = ""
    }

    func apps() async throws -> [TVShortcut] {
        try await request(LGMessage.URI.launchPoints).launchPoints
    }

    func launch(_ app: TVShortcut) async throws {
        _ = try await request(LGMessage.URI.launch, payload: ["id": app.id])
    }

    func inputs() async throws -> [TVShortcut] {
        try await request(LGMessage.URI.inputs).inputs
    }

    func switchInput(_ input: TVShortcut) async throws {
        _ = try await request(LGMessage.URI.switchInput, payload: ["inputId": input.id])
    }

    // MARK: - Sockets

    /// Registers and returns the client key; `nil` when the TV said no.
    private func register(_ transport: TransportPolicy.Transport, clientKey: String?, pinned: String?, wait limit: Duration) async throws -> String? {
        disconnect()
        guard let url = LGMessage.url(host: tv.host, secure: transport == .secure) else { throw TVClientError.unreachable }
        let channel = WebSocketChannel(url: url, pinnedCertificate: pinned)
        self.channel = channel
        channel.open()
        try await channel.send(LGMessage.register(clientKey: clientKey))
        let key: String? = try await withTimeout(limit) {
            while true {
                guard let reply = LGReply(try await channel.receive()), reply.id == LGMessage.registerID else { continue }
                if let key = reply.clientKey { return key }
                if reply.isError { return nil }
            }
        }
        if key != nil { listen() }
        return key
    }

    private func openPointer(pinned: String?) async throws {
        guard let url = try await request(LGMessage.URI.pointerSocket).socketPath else { throw TVClientError.unexpectedReply }
        // The pointer socket of a TLS TV must be TLS too, with the same certificate.
        if pinned != nil, url.scheme != "wss" { throw TVClientError.unexpectedReply }
        let pointer = WebSocketChannel(url: url, pinnedCertificate: pinned)
        pointer.open()
        self.pointer = pointer
    }

    private func listen() {
        guard let channel else { return }
        listener = Task { [weak self] in
            do {
                while !Task.isCancelled {
                    let text = try await channel.receive()
                    guard let reply = LGReply(text), let id = reply.id else { continue }
                    self?.resolve(id: id, text: text, isError: reply.isError)
                }
            } catch {
                guard !Task.isCancelled, let self else { return }
                self.disconnect()
                self.onDisconnect?()
            }
        }
    }

    private func resolve(id: String, text: String, isError: Bool) {
        guard let continuation = pending.removeValue(forKey: id) else { return }
        if isError {
            continuation.resume(throwing: TVClientError.unexpectedReply)
        } else {
            continuation.resume(returning: text)
        }
    }

    private func request(_ uri: String, payload: [String: Any]? = nil) async throws -> LGReply {
        guard let channel else { throw TVClientError.unreachable }
        let id = "sbu_\(nextID)"
        nextID += 1
        let text = LGMessage.request(id: id, uri: uri, payload: payload)
        let reply = try await withCheckedThrowingContinuation { continuation in
            pending[id] = continuation
            Task {
                do {
                    try await channel.send(text)
                    try await Task.sleep(for: .seconds(5))
                    self.resolveTimeout(id: id)
                } catch {
                    self.resolveTimeout(id: id)
                }
            }
        }
        guard let parsed = LGReply(reply) else { throw TVClientError.unexpectedReply }
        return parsed
    }

    private func resolveTimeout(id: String) {
        pending.removeValue(forKey: id)?.resume(throwing: TVClientError.unreachable)
    }

    private func writePointer(_ text: String) async throws {
        guard let pointer else { throw TVClientError.unreachable }
        try await pointer.send(text)
    }

    private func details() async -> TVDetails {
        let system = try? await request(LGMessage.URI.systemInfo)
        let network = try? await request(LGMessage.URI.networkInfo)
        return TVDetails(name: nil, model: system?.modelName, macAddress: network?.macAddress)
    }
}
