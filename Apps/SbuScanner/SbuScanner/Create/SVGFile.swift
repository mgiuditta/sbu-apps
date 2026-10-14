import CoreTransferable
import Foundation
import UniformTypeIdentifiers

/// A code as an SVG file, for print and design at any size.
struct SVGFile: Transferable {
    let name: String
    let svg: String

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(exportedContentType: .svg) { file in
            let url = URL.temporaryDirectory.appending(path: file.name + ".svg")
            try Data(file.svg.utf8).write(to: url, options: .atomic)
            return SentTransferredFile(url)
        }
    }
}
