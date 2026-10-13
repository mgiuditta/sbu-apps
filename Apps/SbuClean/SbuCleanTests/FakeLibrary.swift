import Foundation
import UIKit
import os
@testable import SbuClean

/// A library in memory: items, sizes and analyses set by the test, calls counted.
nonisolated final class FakeLibrary: PhotoLibrary {
    struct Contents: Sendable {
        var access: LibraryAccess = .full
        var items: [MediaItem] = []
        var sizes: [String: ItemSize] = [:]
        var analyses: [String: ImageAnalysis] = [:]
        var analyzed: [String] = []
        var measured: [String] = []
        var deleted: [String] = []
        var refusesDeletion = false
    }

    let contents: OSAllocatedUnfairLock<Contents>

    init(items: [MediaItem] = [], sizes: [String: ItemSize] = [:], analyses: [String: ImageAnalysis] = [:], access: LibraryAccess = .full) {
        contents = OSAllocatedUnfairLock(initialState: Contents(access: access, items: items, sizes: sizes, analyses: analyses))
    }

    var analyzed: [String] {
        contents.withLock { $0.analyzed }
    }

    var measured: [String] {
        contents.withLock { $0.measured }
    }

    var deleted: [String] {
        contents.withLock { $0.deleted }
    }

    func update(_ change: @Sendable (inout Contents) -> Void) {
        contents.withLock { change(&$0) }
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
        contents.withLock { $0.items }
    }

    func measure(_ ids: [String]) async -> [String: ItemSize] {
        contents.withLock { contents in
            contents.measured += ids
            return contents.sizes.filter { ids.contains($0.key) }
        }
    }

    func albums() async -> [Album] {
        []
    }

    func itemIDs(inAlbum albumID: String) async -> [String] {
        []
    }

    func image(for id: String, pixelSide: CGFloat) async -> UIImage? {
        nil
    }

    func analyze(_ id: String) async -> ImageAnalysis? {
        contents.withLock { contents in
            contents.analyzed.append(id)
            return contents.analyses[id]
        }
    }

    func videoURL(for id: String) async -> URL? {
        nil
    }

    func details(for id: String) async -> MediaDetails {
        MediaDetails()
    }

    func delete(_ ids: [String]) async throws {
        try contents.withLock { contents in
            if contents.refusesDeletion {
                throw CocoaError(.userCancelled)
            }
            contents.deleted += ids
            contents.items.removeAll { ids.contains($0.id) }
        }
    }

    func saveStill(ofLivePhoto id: String) async throws -> String {
        "still-\(id)"
    }

    func saveCompressed(video id: String, quality: CompressionQuality) async throws -> String {
        "compressed-\(id)"
    }

    func changes() -> AsyncStream<Void> {
        AsyncStream { $0.finish() }
    }
}
