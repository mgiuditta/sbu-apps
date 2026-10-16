import SbuKit
import SwiftUI

/// The check and the count, as in the original: "5 video compressi e salvati in Foto".
struct DoneHeader: View {
    let summary: BatchSummary
    let access: LibraryAccess

    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space2) {
            Image(systemName: summary.compressed > 0 ? "checkmark.circle.fill" : "exclamationmark.triangle")
                .font(SbuTheme.largeTitle)
                .fontWeight(.medium)
                .imageScale(.medium)
                .foregroundStyle(summary.compressed > 0 ? SbuTheme.success : SbuTheme.warning)
                .accessibilityHidden(true)

            Text(message)
                .font(SbuTheme.headline)
                .foregroundStyle(SbuTheme.ink)
                .accessibilityAddTraits(.isHeader)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        // In line with the figure's caption inside its card.
        .padding(.horizontal, SbuTheme.space4)
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
