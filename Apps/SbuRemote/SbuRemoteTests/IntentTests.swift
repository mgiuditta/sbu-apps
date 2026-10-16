import Foundation
import Testing
@testable import SbuRemote

struct IntentTests {
    @Test func withoutATVTheIntentSaysSo() async throws {
        let defaults = try #require(UserDefaults(suiteName: "IntentTests.\(UUID().uuidString)"))
        await #expect(throws: RemoteCommand.Failure.self) {
            try await RemoteCommand.send(.volumeUp, store: TVStore(defaults: defaults))
        }
    }

    @Test func intentsPressTheirKey() {
        #expect(VolumeUpIntent.title.key == "Alza il volume")
        #expect(PowerIntent.title.key == "Accendi o spegni la TV")
    }
}
