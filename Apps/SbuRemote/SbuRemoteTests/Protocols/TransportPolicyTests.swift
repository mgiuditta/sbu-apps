import Foundation
import Testing
@testable import SbuRemote

struct TransportPolicyTests {
    @Test(arguments: [false, true])
    func aTVThatReportsTLSOrSaysNothingPairsOverTLS(userConfirmedPlain: Bool) {
        #expect(TransportPolicy.pairing(reportsLegacyPlainOnly: false, userConfirmedPlain: userConfirmedPlain) == .use(.secure))
    }

    @Test func aLegacyTVAsksTheUserBeforePlainText() {
        #expect(TransportPolicy.pairing(reportsLegacyPlainOnly: true, userConfirmedPlain: false) == .askUserForPlain)
    }

    @Test func plainTextOnlyAfterTheUserConfirms() {
        #expect(TransportPolicy.pairing(reportsLegacyPlainOnly: true, userConfirmedPlain: true) == .use(.plain))
    }

    @Test func reconnectNeverDowngradesATVPairedOverTLS() {
        #expect(TransportPolicy.reconnect(requiresSecure: true) == .secure)
        #expect(TransportPolicy.reconnect(requiresSecure: false) == .plain)
    }

    @Test func tokensOnlyTravelOverTLS() {
        #expect(TransportPolicy.mayCarryToken(on: .secure))
        #expect(!TransportPolicy.mayCarryToken(on: .plain))
    }

    @Test func aMissingPinStillMeansTLS() {
        let credential = TVCredential(token: "t", certificateSHA256: nil)
        #expect(credential.requiresSecure)
        #expect(TransportPolicy.reconnect(requiresSecure: credential.requiresSecure) == .secure)
    }

    @Test func aStoredCredentialWithoutTheFlagIsSecure() throws {
        let decoded = try JSONDecoder().decode(TVCredential.self, from: Data(#"{"token":"t"}"#.utf8))
        #expect(decoded.requiresSecure)
    }

    @Test func thePlainFlagSurvivesTheKeychainRoundTrip() throws {
        let credential = TVCredential(requiresSecure: false)
        let decoded = try JSONDecoder().decode(TVCredential.self, from: JSONEncoder().encode(credential))
        #expect(!decoded.requiresSecure)
        #expect(decoded.token == nil)
    }
}
