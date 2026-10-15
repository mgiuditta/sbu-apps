import ImageIO
import Testing
import UIKit
import UniformTypeIdentifiers
@testable import SbuInventory

struct PhotoProcessorTests {
    /// A JPEG `width`×`height` that its EXIF says to turn by 90° (orientation 6), as an iPhone shoots in portrait.
    private func rotatedJPEG(width: Int, height: Int) throws -> Data {
        let context = try #require(CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0,
                                             space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue))
        context.setFillColor(UIColor.systemTeal.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        let image = try #require(context.makeImage())
        let output = NSMutableData()
        let destination = try #require(CGImageDestinationCreateWithData(output, UTType.jpeg.identifier as CFString, 1, nil))
        CGImageDestinationAddImage(destination, image, [kCGImagePropertyOrientation: 6] as CFDictionary)
        #expect(CGImageDestinationFinalize(destination))
        return output as Data
    }

    private func pixelSize(_ data: Data) throws -> (width: Int, height: Int, orientation: Int) {
        let source = try #require(CGImageSourceCreateWithData(data as CFData, nil))
        let properties = try #require(CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any])
        return (properties[kCGImagePropertyPixelWidth] as? Int ?? 0,
                properties[kCGImagePropertyPixelHeight] as? Int ?? 0,
                properties[kCGImagePropertyOrientation] as? Int ?? 1)
    }

    @Test func largePhotoIsTurnedUprightAndShrunkTo2048() throws {
        let processed = try #require(PhotoProcessor.process(try rotatedJPEG(width: 4000, height: 3000)))
        let size = try pixelSize(processed.data)
        #expect(size.width == 1536)
        #expect(size.height == 2048)
        #expect(size.orientation == 1)
        let thumbnail = try pixelSize(processed.thumbnail)
        #expect(max(thumbnail.width, thumbnail.height) == 256)
        #expect(thumbnail.height > thumbnail.width)
    }

    @Test func smallPhotoKeepsItsSize() throws {
        let processed = try #require(PhotoProcessor.process(try rotatedJPEG(width: 600, height: 400)))
        let size = try pixelSize(processed.data)
        #expect(size.width == 400)
        #expect(size.height == 600)
    }

    @Test func ownPhotoComesBackFromAnArchiveUntouched() throws {
        let processed = try #require(PhotoProcessor.process(try rotatedJPEG(width: 800, height: 600)))
        #expect(PhotoProcessor.prepareImported(processed.data)?.data == processed.data)
    }

    @Test func foreignPhotoInAnArchiveIsProcessed() throws {
        let foreign = try rotatedJPEG(width: 3000, height: 1000)
        let prepared = try #require(PhotoProcessor.prepareImported(foreign))
        #expect(prepared.data != foreign)
        #expect(try pixelSize(prepared.data).height == 2048)
    }

    @Test func cameraImageIsShrunk() throws {
        let image = UIGraphicsImageRenderer(size: CGSize(width: 3000, height: 4000), format: {
            let format = UIGraphicsImageRendererFormat()
            format.scale = 1
            return format
        }()).image { context in
            UIColor.systemOrange.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 3000, height: 4000))
        }
        let processed = try #require(PhotoProcessor.process(image))
        let size = try pixelSize(processed.data)
        #expect(size.width == 1536)
        #expect(size.height == 2048)
    }

    @Test func notAnImageIsRejected() {
        #expect(PhotoProcessor.process(Data("nope".utf8)) == nil)
        #expect(PhotoProcessor.prepareImported(Data("nope".utf8)) == nil)
    }
}
