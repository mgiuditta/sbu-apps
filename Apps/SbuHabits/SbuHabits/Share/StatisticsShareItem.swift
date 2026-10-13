import CoreTransferable
import UniformTypeIdentifiers

/// The Statistiche page handed to the share sheet: a PNG drawn only when the sheet or the app
/// chosen asks for it, named after the page and its period. Nothing leaves the phone unless you
/// pick where it goes.
nonisolated struct StatisticsShareItem: Transferable {
    let share: StatisticsShare

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .png) { item in
            guard let data = await StatisticsShareRenderer.png(of: item.share) else {
                throw CocoaError(.fileWriteUnknown)
            }
            return data
        }
        .suggestedFileName { item in item.share.fileName() }
    }
}
