import Foundation
import Testing
@testable import SbuRemote

struct HoldTests {
    @Test(arguments: [RemoteKey.volumeUp, .volumeDown, .channelUp, .channelDown, .up, .rewind])
    func repeatingKeysUseThePressAndReleaseOfTheProtocol(key: RemoteKey) {
        #expect(HoldStrategy(key: key, holdsKeysNatively: true) == .native)
        #expect(HoldStrategy(key: key, holdsKeysNatively: false) == .repeating(HoldStrategy.repeatInterval))
    }

    @Test(arguments: [RemoteKey.power, .mute, .home, .select, .playPause, .source])
    func otherKeysDoNotRepeat(key: RemoteKey) {
        #expect(HoldStrategy(key: key, holdsKeysNatively: true) == .none)
        #expect(HoldStrategy(key: key, holdsKeysNatively: false) == .none)
    }

    @Test func holdingSendsPressThenRelease() async throws {
        let (session, client) = try await Self.connectedDemoSession()
        await session.beginHold(.volumeUp)
        await session.endHold()
        #expect(client.sent.map(\.0) == [.volumeUp, .volumeUp])
        #expect(client.sent.map(\.1) == [.press, .release])
    }

    @Test func aTapIsOneClick() async throws {
        let (session, client) = try await Self.connectedDemoSession()
        await session.press(.mute)
        #expect(client.sent.count == 1)
        #expect(client.sent.first?.1 == .click)
    }

    static func connectedDemoSession() async throws -> (RemoteSession, DemoTVClient) {
        let defaults = try #require(UserDefaults(suiteName: "HoldTests.\(UUID().uuidString)"))
        let store = TVStore(defaults: defaults)
        store.add(DemoTVClient.demoTV)
        var made: DemoTVClient?
        let session = RemoteSession(store: store) { tv in
            let client = DemoTVClient(tv: tv)
            made = client
            return client
        }
        await session.connect()
        return (session, try #require(made))
    }
}
