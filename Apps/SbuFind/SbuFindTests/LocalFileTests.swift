import Foundation
import Testing
@testable import SbuFind

/// A file missing or damaged starts from nothing; a file there but unreadable is kept apart, so
/// nothing is saved over it.
struct LocalFileTests {
    let file = LocalFile<[Int]>(url: URL.temporaryDirectory.appending(path: "local-\(UUID().uuidString).json"))

    @Test func aMissingFileIsEmpty() {
        #expect(file.read() == .empty)
    }

    @Test func aDamagedFileIsEmpty() throws {
        try Data("not json".utf8).write(to: file.url)
        #expect(file.read() == .empty)
    }

    @Test func aSavedValueIsLoaded() {
        file.save([1, 2, 3])
        #expect(file.read() == .loaded([1, 2, 3]))
    }

    /// As with a protected file and the iPhone locked: there, but not readable now.
    @Test func aFileThatCannotBeReadIsUnavailable() throws {
        file.save([1])
        try FileManager.default.setAttributes([.posixPermissions: 0o000], ofItemAtPath: file.url.path())
        defer { try? FileManager.default.setAttributes([.posixPermissions: 0o644], ofItemAtPath: file.url.path()) }
        #expect(file.read() == .unavailable)
    }
}
