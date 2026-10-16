import CoreGraphics
import Foundation
import SwiftUI

/// The photo with its grid as an image at the photo's own pixels, and as a PDF the size of the
/// sheet, from the same `GridPicture` the screen shows: what you export is what you saw.
enum GridExport {
    /// The picture and its grid at the picture's size in pixels.
    static func image(of picture: CGImage, settings: GridSettings, rule: CellRule) -> CGImage? {
        let size = CGSize(width: picture.width, height: picture.height)
        let renderer = ImageRenderer(content: GridPicture(image: picture, settings: settings, rule: rule).frame(width: size.width, height: size.height))
        renderer.scale = 1
        renderer.isOpaque = true
        return renderer.cgImage
    }

    /// A one-page PDF of `pageSize` points, the picture filling the page: printed at 100%, the
    /// cells measure what the sheet says.
    static func writePDF(of picture: CGImage, settings: GridSettings, rule: CellRule, pageSize: CGSize, to url: URL) throws {
        guard pageSize.width.isFinite, pageSize.height.isFinite, pageSize.width > 0, pageSize.height > 0 else {
            throw ExportError.noSheet
        }
        let renderer = ImageRenderer(content: GridPicture(image: picture, settings: settings, rule: rule).frame(width: pageSize.width, height: pageSize.height))
        var written = false
        renderer.render { size, draw in
            var box = CGRect(origin: .zero, size: size)
            guard let context = CGContext(url as CFURL, mediaBox: &box, nil) else { return }
            context.beginPDFPage(nil)
            draw(context)
            context.endPDFPage()
            context.closePDF()
            written = true
        }
        guard written else { throw ExportError.notWritten }
    }

    /// The folder the exported files go in before they are shared, emptied at each export.
    static func folder() throws -> URL {
        let folder = URL.temporaryDirectory.appending(path: "Export", directoryHint: .isDirectory)
        try? FileManager.default.removeItem(at: folder)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder
    }
}
