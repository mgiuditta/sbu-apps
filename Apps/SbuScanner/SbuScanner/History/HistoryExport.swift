import CoreTransferable
import Foundation
import UniformTypeIdentifiers

/// The history as a CSV file to share or save in Files.
struct HistoryExport: Transferable {
    let rows: [HistoryCSV.Row]
    let header: [String]

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(exportedContentType: .commaSeparatedText) { export in
            let url = URL.temporaryDirectory.appending(path: String(localized: "Cronologia Sbu Scanner") + ".csv")
            try Data(HistoryCSV.make(export.rows, header: export.header).utf8).write(to: url, options: .atomic)
            return SentTransferredFile(url)
        }
    }
}
