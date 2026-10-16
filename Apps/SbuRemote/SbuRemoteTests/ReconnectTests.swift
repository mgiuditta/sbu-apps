import Foundation
import Testing
@testable import SbuRemote

struct ReconnectTests {
    @Test(arguments: [ConnectionStatus.unreachable, .localNetworkDenied])
    func comingBackReconnects(status: ConnectionStatus) {
        #expect(ReconnectPolicy.action(for: .becameActive, status: status) == .reconnect)
        #expect(ReconnectPolicy.action(for: .dropped, status: status) == .reconnect)
    }

    @Test func aConnectedRemoteStaysAsItIs() {
        #expect(ReconnectPolicy.action(for: .becameActive, status: .connected) == .nothing)
        #expect(ReconnectPolicy.action(for: .becameActive, status: .connecting) == .nothing)
    }

    @Test func aForgottenPhoneWaitsForPairing() {
        #expect(ReconnectPolicy.action(for: .becameActive, status: .notPaired) == .nothing)
        #expect(ReconnectPolicy.action(for: .networkChanged(isOnLocalNetwork: true), status: .notPaired) == .nothing)
    }

    @Test func backgroundLetsGo() {
        #expect(ReconnectPolicy.action(for: .wentToBackground, status: .connected) == .disconnect)
    }

    @Test func aNewWiFiReconnectsEvenWhenConnected() {
        #expect(ReconnectPolicy.action(for: .networkChanged(isOnLocalNetwork: true), status: .connected) == .reconnect)
        #expect(ReconnectPolicy.action(for: .networkChanged(isOnLocalNetwork: false), status: .connected) == .disconnect)
    }

    @Test func nothingWithoutATV() {
        #expect(ReconnectPolicy.action(for: .becameActive, status: .noTV) == .nothing)
        #expect(ReconnectPolicy.action(for: .wentToBackground, status: .noTV) == .nothing)
    }

    @Test func returningToTheForegroundReconnectsTheSession() async throws {
        let (session, _) = try await HoldTests.connectedDemoSession()
        await session.handle(.wentToBackground)
        #expect(session.status == .unreachable)
        #expect(session.client == nil)
        await session.handle(.becameActive)
        #expect(session.status == .connected)
    }
}
