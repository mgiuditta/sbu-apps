import AVFoundation
import ImageIO
import Photos
import UIKit
import os

/// The real photo library, through PhotoKit, on the device only.
///
/// Network access stays off, except when the user asks for one video kept only in iCloud (to
/// watch or compress it): pictures show their local copy and nothing downloads during a scan.
nonisolated final class PhotoKitLibrary: PhotoLibrary {
    /// The side of the picture Vision analyses.
    private static let analysisSide: CGFloat = 512

    func currentAccess() -> LibraryAccess {
        LibraryAccess(status: PHPhotoLibrary.authorizationStatus(for: .readWrite))
    }

    func requestAccess() async -> LibraryAccess {
        LibraryAccess(status: await PHPhotoLibrary.requestAuthorization(for: .readWrite))
    }

    // Off the main actor: callers are views and the main-actor model.
    @concurrent
    func fetchItems() async -> [MediaItem] {
        await Self.fetchAll()
    }

    // Off the main actor: callers are views and the main-actor model.
    @concurrent
    func measure(_ ids: [String]) async -> [String: ItemSize] {
        await Self.sizes(of: ids)
    }

    // Off the main actor: callers are views and the main-actor model.
    @concurrent
    func albums() async -> [Album] {
        await Self.userAlbums()
    }

    // Off the main actor: callers are views and the main-actor model.
    @concurrent
    func itemIDs(inAlbum albumID: String) async -> [String] {
        await Self.ids(inAlbum: albumID)
    }

    // Off the main actor: callers are views and the main-actor model.
    @concurrent
    func image(for id: String, pixelSide: CGFloat) async -> UIImage? {
        guard let asset = Self.asset(id) else { return nil }

        if let image = await Self.requestImage(of: asset, side: pixelSide, mode: .highQualityFormat) {
            return image
        }
        // Kept only in iCloud: the small local copy is better than nothing.
        return await Self.requestImage(of: asset, side: pixelSide, mode: .fastFormat)
    }

    // Off the main actor, at the scan's low priority. The fast format is the small copy Photos
    // keeps ready: Vision scales every picture down to a few hundred pixels anyway, and
    // decoding full-size originals is what made a scan heavy.
    @concurrent
    func analyze(_ id: String) async -> ImageAnalysis? {
        guard let asset = Self.asset(id) else { return nil }

        var image = await Self.requestImage(of: asset, side: Self.analysisSide, mode: .fastFormat)
        if image == nil {
            image = await Self.requestImage(of: asset, side: Self.analysisSide, mode: .highQualityFormat)
        }
        guard let cgImage = image?.cgImage else { return nil }

        return ImageAnalyzer.analyze(cgImage)
    }

    // Off the main actor: callers are views and the main-actor model.
    @concurrent
    func videoURL(for id: String) async -> URL? {
        guard let asset = Self.asset(id) else { return nil }

        return await Self.urlAsset(of: asset)?.url
    }

    // Off the main actor: callers are views and the main-actor model.
    @concurrent
    func downloadVideo(for id: String, progress: @escaping @Sendable (Double) -> Void) async throws -> URL {
        guard let asset = Self.asset(id) else { throw LibraryError.unavailable }

        let url = await Self.urlAsset(of: asset, allowingDownload: true, progress: progress)?.url
        try Task.checkCancellation()
        guard let url else { throw LibraryError.unavailable }

        return url
    }

    // Off the main actor: callers are views and the main-actor model.
    @concurrent
    func details(for id: String) async -> MediaDetails {
        guard let asset = Self.asset(id) else { return MediaDetails() }

        var details = MediaDetails(fileName: PHAssetResource.assetResources(for: asset).first?.originalFilename)
        if asset.mediaType == .image, let data = await Self.imageData(of: asset) {
            let metadata = Self.cameraMetadata(in: data)
            details.camera = metadata.camera
            details.lens = metadata.lens
        }
        return details
    }

    // Off the main actor: callers are views and the main-actor model.
    @concurrent
    func delete(_ ids: [String]) async throws {
        do {
            try await PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.deleteAssets(PHAsset.fetchAssets(withLocalIdentifiers: ids, options: nil))
            }
        } catch let error as PHPhotosError where error.code == .userCancelled {
            throw LibraryError.cancelled
        }
    }

    // Off the main actor: callers are views and the main-actor model.
    @concurrent
    func saveStill(ofLivePhoto id: String) async throws -> String {
        guard let asset = Self.asset(id), let data = await Self.imageData(of: asset) else { throw LibraryError.unavailable }

        let date = asset.creationDate
        let location = asset.location
        let isFavorite = asset.isFavorite
        let created = OSAllocatedUnfairLock<String?>(initialState: nil)
        try await PHPhotoLibrary.shared().performChanges {
            let request = PHAssetCreationRequest.forAsset()
            request.addResource(with: .photo, data: data, options: nil)
            request.creationDate = date
            request.location = location
            request.isFavorite = isFavorite
            let newID = request.placeholderForCreatedAsset?.localIdentifier
            created.withLock { $0 = newID }
        }
        guard let newID = created.withLock({ $0 }) else { throw LibraryError.saveFailed }

        return newID
    }

    // Off the main actor: callers are views and the main-actor model.
    @concurrent
    func saveCompressed(video id: String, quality: CompressionQuality, progress: @escaping @Sendable (CompressionStep) -> Void) async throws -> String {
        guard let asset = Self.asset(id) else { throw LibraryError.unavailable }

        var source = await Self.urlAsset(of: asset)?.url
        if source == nil {
            source = await Self.urlAsset(of: asset, allowingDownload: true) { progress(.downloading($0)) }?.url
        }
        try Task.checkCancellation()
        guard let source else { throw LibraryError.unavailable }

        let output = try await Self.export(source, preset: quality.exportPreset) { progress(.compressing($0)) }
        let date = asset.creationDate
        let location = asset.location
        let isFavorite = asset.isFavorite
        let created = OSAllocatedUnfairLock<String?>(initialState: nil)
        defer { try? FileManager.default.removeItem(at: output) }
        try await PHPhotoLibrary.shared().performChanges {
            let request = PHAssetCreationRequest.forAsset()
            request.addResource(with: .video, fileURL: output, options: nil)
            request.creationDate = date
            request.location = location
            request.isFavorite = isFavorite
            let newID = request.placeholderForCreatedAsset?.localIdentifier
            created.withLock { $0 = newID }
        }
        guard let newID = created.withLock({ $0 }) else { throw LibraryError.saveFailed }

        return newID
    }

    func changes() -> AsyncStream<Void> {
        let (stream, continuation) = AsyncStream.makeStream(of: Void.self, bufferingPolicy: .bufferingNewest(1))
        let observer = LibraryChangeObserver(continuation: continuation)
        PHPhotoLibrary.shared().register(observer)
        continuation.onTermination = { _ in
            PHPhotoLibrary.shared().unregisterChangeObserver(observer)
        }
        return stream
    }

    // MARK: - PhotoKit

    private static func asset(_ id: String) -> PHAsset? {
        PHAsset.fetchAssets(withLocalIdentifiers: [id], options: nil).firstObject
    }

    @concurrent
    private static func fetchAll() async -> [MediaItem] {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        options.includeAssetSourceTypes = [.typeUserLibrary]
        let result = PHAsset.fetchAssets(with: options)
        var items: [MediaItem] = []
        items.reserveCapacity(result.count)
        result.enumerateObjects { asset, _, _ in
            if let item = MediaItem(asset: asset) {
                items.append(item)
            }
        }
        return items
    }

    @concurrent
    private static func sizes(of ids: [String]) async -> [String: ItemSize] {
        var sizes: [String: ItemSize] = [:]
        PHAsset.fetchAssets(withLocalIdentifiers: ids, options: nil).enumerateObjects { asset, _, _ in
            var total: Int64 = 0
            var paired: Int64 = 0
            for resource in PHAssetResource.assetResources(for: asset) {
                // The size PhotoKit knows without reading the file.
                let bytes = (resource.value(forKey: "fileSize") as? NSNumber)?.int64Value ?? 0
                total += bytes
                if resource.type == .pairedVideo || resource.type == .fullSizePairedVideo {
                    paired += bytes
                }
            }
            sizes[asset.localIdentifier] = ItemSize(bytes: total, pairedVideoBytes: paired, modified: asset.modificationDate)
        }
        return sizes
    }

    @concurrent
    private static func userAlbums() async -> [Album] {
        var albums: [Album] = []
        PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil).enumerateObjects { collection, _, _ in
            let count = PHAsset.fetchAssets(in: collection, options: nil).count
            if count > 0 {
                albums.append(Album(id: collection.localIdentifier, title: collection.localizedTitle ?? "", count: count))
            }
        }
        return albums
    }

    @concurrent
    private static func ids(inAlbum albumID: String) async -> [String] {
        guard let collection = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [albumID], options: nil).firstObject else { return [] }

        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        var ids: [String] = []
        PHAsset.fetchAssets(in: collection, options: options).enumerateObjects { asset, _, _ in
            ids.append(asset.localIdentifier)
        }
        return ids
    }

    private static func requestImage(of asset: PHAsset, side: CGFloat, mode: PHImageRequestOptionsDeliveryMode) async -> UIImage? {
        let options = PHImageRequestOptions()
        options.deliveryMode = mode
        options.resizeMode = .fast
        options.isNetworkAccessAllowed = false
        let requestID = OSAllocatedUnfairLock<PHImageRequestID?>(initialState: nil)
        return await withTaskCancellationHandler {
            await withCheckedContinuation { continuation in
                let id = PHImageManager.default().requestImage(
                    for: asset,
                    targetSize: CGSize(width: side, height: side),
                    contentMode: .aspectFit,
                    options: options
                ) { image, _ in
                    // High quality and fast formats call back once.
                    continuation.resume(returning: image)
                }
                requestID.withLock { $0 = id }
            }
        } onCancel: {
            if let id = requestID.withLock({ $0 }) {
                PHImageManager.default().cancelImageRequest(id)
            }
        }
    }

    private static func imageData(of asset: PHAsset) async -> Data? {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = false
        options.version = .current
        return await withCheckedContinuation { continuation in
            PHImageManager.default().requestImageDataAndOrientation(for: asset, options: options) { data, _, _, _ in
                continuation.resume(returning: data)
            }
        }
    }

    /// The video's file. With `allowingDownload`, a video kept only in iCloud is downloaded,
    /// reporting progress; cancelling the task cancels the request.
    private static func urlAsset(
        of asset: PHAsset,
        allowingDownload: Bool = false,
        progress: (@Sendable (Double) -> Void)? = nil
    ) async -> AVURLAsset? {
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = allowingDownload
        if let progress {
            options.progressHandler = { fraction, _, _, _ in progress(fraction) }
        }
        options.deliveryMode = .highQualityFormat
        options.version = .current
        let requestID = OSAllocatedUnfairLock<PHImageRequestID?>(initialState: nil)
        let url: URL? = await withTaskCancellationHandler {
            await withCheckedContinuation { continuation in
                let id = PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { avAsset, _, _ in
                    continuation.resume(returning: (avAsset as? AVURLAsset)?.url)
                }
                requestID.withLock { $0 = id }
            }
        } onCancel: {
            if let id = requestID.withLock({ $0 }) {
                PHImageManager.default().cancelImageRequest(id)
            }
        }
        return url.map { AVURLAsset(url: $0) }
    }

    private static func cameraMetadata(in data: Data) -> (camera: String?, lens: String?) {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any] else { return (nil, nil) }

        let tiff = properties[kCGImagePropertyTIFFDictionary] as? [CFString: Any]
        let exif = properties[kCGImagePropertyExifDictionary] as? [CFString: Any]
        let make = tiff?[kCGImagePropertyTIFFMake] as? String
        let model = tiff?[kCGImagePropertyTIFFModel] as? String
        // Apple models already start with the make ("iPhone 16 Pro"): do not repeat it.
        let camera: String? = switch (make, model) {
        case let (make?, model?) where model.hasPrefix(make) || make == "Apple": model
        case let (make?, model?): "\(make) \(model)"
        case let (nil, model?): model
        case let (make?, nil): make
        case (nil, nil): nil
        }
        return (camera, exif?[kCGImagePropertyExifLensModel] as? String)
    }

    @concurrent
    private static func export(_ source: URL, preset: String, progress: @escaping @Sendable (Double) -> Void) async throws -> URL {
        guard let session = AVAssetExportSession(asset: AVURLAsset(url: source), presetName: preset) else { throw LibraryError.unavailable }

        let output = URL.temporaryDirectory.appending(path: "\(UUID().uuidString).mp4")
        if #available(iOS 18, *) {
            // The session reports its own states while it exports: AVFoundation documents
            // reading them from another task, which the compiler cannot see.
            nonisolated(unsafe) let exporting = session
            async let finished: Void = exporting.export(to: output, as: .mp4)
            for await state in session.states(updateInterval: 0.25) {
                if case .exporting(let exportProgress) = state {
                    progress(exportProgress.fractionCompleted)
                }
            }
            try await finished
        } else {
            session.outputURL = output
            session.outputFileType = .mp4
            await session.export()
            guard session.status == .completed else { throw session.error ?? LibraryError.saveFailed }
        }
        return output
    }
}
