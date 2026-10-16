import Foundation

/// Samsung Tizen client. Messages are built by `SamsungMessage`; this class only moves them.
final class SamsungClient: TVClient {
    let tv: SavedTV
    var onDisconnect: (@MainActor () -> Void)?
    private(set) var reportedDetails: TVDetails?

    let supportedKeys = Set(RemoteKey.allCases.filter { SamsungMessage.keyCode(for: $0) != nil })
    let holdsKeysNatively = true

    private let credentials: CredentialStore
    private var channel: WebSocketChannel?
    private var listener: Task<Void, Never>?
    private var pendingApps: CheckedContinuation<[SamsungEvent.App], Never>?
    private var apps: [SamsungEvent.App] = []

    init(tv: SavedTV, credentials: CredentialStore = .shared) {
        self.tv = tv
        self.credentials = credentials
    }

    func connect() async throws {
        guard let credential = await credentials.credential(for: tv.id) else { throw TVClientError.notPaired }
        // Always the transport chosen at pairing: a TV paired over TLS that does not answer
        // over TLS is unreachable, never retried in plain text.
        let transport = TransportPolicy.reconnect(requiresSecure: credential.requiresSecure)
        let token = TransportPolicy.mayCarryToken(on: transport) ? credential.token : nil
        if transport == .secure, token?.isEmpty ?? true { throw TVClientError.notPaired }
        let event = try await open(transport, token: token, pinned: credential.certificateSHA256, wait: .seconds(8))
        guard case .connected(let newToken) = event else { throw TVClientError.notPaired }
        if transport == .secure, let newToken, newToken != token {
            var updated = credential
            updated.token = newToken
            try? await credentials.save(updated, for: tv.id)
        }
        listen()
    }

    func startPairing(allowingPlain: Bool) async throws -> PairingStep {
        let info = await deviceInfo()
        reportedDetails = info.map { TVDetails(name: $0.name, model: $0.model, macAddress: $0.macAddress) }
        // Only a TV that says it has no token support (2016-2017 Tizen, port 8001 only) may go
        // in plain text, and only once the user confirms. Unknown info means TLS.
        let decision = TransportPolicy.pairing(reportsLegacyPlainOnly: info?.supportsToken == false, userConfirmedPlain: allowingPlain)
        guard case .use(let transport) = decision else { throw TVClientError.needsPlainConfirmation }

        let event = try await open(transport, token: nil, pinned: nil, wait: .seconds(45))
        switch event {
        case .connected(let token):
            let credential: TVCredential
            if transport == .secure {
                guard let pin = channel?.trust.observedFingerprint, let token, !token.isEmpty else {
                    disconnect()
                    throw TVClientError.unexpectedReply
                }
                credential = TVCredential(token: token, certificateSHA256: pin, requiresSecure: true)
            } else {
                // Legacy models give no token; none would be kept for plain text anyway.
                credential = TVCredential(requiresSecure: false)
            }
            try await credentials.save(credential, for: tv.id)
            listen()
            return .paired
        case .unauthorized, .timedOut:
            disconnect()
            throw TVClientError.rejected
        default:
            disconnect()
            throw TVClientError.unexpectedReply
        }
    }

    func finishPairing(code: String) async throws {
        throw TVClientError.unsupported
    }

    func disconnect() {
        listener?.cancel()
        listener = nil
        channel?.close()
        channel = nil
        pendingApps?.resume(returning: [])
        pendingApps = nil
    }

    func send(_ key: RemoteKey, _ action: KeyAction) async throws {
        guard let code = SamsungMessage.keyCode(for: key) else { throw TVClientError.unsupported }
        try await write(SamsungMessage.key(code, action: action))
    }

    func sendText(_ text: String) async throws {
        try await write(SamsungMessage.text(text))
    }

    func submitText() async throws {
        try await write(SamsungMessage.textEnd)
    }

    func apps() async throws -> [TVShortcut] {
        guard channel != nil else { throw TVClientError.unreachable }
        let list = await withCheckedContinuation { continuation in
            pendingApps = continuation
            Task {
                try? await write(SamsungMessage.installedApps)
                try? await Task.sleep(for: .seconds(5))
                resolveApps([])
            }
        }
        apps = list
        return list.map { TVShortcut(id: $0.id, name: $0.name) }
    }

    func launch(_ app: TVShortcut) async throws {
        let type = apps.first { $0.id == app.id }?.type
        try await write(SamsungMessage.launch(appID: app.id, appType: type))
    }

    /// Many models keep the socket up in standby, where `KEY_POWER` turns them back on.
    func powerOn() async throws {
        try await connect()
        try await send(.power, .click)
    }

    // MARK: - Channel

    private func open(_ transport: TransportPolicy.Transport, token: String?, pinned: String?, wait limit: Duration) async throws -> SamsungEvent {
        disconnect()
        guard let url = SamsungMessage.remoteURL(host: tv.host, transport: transport, token: token) else { throw TVClientError.unreachable }
        let channel = WebSocketChannel(url: url, pinnedCertificate: pinned)
        self.channel = channel
        channel.open()
        return try await withTimeout(limit) {
            while true {
                let event = SamsungEvent(try await channel.receive())
                if event != .other { return event }
            }
        }
    }

    private func listen() {
        guard let channel else { return }
        listener = Task { [weak self] in
            do {
                while !Task.isCancelled {
                    let event = SamsungEvent(try await channel.receive())
                    if case .installedApps(let list) = event { self?.resolveApps(list) }
                }
            } catch {
                guard !Task.isCancelled, let self else { return }
                self.channel = nil
                self.onDisconnect?()
            }
        }
    }

    private func resolveApps(_ list: [SamsungEvent.App]) {
        pendingApps?.resume(returning: list)
        pendingApps = nil
    }

    private func write(_ text: String) async throws {
        guard let channel else { throw TVClientError.unreachable }
        try await channel.send(text)
    }

    private func deviceInfo() async -> SamsungDeviceInfo? {
        guard let url = SamsungMessage.deviceInfoURL(host: tv.host) else { return nil }
        var request = URLRequest(url: url, timeoutInterval: 4)
        request.httpMethod = "GET"
        guard let (data, _) = try? await URLSession.shared.data(for: request) else { return nil }
        return SamsungDeviceInfo(data)
    }
}
