import CoreTransferable
import SwiftData
import UniformTypeIdentifiers

/// The whole inventory as a ZIP with the CSV and every photo, written when you pick where it goes.
struct InventoryArchiveFile: Transferable {
    let container: ModelContainer

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(exportedContentType: .zip) { file in
            SentTransferredFile(try await file.write())
        }
    }

    @MainActor private func write() throws -> URL {
        try InventoryExport.writeArchive(from: container.mainContext)
    }
}
