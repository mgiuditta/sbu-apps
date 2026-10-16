import Foundation

/// A self-signed X.509 v3 certificate for the Android TV client identity, built on the device.
///
/// Android TV Remote v2 identifies the phone by the certificate it shows in TLS: the TV trusts
/// it once the user typed the pairing code. No certificate authority is involved; nothing is
/// fetched. The RSA key is generated in the Keychain (`AndroidTVIdentityStore`).
nonisolated enum SelfSignedCertificate {
    static let sha256WithRSAEncryption = "1.2.840.113549.1.1.11"
    static let rsaEncryption = "1.2.840.113549.1.1.1"
    static let commonName = "2.5.4.3"

    /// The part of the certificate that gets signed.
    static func tbs(publicKeyPKCS1: Data, commonName name: String, serial: Data, notBefore: Date, notAfter: Date) -> Data {
        let algorithm = DER.sequence(DER.objectIdentifier(sha256WithRSAEncryption), DER.null)
        let distinguishedName = DER.sequence(DER.set(DER.sequence(DER.objectIdentifier(commonName), DER.utf8String(name))))
        let validity = DER.sequence(DER.utcTime(notBefore), DER.utcTime(notAfter))
        let publicKeyInfo = DER.sequence(
            DER.sequence(DER.objectIdentifier(rsaEncryption), DER.null),
            DER.bitString(publicKeyPKCS1)
        )
        return DER.sequence(
            DER.explicit(0, DER.integer(2)),
            DER.integer(serial),
            algorithm,
            distinguishedName,
            validity,
            distinguishedName,
            publicKeyInfo
        )
    }

    /// The whole certificate: what was signed, the algorithm, the signature.
    static func certificate(tbs: Data, signature: Data) -> Data {
        DER.sequence(
            tbs,
            DER.sequence(DER.objectIdentifier(sha256WithRSAEncryption), DER.null),
            DER.bitString(signature)
        )
    }
}
