import CryptoKit
import Foundation

/// Trust for TVs, which show self-signed certificates: the first one seen at pairing is
/// remembered, and later connections must show the same one (trust on first use).
nonisolated enum CertificatePin {
    /// Lowercase hex SHA-256 of a DER certificate.
    static func fingerprint(of certificateDER: Data) -> String {
        Data(SHA256.hash(data: certificateDER)).hexString
    }

    /// Whether a certificate with `observed` fingerprint is accepted when `pinned` was kept at pairing.
    static func accepts(observed: String, pinned: String?) -> Bool {
        guard let pinned else { return true }
        return observed == pinned
    }
}
