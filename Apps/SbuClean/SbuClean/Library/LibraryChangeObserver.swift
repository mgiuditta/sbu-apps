import Photos

/// Turns PhotoKit change notifications into an `AsyncStream`.
nonisolated final class LibraryChangeObserver: NSObject, PHPhotoLibraryChangeObserver, Sendable {
    private let continuation: AsyncStream<Void>.Continuation

    init(continuation: AsyncStream<Void>.Continuation) {
        self.continuation = continuation
    }

    func photoLibraryDidChange(_ changeInstance: PHChange) {
        continuation.yield()
    }
}
