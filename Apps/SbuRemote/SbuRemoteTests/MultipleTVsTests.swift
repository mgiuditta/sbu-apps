import Foundation
import Testing
@testable import SbuRemote

struct MultipleTVsTests {
    private func session() throws -> (RemoteSession, UserDefaults) {
        let defaults = try #require(UserDefaults(suiteName: "MultipleTVsTests.\(UUID().uuidString)"))
        return (RemoteSession(store: TVStore(defaults: defaults)) { DemoTVClient(tv: $0) }, defaults)
    }

    @Test func switchingConnectsToTheOtherTV() async throws {
        let (session, _) = try session()
        let living = SavedTV(name: "Soggiorno", brand: .samsung, host: "10.0.0.1")
        let bedroom = SavedTV(name: "Camera", brand: .lg, host: "10.0.0.2")
        await session.add(living)
        await session.add(bedroom)
        #expect(session.tv == bedroom)
        await session.switchTo(living)
        #expect(session.tv == living)
        #expect(session.status == .connected)
        #expect(session.client?.tv == living)
    }

    @Test func theLastUsedTVOpensAtLaunch() async throws {
        let (session, defaults) = try session()
        let living = SavedTV(name: "Soggiorno", brand: .samsung, host: "10.0.0.1")
        let bedroom = SavedTV(name: "Camera", brand: .lg, host: "10.0.0.2")
        await session.add(living)
        await session.add(bedroom)
        await session.switchTo(living)
        #expect(TVStore(defaults: defaults).current == living)
    }

    @Test func forgettingTheCurrentTVMovesToTheNext() async throws {
        let (session, _) = try session()
        let living = SavedTV(name: "Soggiorno", brand: .samsung, host: "10.0.0.1")
        let bedroom = SavedTV(name: "Camera", brand: .lg, host: "10.0.0.2")
        await session.add(living)
        await session.add(bedroom)
        await session.forget(bedroom)
        #expect(session.tv == living)
        await session.forget(living)
        #expect(session.tv == nil)
        #expect(session.status == .noTV)
    }
}
