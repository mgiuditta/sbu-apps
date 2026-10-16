import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

/// Turns the data the Photos picker gives into a picture to draw on.
///
/// Through ImageIO, so HEIC, JPEG, PNG and RAW previews all read the same way: the camera's
/// rotation is applied, and a 48-megapixel photo is shrunk to `maximumPixelSize` on its longer
/// side, which is plenty for a grid and keeps the memory low.
nonisolated enum PhotoDecoder {
    static let maximumPixelSize = 4096

    /// - Throws: `PhotoError.unreadable` when the data is not a picture.
    static func image(from data: Data, maximumPixelSize: Int = maximumPixelSize) throws(PhotoError) -> CGImage {
        guard data.isEmpty == false, maximumPixelSize > 0,
              let source = CGImageSourceCreateWithData(data as CFData, [kCGImageSourceShouldCache: false] as CFDictionary),
              CGImageSourceGetCount(source) > 0
        else { throw .unreadable }
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceThumbnailMaxPixelSize: maximumPixelSize,
        ]
        guard let image = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary),
              image.width > 0, image.height > 0
        else { throw .unreadable }
        return image
    }

    /// The picture as JPEG, to keep it between launches.
    static func jpegData(from image: CGImage, quality: Double = 0.9) -> Data? {
        let data = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(data, UTType.jpeg.identifier as CFString, 1, nil) else { return nil }
        CGImageDestinationAddImage(destination, image, [kCGImageDestinationLossyCompressionQuality: quality] as CFDictionary)
        guard CGImageDestinationFinalize(destination) else { return nil }
        return data as Data
    }
}
