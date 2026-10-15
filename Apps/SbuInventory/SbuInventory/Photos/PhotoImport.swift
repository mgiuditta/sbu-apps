import Foundation

/// Runs the photo work away from the main thread, so the form stays responsive while photos shrink.
nonisolated enum PhotoImport {
    @concurrent
    static func process(_ data: Data) async -> PhotoDraft? {
        guard let processed = PhotoProcessor.process(data) else { return nil }
        return PhotoDraft(id: UUID(), data: processed.data, thumbnail: processed.thumbnail)
    }
}
