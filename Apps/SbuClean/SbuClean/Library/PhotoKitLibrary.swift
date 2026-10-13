import AVFoundation
import ImageIO
import Photos
import UIKit
import os

/// The real photo library, through PhotoKit, on the device only.
///
/// Network access stays off: pictures and videos kept only in iCloud show their local
/// thumbnail and are not downloaded.
nonisolated final class PhotoKitLibrary: PhotoLibrary {
    /// The side of the picture Vision analyses.
    private static let analysisSide: CGFloat = 512

    func currentAccess() -> LibraryAccess {
        LibraryAccess(status: PHPhotoLibrary.authorizationStatus(for: .readWrite))
    }

    func requestAccess() async -> LibraryAccess {
        LibraryAccess(status: await PHPhotoLibrary.requestAuthorization(for: .readWrite))
    }

    func fetchItems() async -> [MediaItem] {
        await Self.fetchAll()
    }

    func measure(_ ids: [String]) async -> [String: ItemSize] {
        await Self.sizes(of: ids)
    }

    func albums() async -> [Album] {
        await Self.userAlbums()
    }

    func itemIDs(inAlbum albumID: String) async -> [String] {
        await Self.ids(inAlbum: albumID)
    }

    func image(for id: String, pixelSide: CGFloat) async -> UIImage? {
        guard let asset = Self.asset(id) else { return nil }

        if let image = await Self.requestImage(of: asset, side: pixelSide, mode: .highQualityFormat) {
            return image
        }
        // Kept only in iCloud: the small local copy is better than nothing.
        return await Self.requestImage(of: asset, side: pixelSide, mode: .fastFormat)
    }

    func analyze(_ id: String) async -> ImageAnalysis? {
        guard let image = await image(for: id, pixelSide: Self.analysisSide) else { return nil }

        return await Self.analyze(image)
    }

    func videoURL(for id: String) async -> URL? {
        guard let asset = Self.asset(id) else { return nil }

        return await Self.urlAsset(of: asset)?.url
    }

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

    func delete(_ ids: [String]) async throws {
        do {
            try await PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.deleteAssets(PHAsset.fetchAssets(withLocalIdentifiers: ids, options: nil))
            }
        } catch let error as PHPhotosError where error.code == .userCancelled {
            throw LibraryError.cancelled
        }
    }

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

    func saveCompressed(video id: String, quality: CompressionQuality) async throws -> String {
        guard let asset = Self.asset(id), let source = await Self.urlAsset(of: asset)?.url else { throw LibraryError.unavailable }

        let output = try await Self.export(source, preset: quality.exportPreset)
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

    private static func urlAsset(of asset: PHAsset) async -> AVURLAsset? {
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = false
        options.deliveryMode = .highQualityFormat
        options.version = .current
        let url: URL? = await withCheckedContinuation { continuation in
            PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { avAsset, _, _ in
                continuation.resume(returning: (avAsset as? AVURLAsset)?.url)
            }
        }
        return url.map { AVURLAsset(url: $0) }
    }

    @concurrent
    private static func analyze(_ image: UIImage) async -> ImageAnalysis? {
        guard let cgImage = image.cgImage else { return nil }

        return ImageAnalyzer.analyze(cgImage)
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
    private static func export(_ source: URL, preset: String) async throws -> URL {
        guard let session = AVAssetExportSession(asset: AVURLAsset(url: source), presetName: preset) else { throw LibraryError.unavailable }

        let output = URL.temporaryDirectory.appending(path: "\(UUID().uuidString).mp4")
        if #available(iOS 18, *) {
            try await session.export(to: output, as: .mp4)
        } else {
            session.outputURL = output
            session.outputFileType = .mp4
            await session.export()
            guard session.status == .completed else { throw session.error ?? LibraryError.saveFailed }
        }
        return output
    }
}
