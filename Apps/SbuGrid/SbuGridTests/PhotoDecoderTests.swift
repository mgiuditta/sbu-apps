import CoreGraphics
import Foundation
import ImageIO
import Testing
import UniformTypeIdentifiers
@testable import SbuGrid

struct PhotoDecoderTests {
    @Test(arguments: [UTType.png, .jpeg, .heic, .tiff])
    func readsEveryCommonFormat(type: UTType) throws {
        let image = try PhotoDecoder.image(from: TestImage.data(width: 300, height: 200, type: type))
        #expect(image.width == 300)
        #expect(image.height == 200)
    }

    @Test(arguments: [
        (CGImagePropertyOrientation.right, 200, 300),
        (.left, 200, 300),
        (.up, 300, 200),
        (.down, 300, 200),
    ])
    func turnsThePhotoUpright(orientation: CGImagePropertyOrientation, width: Int, height: Int) throws {
        // A phone held upright stores a landscape picture and says to turn it.
        let data = TestImage.data(width: 300, height: 200, type: .jpeg, orientation: orientation)
        let image = try PhotoDecoder.image(from: data)
        #expect(image.width == width)
        #expect(image.height == height)
    }

    @Test func shrinksALargePhotoToTheLongerSide() throws {
        let image = try PhotoDecoder.image(from: TestImage.data(width: 4000, height: 3000), maximumPixelSize: 1000)
        #expect(image.width == 1000)
        #expect(image.height == 750)
    }

    @Test func neverEnlargesASmallPhoto() throws {
        let image = try PhotoDecoder.image(from: TestImage.data(width: 40, height: 30))
        #expect(image.width == 40)
        #expect(image.height == 30)
    }

    @Test func aOnePixelPhotoOpens() throws {
        let image = try PhotoDecoder.image(from: TestImage.data(width: 1, height: 1))
        #expect(image.width == 1)
    }

    @Test(arguments: [
        Data(),
        Data("not a photo".utf8),
        Data([0xFF, 0xD8, 0xFF, 0xE0]),
        Data(repeating: 0, count: 4096),
    ])
    func dataThatIsNotAPictureIsUnreadable(data: Data) {
        #expect(throws: PhotoError.unreadable) {
            try PhotoDecoder.image(from: data)
        }
    }

    @Test(arguments: [0, -1])
    func anAbsurdMaximumIsUnreadable(maximum: Int) {
        #expect(throws: PhotoError.unreadable) {
            try PhotoDecoder.image(from: TestImage.data(width: 10, height: 10), maximumPixelSize: maximum)
        }
    }

    @Test func aTruncatedFileIsUnreadable() {
        let data = TestImage.data(width: 300, height: 200, type: .png)
        #expect(throws: PhotoError.unreadable) {
            try PhotoDecoder.image(from: data.prefix(40))
        }
    }

    @Test func jpegRoundTripsAtTheSameSize() throws {
        let data = try #require(PhotoDecoder.jpegData(from: TestImage.make(width: 64, height: 48)))
        let image = try PhotoDecoder.image(from: data)
        #expect(image.width == 64)
        #expect(image.height == 48)
    }

    @Test func eachErrorHasAMessage() {
        #expect(PhotoError.unavailable.message.key != PhotoError.unreadable.message.key)
    }
}
