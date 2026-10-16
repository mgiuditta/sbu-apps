import Foundation
import PhotosUI
import SwiftUI

/// A video the user picked, before its file is ready to read.
nonisolated struct PendingVideo: Identifiable, Sendable {
    let id = UUID()
    /// The original in Photos, when it came from there and the app may see it: the one that
    /// "Elimina originali" deletes.
    let assetID: String?
    /// Copies the file into the work folder and returns where it is.
    let load: @Sendable () async throws -> URL

    /// A video picked in Photos.
    init(item: PhotosPickerItem) {
        assetID = item.itemIdentifier
        load = {
            guard let file = try await item.loadTransferable(type: VideoFile.self) else {
                throw CompressionError.unreadable
            }
            return file.url
        }
    }

    /// A video imported from Files.
    init(file: URL) {
        assetID = nil
        load = {
            let isScoped = file.startAccessingSecurityScopedResource()
            defer {
                if isScoped { file.stopAccessingSecurityScopedResource() }
            }
            return try await WorkFolder.copyInBackground(file)
        }
    }

    /// Any other source, for the demo and the tests.
    init(assetID: String?, load: @escaping @Sendable () async throws -> URL) {
        self.assetID = assetID
        self.load = load
    }
}
