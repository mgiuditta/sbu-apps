import CryptoKit
import Foundation

/// The secret that proves to an Android TV that the user typed the code it shows.
///
/// SHA-256 over the client's RSA modulus and exponent, the TV's modulus and exponent, and the
/// last 4 hex characters of the code. The first 2 characters are the hash's first byte, so a
/// typo is caught here before anything goes to the TV.
nonisolated enum PairingSecret {
    static func secret(client: RSAPublicKeyNumbers, server: RSAPublicKeyNumbers, code: String) -> Data? {
        let code = code.trimmingCharacters(in: .whitespaces).uppercased()
        guard code.count == PoloMessage.codeLength,
              let check = UInt8(String(code.prefix(2)), radix: 16),
              let nonce = Data(hexString: String(code.dropFirst(2)))
        else { return nil }
        var hash = SHA256()
        hash.update(data: client.modulus)
        hash.update(data: client.exponent)
        hash.update(data: server.modulus)
        hash.update(data: server.exponent)
        hash.update(data: nonce)
        let digest = Data(hash.finalize())
        guard digest.first == check else { return nil }
        return digest
    }
}
