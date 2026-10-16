import Foundation
import Network
import os
import Security

/// A TCP connection with TLS that shows the phone's client certificate and pins the TV's
/// self-signed one (Android TV, ports 6466 and 6467). Messages are length-prefixed protobuf.
final class TLSChannel {
    private let connection: NWConnection
    private let observed = OSAllocatedUnfairLock<ServerCertificate?>(initialState: nil)
    private var buffer = Data()
    private var frames: [Data] = []
    private var waiting: CheckedContinuation<Data, any Error>?
    private var failed = false
    var onClose: (@MainActor () -> Void)?

    /// The TV's certificate as seen in the handshake.
    struct ServerCertificate: Sendable {
        let fingerprint: String
        let publicKey: RSAPublicKeyNumbers?
    }

    init(host: String, port: UInt16, identity: AndroidTVIdentityStore.Identity, pinned: String?) {
        let tls = NWProtocolTLS.Options()
        let options = tls.securityProtocolOptions
        if let secIdentity = sec_identity_create(identity.secIdentity) {
            sec_protocol_options_set_local_identity(options, secIdentity)
        }
        let observed = observed
        sec_protocol_options_set_verify_block(options, { _, trust, complete in
            let secTrust = sec_trust_copy_ref(trust).takeRetainedValue()
            guard let leaf = (SecTrustCopyCertificateChain(secTrust) as? [SecCertificate])?.first else {
                complete(false)
                return
            }
            let fingerprint = CertificatePin.fingerprint(of: SecCertificateCopyData(leaf) as Data)
            let publicKey = SecCertificateCopyKey(leaf)
                .flatMap { SecKeyCopyExternalRepresentation($0, nil) as Data? }
                .flatMap(RSAPublicKeyNumbers.init(pkcs1:))
            observed.withLock { $0 = ServerCertificate(fingerprint: fingerprint, publicKey: publicKey) }
            complete(CertificatePin.accepts(observed: fingerprint, pinned: pinned))
        }, .main)
        let parameters = NWParameters(tls: tls, tcp: NWProtocolTCP.Options())
        connection = NWConnection(host: .init(host), port: .init(integerLiteral: port), using: parameters)
    }

    var serverCertificate: ServerCertificate? { observed.withLock { $0 } }

    /// Opens the connection and waits for the TLS handshake.
    func open(timeout: Duration = .seconds(8)) async throws {
        let nwConnection = connection
        let states = AsyncStream<NWConnection.State> { continuation in
            nwConnection.stateUpdateHandler = { state in
                continuation.yield(state)
                if case .cancelled = state { continuation.finish() }
            }
        }
        nwConnection.start(queue: .main)
        try await withTimeout(timeout) {
            for await state in states {
                switch state {
                case .ready:
                    return
                case .waiting(let error), .failed(let error):
                    nwConnection.cancel()
                    throw LocalNetworkAccess.isDenied(error) ? TVClientError.localNetworkDenied : TVClientError.unreachable
                case .cancelled:
                    throw TVClientError.unreachable
                default:
                    continue
                }
            }
            throw TVClientError.unreachable
        }
        connection.stateUpdateHandler = { [weak self] state in
            switch state {
            case .failed, .cancelled:
                Task { @MainActor in self?.closed() }
            default:
                break
            }
        }
        receiveLoop()
    }

    func send(_ message: Data) async throws {
        let framed = ProtobufWriter.delimited(message)
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, any Error>) in
            connection.send(content: framed, completion: .contentProcessed { error in
                if error == nil {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: TVClientError.unreachable)
                }
            })
        }
    }

    /// The next whole message from the TV.
    func receive() async throws -> Data {
        if !frames.isEmpty { return frames.removeFirst() }
        if failed { throw TVClientError.unreachable }
        return try await withCheckedThrowingContinuation { continuation in
            waiting = continuation
        }
    }

    func close() {
        connection.stateUpdateHandler = nil
        connection.cancel()
        fail()
    }

    private func receiveLoop() {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 64 * 1024) { [weak self] content, _, isComplete, error in
            Task { @MainActor in
                guard let self else { return }
                if let content { self.received(content) }
                if isComplete || error != nil {
                    self.closed()
                } else {
                    self.receiveLoop()
                }
            }
        }
    }

    private func received(_ content: Data) {
        buffer.append(content)
        frames.append(contentsOf: ProtobufReader.takeDelimited(from: &buffer))
        if let waiting, !frames.isEmpty {
            self.waiting = nil
            waiting.resume(returning: frames.removeFirst())
        }
    }

    private func closed() {
        guard !failed else { return }
        fail()
        onClose?()
    }

    private func fail() {
        failed = true
        waiting?.resume(throwing: TVClientError.unreachable)
        waiting = nil
    }
}
