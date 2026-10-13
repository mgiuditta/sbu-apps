import Foundation
@testable import SbuClean

/// Builders for test items and dates.
nonisolated enum Fixture {
    /// Noon of a day in 2026, in the Gregorian calendar of the current time zone.
    static func date(_ month: Int, _ day: Int, year: Int = 2026, hour: Int = 12, minute: Int = 0, second: Int = 0) -> Date {
        Calendar.current.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute, second: second)) ?? .distantPast
    }

    static func photo(_ id: String, on date: Date? = nil, bytes: Int64 = 1_000_000, screenshot: Bool = false, favorite: Bool = false, pixels: Int = 12_000_000) -> MediaItem {
        MediaItem(id: id, creationDate: date, kind: .photo, isScreenshot: screenshot, isFavorite: favorite,
                  pixelWidth: pixels / 1000, pixelHeight: 1000, size: ItemSize(bytes: bytes))
    }

    static func video(_ id: String, on date: Date? = nil, bytes: Int64 = 50_000_000, recording: Bool = false) -> MediaItem {
        MediaItem(id: id, creationDate: date, kind: .video, isScreenRecording: recording, duration: 30, size: ItemSize(bytes: bytes))
    }

    /// A feature print pointing mostly along one axis, `offset` away from the pure axis.
    static func print(axis: Int, offset: Float = 0, dimension: Int = 8) -> [Float] {
        var vector = [Float](repeating: 0, count: dimension)
        vector[axis] = 1
        vector[(axis + 1) % dimension] = offset
        return vector
    }

    /// A fresh folder for a model's files.
    static func directory() -> URL {
        URL.temporaryDirectory.appending(path: "tests-\(UUID().uuidString)", directoryHint: .isDirectory)
    }
}
