import CoreGraphics
import Foundation
import Testing
@testable import SbuGrid

struct GridExportTests {
    let folder = URL.temporaryDirectory.appending(path: "GridExportTests-\(UUID().uuidString)", directoryHint: .isDirectory)

    init() throws {
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
    }

    /// The red, green and blue of a pixel, 0…255.
    private func pixel(_ image: CGImage, x: Int, y: Int) throws -> [UInt8] {
        var data = [UInt8](repeating: 0, count: 4)
        let context = try #require(CGContext(
            data: &data, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4,
            space: CGColorSpace(name: CGColorSpace.sRGB)!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ))
        context.draw(image, in: CGRect(x: -x, y: y - image.height + 1, width: image.width, height: image.height))
        return Array(data.prefix(3))
    }

    @Test func theImageIsAtThePhotosOwnPixels() throws {
        let picture = TestImage.make(width: 900, height: 1200)
        let image = try #require(GridExport.image(of: picture, settings: GridSettings(), rule: .square(columns: 3)))
        #expect(image.width == 900)
        #expect(image.height == 1200)
    }

    @Test func theLinesAreDrawnWhereTheLayoutSays() throws {
        var settings = GridSettings()
        settings.opacity = 1
        settings.lineWidth = 8
        let picture = TestImage.make(width: 900, height: 900)
        let image = try #require(GridExport.image(of: picture, settings: settings, rule: .square(columns: 3)))
        // The test photo is blue (51, 128, 204); on the line at x = 300 the ink is dark.
        let line = try pixel(image, x: 300, y: 150)
        let cell = try pixel(image, x: 150, y: 150)
        #expect(line.allSatisfy { $0 < 60 }, "\(line)")
        #expect(cell[2] > 150, "\(cell)")
    }

    @Test func blackAndWhiteHasNoColour() throws {
        var settings = GridSettings()
        settings.isBlackAndWhite = true
        let image = try #require(GridExport.image(of: TestImage.make(width: 300, height: 300), settings: settings, rule: .square(columns: 3)))
        let cell = try pixel(image, x: 50, y: 50)
        #expect(Int(cell.max()!) - Int(cell.min()!) <= 2, "\(cell)")
    }

    @Test func thePDFIsOnePageTheSizeOfTheSheet() throws {
        var paper = PaperSettings(locale: Locale(identifier: "it_IT"))
        paper.format = .a4
        let page = try #require(paper.pageSize)
        let url = folder.appending(path: "a4.pdf")
        let rule = try #require(paper.cellRule)
        try GridExport.writePDF(of: TestImage.make(width: 707, height: 1000), settings: GridSettings(), rule: rule, pageSize: page, to: url)
        let document = try #require(CGPDFDocument(url as CFURL))
        #expect(document.numberOfPages == 1)
        let box = try #require(document.page(at: 1)?.getBoxRect(.mediaBox))
        #expect(abs(box.width - 595.28) < 0.01)
        #expect(abs(box.height - 841.89) < 0.01)
    }

    @Test(arguments: [CGSize.zero, CGSize(width: -1, height: 100), CGSize(width: CGFloat.nan, height: 100)])
    func aPDFWithoutASheetIsAnError(page: CGSize) {
        #expect(throws: ExportError.noSheet) {
            try GridExport.writePDF(of: TestImage.make(width: 10, height: 10), settings: GridSettings(), rule: .square(columns: 2), pageSize: page, to: folder.appending(path: "x.pdf"))
        }
    }

    @Test func exportMakesTheImageAndThePDFOnlyWithASheet() async throws {
        let picture = TestImage.make(width: 400, height: 300)
        let withSheet = try await ExportedFiles.make(picture: picture, settings: GridSettings(), rule: .square(columns: 4), pageSize: CGSize(width: 400, height: 300), in: folder)
        #expect(FileManager.default.fileExists(atPath: withSheet.imageURL.path(percentEncoded: false)))
        let pdf = try #require(withSheet.pdfURL)
        #expect(FileManager.default.fileExists(atPath: pdf.path(percentEncoded: false)))
        #expect(withSheet.imageURL.pathExtension == "jpg")
        #expect(pdf.pathExtension == "pdf")

        let without = try await ExportedFiles.make(picture: picture, settings: GridSettings(), rule: .square(columns: 4), pageSize: nil, in: folder)
        #expect(without.pdfURL == nil)
        let reopened = try PhotoDecoder.image(from: Data(contentsOf: without.imageURL))
        #expect(reopened.width == 400)
    }

    @Test func theExportFolderStartsEmpty() throws {
        let first = try GridExport.folder()
        try Data("old".utf8).write(to: first.appending(path: "old.txt"))
        let second = try GridExport.folder()
        #expect(try FileManager.default.contentsOfDirectory(atPath: second.path(percentEncoded: false)).isEmpty)
    }
}
