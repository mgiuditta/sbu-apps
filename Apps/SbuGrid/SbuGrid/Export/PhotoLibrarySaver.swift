import Foundation
import Photos

/// Adds the exported picture to Photos. It asks only to add: Sbu Grid never reads the library.
/// Not on the main actor: Photos runs the change block on its own queue.
nonisolated enum PhotoLibrarySaver {
    static func save(fileAt url: URL) async throws(ExportError) {
        let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        guard status == .authorized || status == .limited else { throw .photosDenied }
        do {
            try await PHPhotoLibrary.shared().performChanges {
                PHAssetCreationRequest.forAsset().addResource(with: .photo, fileURL: url, options: nil)
            }
        } catch {
            throw .notSaved
        }
    }
}
