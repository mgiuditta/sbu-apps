import Foundation
import Testing
@testable import SbuNoise

struct NoiseStoreTests {
    private let store = NoiseStore(url: .temporaryDirectory.appending(path: "NoiseStoreTests-\(UUID().uuidString)/noise.json"))

    @Test func aMissingFileLoadsEmpty() throws {
        #expect(try store.load() == NoiseFile())
    }

    @Test func savedTimersLoadBack() throws {
        let file = NoiseFile(timers: [
            SoundTimer(fade: .oneMinute, trigger: .duration(minutes: 45), repeatsAlways: true, startedAt: Date(timeIntervalSince1970: 1_000)),
            SoundTimer(isOn: false, trigger: .clock(hour: 23, minute: 30), weekdays: [2, 6]),
        ], mixes: [Mix(name: "Temporale", soundIDs: ["noise.brown", "noise.pink"])])
        try store.save(file)
        #expect(try store.load() == file)
    }

    @Test func aFileFromANewerVersionIsNeverOverwritten() throws {
        let newer = Data(#"{"version": 99, "timers": [], "somethingNew": true}"#.utf8)
        try FileManager.default.createDirectory(at: store.url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try newer.write(to: store.url)

        #expect(throws: NoiseStore.Failure.unknownVersion(99)) { try store.load() }
        #expect(throws: NoiseStore.Failure.unknownVersion(99)) { try store.save(NoiseFile()) }
        #expect(try Data(contentsOf: store.url) == newer)
    }

    @Test func aFileWithoutMixesLoadsWithNone() throws {
        let old = Data(#"{"version": 1, "timers": []}"#.utf8)
        try FileManager.default.createDirectory(at: store.url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try old.write(to: store.url)
        #expect(try store.load().mixes.isEmpty)
    }
}
