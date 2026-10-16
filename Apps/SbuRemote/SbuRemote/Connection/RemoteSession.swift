import Foundation
import Observation

/// The remote's connection to the current TV: which TV, its client, and how it is going.
@Observable
final class RemoteSession {
    let store: TVStore
    private(set) var status: ConnectionStatus = .noTV
    private(set) var client: (any TVClient)?

    @ObservationIgnored private var hold: (key: RemoteKey, strategy: HoldStrategy, task: Task<Void, Never>?)?
    @ObservationIgnored private let makeClient: @MainActor (SavedTV) -> any TVClient

    init(store: TVStore, makeClient: @escaping @MainActor (SavedTV) -> any TVClient = TVClientFactory.client(for:)) {
        self.store = store
        self.makeClient = makeClient
        status = store.current == nil ? .noTV : .unreachable
    }

    var tv: SavedTV? { store.current }

    /// Connects to the current TV with its saved credential; no pairing again.
    func connect() async {
        guard let tv else {
            disconnect()
            status = .noTV
            return
        }
        status = .connecting
        client?.disconnect()
        let client = makeClient(tv)
        client.onDisconnect = { [weak self] in
            self?.status = .unreachable
        }
        do {
            try await client.connect()
            // The user may have switched TV while this one was connecting.
            guard self.tv?.id == tv.id else {
                client.disconnect()
                return
            }
            self.client = client
            status = .connected
        } catch {
            client.disconnect()
            guard self.tv?.id == tv.id else { return }
            self.client = nil
            status = ConnectionStatus(error)
        }
    }

    func disconnect() {
        client?.onDisconnect = nil
        client?.disconnect()
        client = nil
    }

    /// Saves a newly paired TV and switches to it.
    func add(_ tv: SavedTV) async {
        disconnect()
        store.add(tv)
        await connect()
    }

    func switchTo(_ tv: SavedTV) async {
        guard tv.id != self.tv?.id || status != .connected else { return }
        disconnect()
        store.use(tv)
        await connect()
    }

    // MARK: - Keys

    /// Whether a key does something on this TV right now. Power always does while a TV is
    /// saved: with the TV off it tries to wake it.
    func isAvailable(_ key: RemoteKey) -> Bool {
        if key == .power, tv != nil, !status.acceptsKeys { return status != .connecting }
        return status.acceptsKeys && (client?.supportedKeys.contains(key) ?? false)
    }

    /// One tap: one event to the TV. No limit on taps.
    func press(_ key: RemoteKey) async {
        if key == .power, !status.acceptsKeys {
            await wake()
            return
        }
        await run { try await $0.send(key, .click) }
    }

    /// Turns the TV on: the magic packet to its MAC, then the protocol's own power-on where
    /// the TV listens in standby, then connects. Honest about it: the TV must allow it (#341).
    func wake() async {
        guard let tv else { return }
        status = .connecting
        await WakeOnLAN.wake(tv)
        let client = makeClient(tv)
        try? await client.powerOn()
        client.disconnect()
        // A TV takes a few seconds to bring its network up.
        for delay in [Duration.seconds(2), .seconds(4), .seconds(6)] {
            try? await Task.sleep(for: delay)
            guard self.tv?.id == tv.id else { return }
            await connect()
            if status == .connected { return }
        }
    }

    /// The finger stays on a key: the TV repeats it, or the remote does, until `endHold`.
    func beginHold(_ key: RemoteKey) async {
        guard let client, isAvailable(key) else { return }
        await endHold()
        let strategy = HoldStrategy(key: key, holdsKeysNatively: client.holdsKeysNatively)
        switch strategy {
        case .native:
            hold = (key, strategy, nil)
            await run { try await $0.send(key, .press) }
        case .repeating(let interval):
            let task = Task { [weak self] in
                while !Task.isCancelled {
                    await self?.press(key)
                    try? await Task.sleep(for: interval)
                }
            }
            hold = (key, strategy, task)
        case .none:
            await press(key)
        }
    }

    func endHold() async {
        guard let hold else { return }
        self.hold = nil
        hold.task?.cancel()
        if hold.strategy == .native {
            await run { try await $0.send(hold.key, .release) }
        }
    }

    /// Runs a command on the connected client; a dropped connection shows in the status.
    func run(_ command: (any TVClient) async throws -> Void) async {
        guard let client, status.acceptsKeys else { return }
        do {
            try await command(client)
        } catch TVClientError.unsupported {
            return
        } catch {
            guard client === self.client else { return }
            disconnect()
            status = ConnectionStatus(error)
        }
    }

    func forget(_ tv: SavedTV) async {
        let wasCurrent = tv.id == self.tv?.id
        if wasCurrent { disconnect() }
        await store.forget(tv)
        if wasCurrent { await connect() }
    }
}
