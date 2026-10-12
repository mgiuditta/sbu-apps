import CoreTransferable
import Foundation
import UniformTypeIdentifiers

/// The habits, their history and the start of the day as a readable JSON file, for Esporta.
/// The file is a `HabitsFile` with its version, so Importa can read it back.
nonisolated struct HabitsExport: Transferable {
    let file: HabitsFile
    /// The day of the export, in the file name.
    let date: Date

    /// "Sbu Habits 2026-10-12.json": the date sorts and reads the same in every language.
    var fileName: String {
        let day = date.formatted(Date.ISO8601FormatStyle(timeZone: .current).year().month().day())
        return "Sbu Habits \(day).json"
    }

    /// Indented with sorted keys, so the file is readable and two exports of the same data match.
    func data() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(file)
    }

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .json) { export in
            try export.data()
        }
        .suggestedFileName { $0.fileName }
    }
}
