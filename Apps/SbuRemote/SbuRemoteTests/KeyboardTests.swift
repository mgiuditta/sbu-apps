import Foundation
import Testing
@testable import SbuRemote

struct KeyboardTests {
    @Test func textReachesTheTVAsTyped() async throws {
        let (session, client) = try await HoldTests.connectedDemoSession()
        for text in ["c", "ci", "cia", "ciao"] {
            await session.run { try await $0.sendText(text) }
        }
        #expect(client.text == "ciao")
    }

    @Test func noTextWithoutAConnection() async throws {
        let defaults = try #require(UserDefaults(suiteName: "KeyboardTests.\(UUID().uuidString)"))
        let session = RemoteSession(store: TVStore(defaults: defaults)) { DemoTVClient(tv: $0) }
        var ran = false
        await session.run { _ in ran = true }
        #expect(!ran)
    }
}
