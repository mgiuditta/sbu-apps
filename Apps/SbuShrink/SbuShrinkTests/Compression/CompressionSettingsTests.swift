import Foundation
import Testing
@testable import SbuShrink

struct CompressionSettingsTests {
    @Test func defaultsAreTheOriginalsSuggestions() {
        let settings = CompressionSettings()
        #expect(settings.frameRate == 24)
        #expect(settings.dimensionPercent == 80)
        #expect(settings.qualityPercent == 60)
        #expect(settings.targetMegabytes == nil)
        #expect(settings.codec == .h264)
        #expect(!settings.removesAudio)
        #expect(!settings.convertsToMP4)
        #expect(!settings.hasAdvancedChanges)
    }

    @Test(arguments: [
        (Int.min, 10), (-5, 10), (0, 10), (9, 10), (10, 10), (24, 24), (60, 60), (61, 60), (240, 60), (Int.max, 60),
    ])
    func frameRateIsClamped(value: Int, expected: Int) {
        #expect(CompressionSettings(frameRate: value).frameRate == expected)
        var settings = CompressionSettings()
        settings.frameRate = value
        #expect(settings.frameRate == expected)
    }

    @Test(arguments: [(Int.min, 10), (0, 10), (10, 10), (55, 55), (100, 100), (101, 100), (Int.max, 100)])
    func dimensionAndQualityAreClamped(value: Int, expected: Int) {
        var settings = CompressionSettings(dimensionPercent: value, qualityPercent: value)
        #expect(settings.dimensionPercent == expected)
        #expect(settings.qualityPercent == expected)
        settings.dimensionPercent = value
        settings.qualityPercent = value
        #expect(settings.dimensionPercent == expected)
        #expect(settings.qualityPercent == expected)
    }

    @Test(arguments: [
        (Double?.none, Double?.none),
        (.some(.nan), .none),
        (.some(.infinity), .none),
        (.some(-.infinity), .none),
        (.some(-3), .some(1)),
        (.some(0), .some(1)),
        (.some(0.5), .some(1)),
        (.some(25), .some(25)),
        (.some(9.9), .some(9.9)),
        (.some(1e12), .some(10_000)),
    ])
    func targetIsClampedOrDropped(value: Double?, expected: Double?) {
        #expect(CompressionSettings(targetMegabytes: value).targetMegabytes == expected)
        var settings = CompressionSettings()
        settings.targetMegabytes = value
        #expect(settings.targetMegabytes == expected)
    }

    @Test(arguments: [
        CompressionSettings(targetMegabytes: 10),
        CompressionSettings(codec: .hevc),
        CompressionSettings(removesAudio: true),
        CompressionSettings(convertsToMP4: true),
    ])
    func anyAdvancedOptionCountsAsAChange(settings: CompressionSettings) {
        #expect(settings.hasAdvancedChanges)
    }

    @Test func theMainSlidersAreNotAdvanced() {
        #expect(!CompressionSettings(frameRate: 60, dimensionPercent: 30, qualityPercent: 90).hasAdvancedChanges)
    }

    @Test func roundTripsThroughJSON() throws {
        let settings = CompressionSettings(frameRate: 30, dimensionPercent: 50, qualityPercent: 75, targetMegabytes: 24.5, codec: .hevc, removesAudio: true, convertsToMP4: true)
        let data = try JSONEncoder().encode(settings)
        #expect(try JSONDecoder().decode(CompressionSettings.self, from: data) == settings)
    }

    @Test func decodingClampsStoredValues() throws {
        let json = Data(#"{"frameRate": 999, "dimensionPercent": -4, "qualityPercent": 1000, "targetMegabytes": -1, "codec": "hevc", "removesAudio": true, "convertsToMP4": false}"#.utf8)
        let settings = try JSONDecoder().decode(CompressionSettings.self, from: json)
        #expect(settings.frameRate == 60)
        #expect(settings.dimensionPercent == 10)
        #expect(settings.qualityPercent == 100)
        #expect(settings.targetMegabytes == 1)
        #expect(settings.codec == .hevc)
    }

    @Test func decodingFallsBackToDefaultsForMissingOrWrongValues() throws {
        let json = Data(#"{"frameRate": "fast", "codec": "av1", "removesAudio": 3}"#.utf8)
        let settings = try JSONDecoder().decode(CompressionSettings.self, from: json)
        #expect(settings == CompressionSettings())
    }

    @Test func decodingAnEmptyObjectGivesTheDefaults() throws {
        #expect(try JSONDecoder().decode(CompressionSettings.self, from: Data("{}".utf8)) == CompressionSettings())
    }

    @Test func decodingSomethingThatIsNotAnObjectThrows() {
        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(CompressionSettings.self, from: Data("[1, 2]".utf8))
        }
    }
}
