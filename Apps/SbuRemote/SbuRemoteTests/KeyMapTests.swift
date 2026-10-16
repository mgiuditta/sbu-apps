import Testing
@testable import SbuRemote

/// Every media key goes somewhere on each protocol, or is dimmed on purpose.
struct KeyMapTests {
    nonisolated static let mediaKeys: [RemoteKey] = [.rewind, .playPause, .fastForward, .replay, .options]

    @Test func gridHoldsEveryMediaKey() {
        #expect(Set(KeyGridView.rows.flatMap(\.self)).isSuperset(of: Self.mediaKeys))
    }

    @Test(arguments: mediaKeys)
    func androidTVHasEveryMediaKey(key: RemoteKey) {
        #expect(AndroidKeyCode.code(for: key) != nil)
    }

    @Test(arguments: [(RemoteKey.rewind, "KEY_REWIND"), (.fastForward, "KEY_FF"), (.playPause, "KEY_PLAY"), (.options, "KEY_TOOLS")])
    func samsungMediaKeys(key: RemoteKey, code: String) {
        #expect(SamsungMessage.keyCode(for: key) == code)
    }

    @Test func lgMediaKeys() {
        #expect(LGMessage.uri(for: .rewind) == "ssap://media.controls/rewind")
        #expect(LGMessage.uri(for: .fastForward) == "ssap://media.controls/fastForward")
        #expect(LGPointerMessage.buttonName(for: .options) == "MENU")
    }

    @Test(arguments: mediaKeys)
    func sonyHasANameForEveryMediaKey(key: RemoteKey) {
        #expect(!SonyRequest.irccNames(for: key).isEmpty)
    }

    @Test func replayIsDimmedOnSamsungAndLG() {
        #expect(!SamsungClient(tv: .sample).supportedKeys.contains(.replay))
        #expect(!LGClient(tv: .sample).supportedKeys.contains(.replay))
    }
}
