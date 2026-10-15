import Foundation
import Testing
@testable import SbuChats

struct KnownOwnersTests {
    private let owners = KnownOwners(defaults: UserDefaults(suiteName: "known-owners-\(UUID().uuidString)") ?? .standard)

    @Test func remembersNamesOnceInOrder() {
        owners.remember("Giulia")
        owners.remember("Giulia R.")
        owners.remember("Giulia")
        #expect(owners.names == ["Giulia", "Giulia R."])
    }

    @Test func forgetsAName() {
        owners.remember("Giulia")
        owners.remember("Marco")
        owners.forget("Giulia")
        #expect(owners.names == ["Marco"])
    }
}
