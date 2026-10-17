import SbuKit
import SwiftUI

/// The row mark and the count, as in the original: "5 video compressi e salvati in Foto".
struct DoneHeader: View {
    let summary: BatchSummary
    let access: LibraryAccess

    var body: some View {
        HStack(spacing: SbuTheme.space2) {
            // Filled when something got lighter, empty when nothing did: the words say which.
            SbuRowMark(filled: summary.compressed > 0)

            Text(message)
                .font(SbuTheme.headline)
                .foregroundStyle(SbuTheme.ink)
                .accessibilityAddTraits(.isHeader)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var message: LocalizedStringKey {
        if summary.compressed == 0 {
            return "Nessun video è diventato più leggero"
        }
        if summary.savedToPhotos == summary.compressed {
            return "\(summary.compressed) video compressi e salvati in Foto"
        }
        return "\(summary.compressed) video compressi"
    }
}

#Preview("Light") {
    DoneHeader(summary: BatchSummary(jobs: []), access: .full)
        .padding(SbuTheme.space4)
}

#Preview("Dark") {
    DoneHeader(summary: BatchSummary(jobs: []), access: .denied)
        .padding(SbuTheme.space4)
        .preferredColorScheme(.dark)
}
