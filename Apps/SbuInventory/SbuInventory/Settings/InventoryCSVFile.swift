import CoreTransferable
import SwiftData
import UniformTypeIdentifiers

/// The whole inventory as a CSV file, written when you pick where it goes in the share sheet.
struct InventoryCSVFile: Transferable {
    let container: ModelContainer

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(exportedContentType: .commaSeparatedText) { file in
            SentTransferredFile(try await file.write())
        }
    }

    @MainActor private func write() throws -> URL {
        try InventoryExport.writeCSV(from: container.mainContext)
    }
}
