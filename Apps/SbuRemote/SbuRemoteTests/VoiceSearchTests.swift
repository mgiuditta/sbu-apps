import Testing
@testable import SbuRemote

struct VoiceSearchTests {
    @Test func stoppingBeforeListeningSendsNothing() {
        let voice = VoiceSearch()
        #expect(voice.stop().isEmpty)
        #expect(voice.phase == .idle)
    }
}
