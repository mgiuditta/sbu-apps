import Foundation

/// Modulus and exponent of an RSA public key, as unsigned big-endian bytes without leading zeros.
nonisolated struct RSAPublicKeyNumbers: Equatable, Sendable {
    let modulus: Data
    let exponent: Data

    /// Reads a PKCS#1 `RSAPublicKey` (`SEQUENCE { INTEGER n, INTEGER e }`), the form
    /// `SecKeyCopyExternalRepresentation` gives for RSA public keys.
    init?(pkcs1 der: Data) {
        var reader = DERReader(der)
        guard let sequence = reader.read(tag: 0x30) else { return nil }
        var inner = DERReader(sequence)
        guard let modulus = inner.read(tag: 0x02), let exponent = inner.read(tag: 0x02) else { return nil }
        self.modulus = Self.stripped(modulus)
        self.exponent = Self.stripped(exponent)
    }

    init(modulus: Data, exponent: Data) {
        self.modulus = Self.stripped(modulus)
        self.exponent = Self.stripped(exponent)
    }

    private static func stripped(_ integer: Data) -> Data {
        let trimmed = integer.drop { $0 == 0 }
        return trimmed.isEmpty ? Data([0]) : Data(trimmed)
    }
}
