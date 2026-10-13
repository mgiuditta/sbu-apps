import UIKit
import os

/// A made-up library for previews, UI tests and App Store screenshots: about sixty items with
/// duplicates, a burst, screenshots, videos and Live Photos, all drawn in code.
nonisolated final class DemoLibrary: PhotoLibrary {
    private struct Entry: Sendable {
        var item: MediaItem
        /// Draws the landscape with this seed and shift, or a screen when `isScreen`.
        var seed: Int
        var shift: CGFloat = 0
        var isScreen = false
    }

    private struct Contents: Sendable {
        var access: LibraryAccess
        var entries: [Entry]
    }

    private static let pictureSize = CGSize(width: 1200, height: 900)
    private static let screenSize = CGSize(width: 590, height: 1278)

    private let contents: OSAllocatedUnfairLock<Contents>

    /// Creates the demo library.
    /// - Parameters:
    ///   - access: The access it pretends the user gave; requesting it gives full access.
    ///   - now: The day the library ends on.
    init(access: LibraryAccess = .full, now: Date = .now) {
        contents = OSAllocatedUnfairLock(initialState: Contents(access: access, entries: Self.makeEntries(now: now)))
    }

    func currentAccess() -> LibraryAccess {
        contents.withLock { $0.access }
    }

    func requestAccess() async -> LibraryAccess {
        contents.withLock { contents in
            if contents.access == .notDetermined {
                contents.access = .full
            }
            return contents.access
        }
    }

    func fetchItems() async -> [MediaItem] {
        contents.withLock { $0.entries.map { entry in
            var item = entry.item
            item.size = nil
            return item
        } }
    }

    func measure(_ ids: [String]) async -> [String: ItemSize] {
        let wanted = Set(ids)
        return contents.withLock { contents in
            Dictionary(uniqueKeysWithValues: contents.entries.filter { wanted.contains($0.item.id) }.compactMap { entry in
                entry.item.size.map { (entry.item.id, $0) }
            })
        }
    }

    func albums() async -> [Album] {
        [Album(id: "demo-album", title: String(localized: "Vacanze"), count: 6)]
    }

    func itemIDs(inAlbum albumID: String) async -> [String] {
        contents.withLock { Array($0.entries.map(\.item.id).filter { $0.hasPrefix("photo") }.prefix(6)) }
    }

    func image(for id: String, pixelSide: CGFloat) async -> UIImage? {
        guard let entry = entry(id) else { return nil }

        return Self.draw(entry)
    }

    func analyze(_ id: String) async -> ImageAnalysis? {
        guard let entry = entry(id), entry.item.kind == .photo else { return nil }

        return await Self.analyze(entry)
    }

    func videoURL(for id: String) async -> URL? {
        nil
    }

    func details(for id: String) async -> MediaDetails {
        guard let entry = entry(id) else { return MediaDetails() }

        return entry.isScreen
            ? MediaDetails(fileName: "IMG_\(1000 + entry.seed).PNG")
            : MediaDetails(fileName: "IMG_\(1000 + entry.seed).HEIC", camera: "iPhone", lens: nil)
    }

    func delete(_ ids: [String]) async throws {
        let gone = Set(ids)
        contents.withLock { $0.entries.removeAll { gone.contains($0.item.id) } }
    }

    func saveStill(ofLivePhoto id: String) async throws -> String {
        guard var entry = entry(id) else { throw LibraryError.unavailable }

        entry.item = MediaItem(id: "still-\(id)", creationDate: entry.item.creationDate, kind: .photo, isFavorite: entry.item.isFavorite,
                               pixelWidth: entry.item.pixelWidth, pixelHeight: entry.item.pixelHeight,
                               size: ItemSize(bytes: entry.item.bytes - (entry.item.size?.pairedVideoBytes ?? 0)))
        let still = entry
        contents.withLock { $0.entries.append(still) }
        return still.item.id
    }

    func saveCompressed(video id: String, quality: CompressionQuality) async throws -> String {
        guard var entry = entry(id) else { throw LibraryError.unavailable }

        let bytes = quality.estimatedBytes(duration: entry.item.duration, originalBytes: entry.item.bytes)
        entry.item = MediaItem(id: "compressed-\(id)", creationDate: entry.item.creationDate, kind: .video,
                               pixelWidth: 1280, pixelHeight: 720, duration: entry.item.duration, size: ItemSize(bytes: bytes))
        let compressed = entry
        contents.withLock { $0.entries.append(compressed) }
        return compressed.item.id
    }

    func changes() -> AsyncStream<Void> {
        AsyncStream { _ in }
    }

    private func entry(_ id: String) -> Entry? {
        contents.withLock { $0.entries.first { $0.item.id == id } }
    }

    @concurrent
    private static func analyze(_ entry: Entry) async -> ImageAnalysis? {
        guard let image = draw(entry).cgImage else { return nil }

        return ImageAnalyzer.analyze(image)
    }

    private static func draw(_ entry: Entry) -> UIImage {
        entry.isScreen
            ? DemoPicture.screen(seed: entry.seed, size: screenSize)
            : DemoPicture.landscape(seed: entry.seed, shift: entry.shift, size: pictureSize)
    }

    // MARK: - Contents

    private static func makeEntries(now: Date) -> [Entry] {
        let day: TimeInterval = 86_400
        var entries: [Entry] = []

        func photo(_ id: String, seed: Int, ago: TimeInterval, shift: CGFloat = 0, megabytes: Double = 3.2, live: Bool = false, favorite: Bool = false) {
            let paired: Int64 = live ? 2_400_000 : 0
            let bytes = Int64(megabytes * 1_000_000) + paired
            let item = MediaItem(id: id, creationDate: now.addingTimeInterval(-ago), kind: .photo, isLivePhoto: live, isFavorite: favorite,
                                 pixelWidth: 4032, pixelHeight: 3024, size: ItemSize(bytes: bytes, pairedVideoBytes: paired))
            entries.append(Entry(item: item, seed: seed, shift: shift))
        }

        // The last days: a burst, everyday photos, two Live Photos.
        for shot in 0..<3 {
            photo("burst-\(shot)", seed: 50, ago: day * 1 + Double(shot) * 2, shift: CGFloat(shot) * 8, megabytes: 3.6 + Double(shot) * 0.1)
        }
        for index in 0..<8 {
            photo("photo-\(index)", seed: index + 1, ago: day * Double(index * 3 + 2), megabytes: 2.4 + Double(index % 4) * 0.6, favorite: index == 2)
        }
        photo("live-0", seed: 70, ago: day * 4, live: true)
        photo("live-1", seed: 71, ago: day * 12, live: true)

        // Screenshots.
        for index in 0..<5 {
            let item = MediaItem(id: "screenshot-\(index)", creationDate: now.addingTimeInterval(-day * Double(index * 5 + 1)), kind: .photo,
                                 isScreenshot: true, pixelWidth: 1179, pixelHeight: 2556, size: ItemSize(bytes: Int64(900_000 + index * 150_000)))
            entries.append(Entry(item: item, seed: 80 + index, isScreen: true))
        }

        // Videos, one of them a screen recording.
        for (index, (seconds, megabytes)) in [(95.0, 420.0), (48.0, 140.0), (12.0, 31.0)].enumerated() {
            let item = MediaItem(id: "video-\(index)", creationDate: now.addingTimeInterval(-day * Double(index * 20 + 6)), kind: .video,
                                 pixelWidth: 1920, pixelHeight: 1080, duration: seconds, size: ItemSize(bytes: Int64(megabytes * 1_000_000)))
            entries.append(Entry(item: item, seed: 90 + index))
        }
        let recording = MediaItem(id: "recording-0", creationDate: now.addingTimeInterval(-day * 9), kind: .video, isScreenRecording: true,
                                  pixelWidth: 1178, pixelHeight: 2556, duration: 22, size: ItemSize(bytes: 38_000_000))
        entries.append(Entry(item: recording, seed: 95, isScreen: true))

        // Duplicates: one picture saved twice, another three times, far apart.
        photo("duplicate-a0", seed: 60, ago: day * 15)
        photo("duplicate-a1", seed: 60, ago: day * 75)
        photo("duplicate-b0", seed: 61, ago: day * 33, megabytes: 4.1)
        photo("duplicate-b1", seed: 61, ago: day * 120, megabytes: 4.1)
        photo("duplicate-b2", seed: 61, ago: day * 200, megabytes: 4.1)

        // Older months, two photos each.
        for month in 1..<14 {
            photo("old-\(month)-a", seed: 200 + month * 2, ago: day * Double(month * 30 + 3))
            photo("old-\(month)-b", seed: 201 + month * 2, ago: day * Double(month * 30 + 11), megabytes: 2.8)
        }

        return entries.sorted { ($0.item.creationDate ?? .distantPast) > ($1.item.creationDate ?? .distantPast) }
    }
}
