import Foundation

/// One key to the last TV used, for Shortcuts, Siri and the widget: connect with the saved
/// credential, send, let go. Nothing leaves the home network.
enum RemoteCommand {
    enum Failure: Error {
        case noTV
        case unreachable
    }

    /// Sends the key and returns the TV's name for the reply.
    @discardableResult
    static func send(_ key: RemoteKey, store: TVStore = TVStore()) async throws -> String {
        store.reload()
        guard let tv = store.current else { throw Failure.noTV }
        let client = TVClientFactory.client(for: tv)
        defer { client.disconnect() }
        do {
            try await client.connect()
            try await client.send(key, .click)
        } catch {
            // A TV that is off does not answer: power tries to wake it instead.
            guard key == .power else { throw Failure.unreachable }
            await WakeOnLAN.wake(tv)
            try? await client.powerOn()
        }
        return tv.name
    }
}
