import Testing
@testable import SbuRemote

struct SourceSessionTests {
    @Test func inputsComeThroughTheSession() async throws {
        let (session, _) = try await HoldTests.connectedDemoSession()
        var listed: [TVShortcut] = []
        await session.run { listed = try await $0.inputs() }
        #expect(listed.count == 3)
    }
}
