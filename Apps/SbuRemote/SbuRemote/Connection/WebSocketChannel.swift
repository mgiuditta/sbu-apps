import Foundation

/// A text WebSocket to a TV (Samsung, LG), with the TV's self-signed certificate pinned.
final class WebSocketChannel {
    let trust: LocalTrustDelegate
    private let session: URLSession
    private let task: URLSessionWebSocketTask

    init(url: URL, pinnedCertificate: String?) {
        trust = LocalTrustDelegate(host: url.host() ?? "", pinned: pinnedCertificate)
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 10
        session = URLSession(configuration: configuration, delegate: trust, delegateQueue: nil)
        task = session.webSocketTask(with: url)
        task.maximumMessageSize = 4 * 1024 * 1024
    }

    func open() {
        task.resume()
    }

    func send(_ text: String) async throws {
        do {
            try await task.send(.string(text))
        } catch {
            throw TVClientError.unreachable
        }
    }

    /// The next message, as text.
    func receive() async throws -> String {
        let message: URLSessionWebSocketTask.Message
        do {
            message = try await task.receive()
        } catch {
            throw TVClientError.unreachable
        }
        switch message {
        case .string(let text):
            return text
        case .data(let data):
            return String(decoding: data, as: UTF8.self)
        @unknown default:
            throw TVClientError.unexpectedReply
        }
    }

    func close() {
        task.cancel(with: .goingAway, reason: nil)
        session.invalidateAndCancel()
    }
}
