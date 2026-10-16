import Foundation
import Security

/// The phone's identity for Android TV: an RSA 2048 key generated in the Keychain and a
/// self-signed certificate over it, made once and reused for every Android TV.
///
/// The private key never leaves the Keychain; TLS uses it through the `SecIdentity`.
actor AndroidTVIdentityStore {
    enum Failure: Error, Equatable {
        case status(OSStatus)
        case keyGeneration
        case signing
        case certificate
    }

    /// What TLS needs and what pairing hashes.
    struct Identity: @unchecked Sendable {
        // SecIdentity is an immutable Security object, safe to use from any thread.
        let secIdentity: SecIdentity
        let publicKey: RSAPublicKeyNumbers
    }

    static let shared = AndroidTVIdentityStore(accessGroup: AppGroup.keychainAccessGroup)

    private let label = "Sbu Remote Android TV"
    private let keyTag = Data("dev.sbu.remote.androidtv.key".utf8)
    private let accessGroup: String?

    init(accessGroup: String?) {
        self.accessGroup = accessGroup
    }

    /// The saved identity, or a new one when there is none yet.
    func identity() throws -> Identity {
        if let existing = try savedIdentity() { return existing }
        return try makeIdentity()
    }

    private func savedIdentity() throws -> Identity? {
        var query: [String: Any] = [
            kSecClass as String: kSecClassIdentity,
            kSecAttrLabel as String: label,
            kSecReturnRef as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]
        if let accessGroup { query[kSecAttrAccessGroup as String] = accessGroup }
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        switch status {
        case errSecSuccess:
            guard let result, CFGetTypeID(result) == SecIdentityGetTypeID() else { return nil }
            let identity = result as! SecIdentity // Type checked on the line above.
            return try Identity(secIdentity: identity, publicKey: publicKeyNumbers(of: identity))
        case errSecItemNotFound:
            return nil
        default:
            throw Failure.status(status)
        }
    }

    private func makeIdentity() throws -> Identity {
        var keyAttributes: [String: Any] = [
            kSecAttrIsPermanent as String: true,
            kSecAttrApplicationTag as String: keyTag,
            kSecAttrLabel as String: label,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
        ]
        if let accessGroup { keyAttributes[kSecAttrAccessGroup as String] = accessGroup }
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeySizeInBits as String: 2048,
            kSecPrivateKeyAttrs as String: keyAttributes,
        ]
        var error: Unmanaged<CFError>?
        guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error),
              let publicKey = SecKeyCopyPublicKey(privateKey),
              let pkcs1 = SecKeyCopyExternalRepresentation(publicKey, &error) as Data?
        else { throw Failure.keyGeneration }

        let now = Date.now
        var serial = Data(count: 8)
        serial[0] = 0x01
        for index in 1..<serial.count { serial[index] = UInt8.random(in: 0...255) }
        let tbs = SelfSignedCertificate.tbs(
            publicKeyPKCS1: pkcs1,
            commonName: "Sbu Remote",
            serial: serial,
            notBefore: now.addingTimeInterval(-86_400),
            notAfter: now.addingTimeInterval(20 * 365 * 86_400)
        )
        guard let signature = SecKeyCreateSignature(privateKey, .rsaSignatureMessagePKCS1v15SHA256, tbs as CFData, &error) as Data? else {
            throw Failure.signing
        }
        let der = SelfSignedCertificate.certificate(tbs: tbs, signature: signature)
        guard let certificate = SecCertificateCreateWithData(nil, der as CFData) else { throw Failure.certificate }

        var add: [String: Any] = [
            kSecClass as String: kSecClassCertificate,
            kSecValueRef as String: certificate,
            kSecAttrLabel as String: label,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
        ]
        if let accessGroup { add[kSecAttrAccessGroup as String] = accessGroup }
        let status = SecItemAdd(add as CFDictionary, nil)
        guard status == errSecSuccess || status == errSecDuplicateItem else { throw Failure.status(status) }

        guard let identity = try savedIdentity() else { throw Failure.certificate }
        return identity
    }

    private func publicKeyNumbers(of identity: SecIdentity) throws -> RSAPublicKeyNumbers {
        var certificate: SecCertificate?
        let status = SecIdentityCopyCertificate(identity, &certificate)
        guard status == errSecSuccess, let certificate, let key = SecCertificateCopyKey(certificate),
              let pkcs1 = SecKeyCopyExternalRepresentation(key, nil) as Data?,
              let numbers = RSAPublicKeyNumbers(pkcs1: pkcs1)
        else { throw Failure.certificate }
        return numbers
    }
}
