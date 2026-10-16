import CoreTransferable
import UniformTypeIdentifiers

/// A video picked in Photos, copied into the work folder with its name.
nonisolated struct VideoFile: Transferable {
    let url: URL

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(importedContentType: .movie) { received in
            VideoFile(url: try WorkFolder.copy(received.file))
        }
    }
}
