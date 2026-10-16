import os
import Photos

/// The real photo library through PhotoKit.
nonisolated struct PhotoKitLibrary: VideoLibrary {
    /// Where the album's identifier is kept, so a renamed album or a new language still finds it.
    private static let albumKey = "albumIdentifier"

    func access() -> LibraryAccess {
        LibraryAccess(status: PHPhotoLibrary.authorizationStatus(for: .readWrite))
    }

    func requestAccess() async -> LibraryAccess {
        LibraryAccess(status: await PHPhotoLibrary.requestAuthorization(for: .readWrite))
    }

    @concurrent
    func save(_ url: URL, original: String?, toAlbum: Bool) async throws -> String {
        guard access().canSave else { throw LibraryError.denied }

        let source = original.flatMap { PHAsset.fetchAssets(withLocalIdentifiers: [$0], options: nil).firstObject }
        // The copy keeps the original's date and place, so it sits next to it in the library.
        let date = source?.creationDate
        let location = source?.location
        let isFavorite = source?.isFavorite ?? false
        let album = toAlbum ? try? await Self.album() : nil
        let created = OSAllocatedUnfairLock<String?>(initialState: nil)
        do {
            try await PHPhotoLibrary.shared().performChanges {
                let request = PHAssetCreationRequest.forAsset()
                let options = PHAssetResourceCreationOptions()
                options.originalFilename = url.lastPathComponent
                request.addResource(with: .video, fileURL: url, options: options)
                request.creationDate = date ?? Date()
                request.location = location
                request.isFavorite = isFavorite
                if let album, let placeholder = request.placeholderForCreatedAsset {
                    PHAssetCollectionChangeRequest(for: album)?.addAssets([placeholder] as NSArray)
                }
                let id = request.placeholderForCreatedAsset?.localIdentifier
                created.withLock { $0 = id }
            }
        } catch {
            throw LibraryError.saveFailed
        }
        guard let id = created.withLock({ $0 }) else { throw LibraryError.saveFailed }
        return id
    }

    @concurrent
    func delete(_ ids: [String]) async throws -> Int {
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: ids, options: nil)
        guard assets.count > 0 else { return 0 }
        do {
            try await PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.deleteAssets(assets)
            }
        } catch let error as PHPhotosError where error.code == .userCancelled {
            throw LibraryError.cancelled
        } catch {
            throw LibraryError.saveFailed
        }
        return assets.count
    }

    /// The "Video compressi" album, made the first time.
    private static func album() async throws -> PHAssetCollection {
        let defaults = UserDefaults.standard
        if let id = defaults.string(forKey: albumKey),
           let album = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [id], options: nil).firstObject {
            return album
        }
        let title = String(localized: "Video compressi", comment: "The album in Photos with the compressed copies.")
        let created = OSAllocatedUnfairLock<String?>(initialState: nil)
        try await PHPhotoLibrary.shared().performChanges {
            let request = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: title)
            let id = request.placeholderForCreatedAssetCollection.localIdentifier
            created.withLock { $0 = id }
        }
        guard let id = created.withLock({ $0 }),
              let album = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [id], options: nil).firstObject else {
            throw LibraryError.saveFailed
        }
        defaults.set(id, forKey: albumKey)
        return album
    }
}
