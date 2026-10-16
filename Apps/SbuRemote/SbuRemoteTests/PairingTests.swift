import Foundation
import Testing
@testable import SbuRemote

struct PairingTests {
    @Test func addingMakesTheTVCurrent() {
        var list = SavedTVList()
        let living = SavedTV(name: "Soggiorno", brand: .samsung, host: "192.168.1.20")
        let bedroom = SavedTV(name: "Camera", brand: .androidTV, host: "192.168.1.21")
        list.add(living)
        list.add(bedroom)
        #expect(list.current == bedroom)
        list.use(living.id)
        #expect(list.current == living)
    }

    @Test func pairingAgainAtTheSameAddressReplacesTheOldEntry() {
        var list = SavedTVList()
        let old = SavedTV(name: "Soggiorno", brand: .lg, host: "192.168.1.30")
        list.add(old)
        let new = SavedTV(name: "Soggiorno", brand: .lg, host: "192.168.1.30")
        #expect(list.add(new) == [old.id])
        #expect(list.tvs == [new])
    }

    @Test func removingTheCurrentTVFallsBackToTheFirst() {
        var list = SavedTVList()
        let first = SavedTV(name: "A", brand: .sony, host: "10.0.0.1")
        let second = SavedTV(name: "B", brand: .sony, host: "10.0.0.2")
        list.add(first)
        list.add(second)
        list.remove(second.id)
        #expect(list.current == first)
        list.remove(first.id)
        #expect(list.current == nil)
    }

    @Test func renameIgnoresBlankNames() {
        var list = SavedTVList()
        let tv = SavedTV(name: "Soggiorno", brand: .samsung, host: "10.0.0.1")
        list.add(tv)
        list.rename(tv.id, to: "  ")
        #expect(list.current?.name == "Soggiorno")
        list.rename(tv.id, to: " Salotto ")
        #expect(list.current?.name == "Salotto")
    }

    @Test func storePersistsWithoutCredentials() throws {
        let defaults = try #require(UserDefaults(suiteName: "PairingTests.\(UUID().uuidString)"))
        let store = TVStore(defaults: defaults)
        store.add(.sample)
        let reloaded = TVStore(defaults: defaults)
        #expect(reloaded.current == .sample)
        let text = String(decoding: try #require(defaults.data(forKey: TVStore.key)), as: UTF8.self)
        #expect(!text.contains("token"))
    }

    @Test(arguments: [
        ("a1 b2c3", 6, true, "A1B2C3"),
        ("1234", 4, false, "1234"),
    ])
    func validCodes(text: String, length: Int, isHexadecimal: Bool, code: String) {
        #expect(PairingCode.normalized(text, length: length, isHexadecimal: isHexadecimal) == code)
    }

    @Test(arguments: [
        ("A1B2C", 6, true),
        ("A1B2CG", 6, true),
        ("12a4", 4, false),
        ("12345", 4, false),
    ])
    func invalidCodes(text: String, length: Int, isHexadecimal: Bool) {
        #expect(PairingCode.normalized(text, length: length, isHexadecimal: isHexadecimal) == nil)
    }

    @Test(arguments: [
        (TVClientError.notPaired, ConnectionStatus.notPaired),
        (.rejected, .notPaired),
        (.unreachable, .unreachable),
        (.localNetworkDenied, .localNetworkDenied),
    ])
    func errorsBecomeStatuses(error: TVClientError, status: ConnectionStatus) {
        #expect(ConnectionStatus(error) == status)
    }

    @Test func onlyAConnectedRemoteAcceptsKeys() {
        #expect(ConnectionStatus.connected.acceptsKeys)
        #expect(!ConnectionStatus.connecting.acceptsKeys)
        #expect(!ConnectionStatus.unreachable.acceptsKeys)
    }
}
