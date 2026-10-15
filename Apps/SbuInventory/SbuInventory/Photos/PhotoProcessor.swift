import ImageIO
import UIKit
import UniformTypeIdentifiers

/// Turns any photo into one the inventory keeps: turned upright from its EXIF orientation, at most
/// 2048 px on the long side, saved as HEIC (JPEG where HEIC can't be written), with a 256 px thumbnail.
nonisolated enum PhotoProcessor {
    static let maxPixelSize = 2048
    static let thumbnailPixelSize = 256
    /// Photos an item keeps at most.
    static let maxPhotos = 8

    /// From the bytes of a photo in any format ImageIO reads (HEIC, JPEG, PNG…).
    static func process(_ data: Data) -> ProcessedPhoto? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let image = downsampled(source, maxPixelSize: maxPixelSize) else { return nil }
        return encode(image)
    }

    /// From a photo just taken with the camera; UIKit already knows which way is up.
    static func process(_ image: UIImage) -> ProcessedPhoto? {
        let longSide = max(image.size.width, image.size.height)
        guard longSide > 0 else { return nil }
        let scale = min(1, CGFloat(maxPixelSize) / longSide)
        let size = CGSize(width: (image.size.width * scale).rounded(), height: (image.size.height * scale).rounded())
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = true
        let upright = UIGraphicsImageRenderer(size: size, format: format).image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
        guard let cgImage = upright.cgImage else { return nil }
        return encode(cgImage)
    }

    /// A photo from an imported archive: kept as it is when this app wrote it (upright, small enough,
    /// HEIC or JPEG), so a round trip never loses quality; anything else goes through `process(_:)`.
    static func prepareImported(_ data: Data) -> ProcessedPhoto? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let type = CGImageSourceGetType(source).flatMap({ UTType($0 as String) }),
              type.conforms(to: .heic) || type.conforms(to: .jpeg),
              let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
              let width = properties[kCGImagePropertyPixelWidth] as? Int,
              let height = properties[kCGImagePropertyPixelHeight] as? Int,
              max(width, height) <= maxPixelSize,
              (properties[kCGImagePropertyOrientation] as? Int ?? 1) == 1,
              let thumbnail = downsampled(source, maxPixelSize: thumbnailPixelSize).flatMap({ write($0, as: .jpeg, quality: 0.8) })
        else { return process(data) }
        return ProcessedPhoto(data: data, thumbnail: thumbnail)
    }

    /// The image of a kept photo, upright, no larger than `maxPixelSize`, for the screen.
    static func image(_ data: Data, maxPixelSize: Int) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let image = downsampled(source, maxPixelSize: maxPixelSize) else { return nil }
        return UIImage(cgImage: image)
    }

    /// The file extension of a kept photo: `heic`, or `jpg` where HEIC couldn't be written.
    static func fileExtension(of data: Data) -> String {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let type = CGImageSourceGetType(source).flatMap({ UTType($0 as String) }) else { return "heic" }
        return type.conforms(to: .heic) ? "heic" : (type.preferredFilenameExtension ?? "jpg")
    }

    private static func downsampled(_ source: CGImageSource, maxPixelSize: Int) -> CGImage? {
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize,
        ]
        return CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary)
    }

    private static func encode(_ image: CGImage) -> ProcessedPhoto? {
        guard let data = write(image, as: .heic, quality: 0.8) ?? write(image, as: .jpeg, quality: 0.85),
              let source = CGImageSourceCreateWithData(data as CFData, nil),
              let small = downsampled(source, maxPixelSize: thumbnailPixelSize),
              let thumbnail = write(small, as: .jpeg, quality: 0.8) else { return nil }
        return ProcessedPhoto(data: data, thumbnail: thumbnail)
    }

    private static func write(_ image: CGImage, as type: UTType, quality: Double) -> Data? {
        let output = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(output, type.identifier as CFString, 1, nil) else { return nil }
        CGImageDestinationAddImage(destination, image, [kCGImageDestinationLossyCompressionQuality: quality] as CFDictionary)
        guard CGImageDestinationFinalize(destination) else { return nil }
        return output as Data
    }
}
