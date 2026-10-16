import Foundation
import Testing
@testable import SbuShrink

@Suite(.serialized)
struct WorkFolderTests {
    @Test(arguments: [
        ("IMG_1669.MOV", OutputFormat.mov, "IMG_1669.mov"),
        ("IMG_1669.MOV", .mp4, "IMG_1669.mp4"),
        ("clip.m4v", .mp4, "clip.mp4"),
        ("no extension", .mov, "no extension.mov"),
        ("città è.mov", .mov, "città è.mov"),
    ])
    func outputKeepsTheNameWithTheNewExtension(name: String, format: OutputFormat, expected: String) throws {
        let output = try WorkFolder.output(for: URL(filePath: "/tmp/in/\(name)"), format: format)
        #expect(output.lastPathComponent == expected)
        #expect(output.path().hasPrefix(WorkFolder.root.path()))
    }

    @Test func twoVideosWithTheSameNameNeverCollide() throws {
        let source = URL(filePath: "/tmp/in/IMG_1.MOV")
        let first = try WorkFolder.output(for: source, format: .mov)
        let second = try WorkFolder.output(for: source, format: .mov)
        #expect(first != second)
    }

    @Test func copyKeepsTheNameAndClearRemovesEverything() async throws {
        let original = URL.temporaryDirectory.appending(path: "orig-\(UUID().uuidString).mov")
        try Data("video".utf8).write(to: original)
        defer { try? FileManager.default.removeItem(at: original) }

        let copy = try await WorkFolder.copyInBackground(original)
        #expect(copy.lastPathComponent == original.lastPathComponent)
        #expect(try Data(contentsOf: copy) == Data("video".utf8))

        WorkFolder.clear()
        #expect(!FileManager.default.fileExists(atPath: copy.path()))
    }

    @Test func copyingAMissingFileThrows() {
        #expect(throws: (any Error).self) {
            try WorkFolder.copy(URL(filePath: "/tmp/missing-\(UUID().uuidString).mov"))
        }
    }
}
