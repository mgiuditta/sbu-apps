import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

/// Pictures made in the tests, in any format ImageIO writes.
enum TestImage {
    /// A plain picture of `width` × `height` pixels.
    static func make(width: Int, height: Int) -> CGImage {
        // ponytail: an RGBA context of a positive size always exists and always makes an image.
        let context = CGContext(
            data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0,
            space: CGColorSpace(name: CGColorSpace.sRGB)!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )!
        context.setFillColor(CGColor(red: 0.2, green: 0.5, blue: 0.8, alpha: 1))
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        return context.makeImage()!
    }

    /// The picture encoded as `type`, with an EXIF orientation when given.
    static func data(width: Int, height: Int, type: UTType = .png, orientation: CGImagePropertyOrientation? = nil) -> Data {
        let data = NSMutableData()
        let destination = CGImageDestinationCreateWithData(data, type.identifier as CFString, 1, nil)!
        var properties: [CFString: Any] = [:]
        if let orientation {
            properties[kCGImagePropertyOrientation] = orientation.rawValue
        }
        CGImageDestinationAddImage(destination, make(width: width, height: height), properties as CFDictionary)
        CGImageDestinationFinalize(destination)
        return data as Data
    }
}
