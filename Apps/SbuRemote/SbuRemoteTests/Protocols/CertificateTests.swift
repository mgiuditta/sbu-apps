import Foundation
import Security
import Testing
@testable import SbuRemote

struct CertificateTests {
    @Test(arguments: [
        ("1.2.840.113549.1.1.11", [0x06, 0x09, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01, 0x0b]),
        ("2.5.4.3", [0x06, 0x03, 0x55, 0x04, 0x03]),
    ])
    func objectIdentifiers(dotted: String, bytes: [UInt8]) {
        #expect([UInt8](DER.objectIdentifier(dotted)) == bytes)
    }

    @Test func integersGetALeadingZeroWhenTheTopBitIsSet() {
        #expect([UInt8](DER.integer(Data([0x80]))) == [0x02, 0x02, 0x00, 0x80])
        #expect([UInt8](DER.integer(Data([0x00, 0x00, 0x7f]))) == [0x02, 0x01, 0x7f])
        #expect([UInt8](DER.integer(2)) == [0x02, 0x01, 0x02])
    }

    @Test func longLengths() {
        #expect([UInt8](DER.length(0x7f)) == [0x7f])
        #expect([UInt8](DER.length(0x80)) == [0x81, 0x80])
        #expect([UInt8](DER.length(0x0123)) == [0x82, 0x01, 0x23])
    }

    @Test func utcTime() {
        let date = Date(timeIntervalSince1970: 1_792_108_800) // 2026-10-16 00:00:00 UTC
        #expect(String(decoding: DER.utcTime(date).dropFirst(2), as: UTF8.self) == "261016000000Z")
    }

    @Test func pkcs1NumbersLoseTheirLeadingZero() throws {
        let der = DER.sequence(DER.integer(Data([0x00, 0xc1, 0x02])), DER.integer(Data([0x01, 0x00, 0x01])))
        let numbers = try #require(RSAPublicKeyNumbers(pkcs1: der))
        #expect(numbers.modulus == Data([0xc1, 0x02]))
        #expect(numbers.exponent == Data([0x01, 0x00, 0x01]))
    }

    /// The certificate built by hand parses as X.509 and its signature checks out with the key.
    @Test func selfSignedCertificateIsValidX509() throws {
        let attributes: [String: Any] = [kSecAttrKeyType as String: kSecAttrKeyTypeRSA, kSecAttrKeySizeInBits as String: 2048]
        let privateKey = try #require(SecKeyCreateRandomKey(attributes as CFDictionary, nil))
        let publicKey = try #require(SecKeyCopyPublicKey(privateKey))
        let pkcs1 = try #require(SecKeyCopyExternalRepresentation(publicKey, nil) as Data?)
        let tbs = SelfSignedCertificate.tbs(publicKeyPKCS1: pkcs1, commonName: "Sbu Remote", serial: Data([0x01, 0x02]), notBefore: .now, notAfter: .now.addingTimeInterval(86_400))
        let signature = try #require(SecKeyCreateSignature(privateKey, .rsaSignatureMessagePKCS1v15SHA256, tbs as CFData, nil) as Data?)
        let der = SelfSignedCertificate.certificate(tbs: tbs, signature: signature)

        let certificate = try #require(SecCertificateCreateWithData(nil, der as CFData))
        #expect(SecCertificateCopySubjectSummary(certificate) as String? == "Sbu Remote")
        let certificateKey = try #require(SecCertificateCopyKey(certificate))
        #expect(SecKeyVerifySignature(certificateKey, .rsaSignatureMessagePKCS1v15SHA256, tbs as CFData, signature as CFData, nil))
        #expect(RSAPublicKeyNumbers(pkcs1: try #require(SecKeyCopyExternalRepresentation(certificateKey, nil) as Data?)) == RSAPublicKeyNumbers(pkcs1: pkcs1))
    }
}
