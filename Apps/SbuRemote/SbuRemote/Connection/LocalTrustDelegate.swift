import Foundation
import os
import Security

/// Accepts the self-signed certificate of one TV over HTTPS and WSS, pinned at pairing.
///
/// Only for the TV's own address on the local network (ADR-0007). Before pairing any
/// certificate is accepted and remembered in `observedFingerprint`, which the client saves.
nonisolated final class LocalTrustDelegate: NSObject, URLSessionDelegate, Sendable {
    private let host: String
    private let pinned: String?
    private let observed = OSAllocatedUnfairLock<String?>(initialState: nil)

    init(host: String, pinned: String?) {
        self.host = host
        self.pinned = pinned
    }

    /// SHA-256 of the certificate the TV showed on the last connection.
    var observedFingerprint: String? { observed.withLock { $0 } }

    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              challenge.protectionSpace.host == host,
              let trust = challenge.protectionSpace.serverTrust,
              let leaf = (SecTrustCopyCertificateChain(trust) as? [SecCertificate])?.first
        else {
            return (.performDefaultHandling, nil)
        }
        let fingerprint = CertificatePin.fingerprint(of: SecCertificateCopyData(leaf) as Data)
        observed.withLock { $0 = fingerprint }
        guard CertificatePin.accepts(observed: fingerprint, pinned: pinned) else {
            return (.cancelAuthenticationChallenge, nil)
        }
        return (.useCredential, URLCredential(trust: trust))
    }
}
