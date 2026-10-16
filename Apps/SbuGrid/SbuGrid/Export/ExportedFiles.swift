import CoreGraphics
import Foundation

/// What an export made: the image to save or share, and the PDF when there is a sheet.
struct ExportedFiles {
    let image: CGImage
    let imageURL: URL
    let pdfURL: URL?

    /// Draws and writes the files for the picture on screen.
    /// - Parameters:
    ///   - pageSize: The sheet in PDF points; `nil` makes no PDF.
    ///   - folder: Where the files go.
    static func make(picture: CGImage, settings: GridSettings, rule: CellRule, pageSize: CGSize?, in folder: URL) async throws -> ExportedFiles {
        guard let image = GridExport.image(of: picture, settings: settings, rule: rule) else { throw ExportError.notWritten }
        let imageURL = folder.appending(path: String(localized: "Sbu Grid.jpg", comment: "File name of the exported photo with the grid."))
        try await write(image, to: imageURL)
        var pdfURL: URL?
        if let pageSize {
            let url = folder.appending(path: String(localized: "Sbu Grid in scala.pdf", comment: "File name of the PDF to print at real size."))
            try GridExport.writePDF(of: picture, settings: settings, rule: rule, pageSize: pageSize, to: url)
            pdfURL = url
        }
        return ExportedFiles(image: image, imageURL: imageURL, pdfURL: pdfURL)
    }

    /// Encodes off the main thread: a 12-megapixel JPEG takes a moment.
    @concurrent
    private static func write(_ image: CGImage, to url: URL) async throws {
        guard let data = PhotoDecoder.jpegData(from: image) else { throw ExportError.notWritten }
        try data.write(to: url, options: .atomic)
    }
}
