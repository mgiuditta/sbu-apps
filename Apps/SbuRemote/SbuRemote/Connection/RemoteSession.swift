import Foundation
import Observation

/// The remote's connection to the current TV: which TV, its client, and how it is going.
@Observable
final class RemoteSession {
    let store: TVStore
    private(set) var status: ConnectionStatus = .noTV
    private(set) var client: (any TVClient)?

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

    func forget(_ tv: SavedTV) async {
        let wasCurrent = tv.id == self.tv?.id
        if wasCurrent { disconnect() }
        await store.forget(tv)
        if wasCurrent { await connect() }
    }
}
