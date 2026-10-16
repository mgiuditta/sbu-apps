import Foundation
import Testing
@testable import SbuFind

struct BluetoothNoticeTests {
    @Test func readyShowsTheListInstead() {
        #expect(BluetoothNotice(state: .ready) == nil)
    }

    @Test(arguments: BluetoothState.allCases.filter { $0 != .ready })
    func everyOtherStateSaysSomething(state: BluetoothState) throws {
        let notice = try #require(BluetoothNotice(state: state))
        #expect(!String(localized: notice.title).isEmpty)
        #expect(!String(localized: notice.message).isEmpty)
        #expect(!notice.systemImage.isEmpty)
    }

    @Test(arguments: [
        (BluetoothState.denied, true),
        (.restricted, true),
        (.poweredOff, false),
        (.unsupported, false),
        (.resetting, false),
        (.starting, false),
    ])
    func onlyPermissionProblemsOfferSettings(state: BluetoothState, opensSettings: Bool) {
        #expect(BluetoothNotice(state: state)?.opensSettings == opensSettings)
    }

    @Test func eachStateHasItsOwnTitle() {
        let titles = BluetoothState.allCases.compactMap { BluetoothNotice(state: $0) }.map { String(localized: $0.title) }
        #expect(Set(titles).count == BluetoothState.allCases.count - 1)
    }
}
