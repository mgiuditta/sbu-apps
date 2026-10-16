import SbuKit
import SwiftUI

/// What did not go as planned, one line each, and the question about the originals.
struct DoneNotes: View {
    let summary: BatchSummary
    let access: LibraryAccess
    let deletion: Deletion

    @Environment(\.openURL) private var openURL

    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space3) {
            if summary.notSmaller > 0 {
                Text("Già leggeri, restano come sono: \(summary.notSmaller)")
            }
            if summary.failed > 0 {
                Label("Non compressi: \(summary.failed)", systemImage: "exclamationmark.triangle")
                    .foregroundStyle(SbuTheme.danger)
            }
            if summary.cancelled > 0 {
                Text("Interrotti: \(summary.cancelled)")
            }
            if summary.compressed > summary.savedToPhotos {
                VStack(alignment: .leading, spacing: SbuTheme.space2) {
                    Label(
                        access.canSave
                            ? "Alcune copie non sono state salvate in Foto. Puoi condividerle."
                            : "Foto non consentito: le copie non sono in Foto. Condividile, o consenti l'accesso.",
                        systemImage: "exclamationmark.triangle"
                    )
                    .foregroundStyle(SbuTheme.warning)
                    if !access.canSave {
                        SbuButton("Apri Impostazioni", kind: .secondary, action: openSettings)
                    }
                }
            }

            switch deletion {
            case .deleted(let count):
                Label("Originali eliminati: \(count). Restano in Eliminati di recente per 30 giorni.", systemImage: "checkmark.circle")
                    .foregroundStyle(SbuTheme.success)
            case .failed:
                Label("Foto non ha eliminato gli originali.", systemImage: "exclamationmark.triangle")
                    .foregroundStyle(SbuTheme.danger)
            case .idle, .deleting:
                if !summary.deletableIDs.isEmpty {
                    Text("Cosa vuoi fare con i video originali?")
                }
            }
        }
        .font(SbuTheme.subheadline)
        .foregroundStyle(SbuTheme.inkMuted)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, SbuTheme.space4)
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            openURL(url)
        }
    }
}

#Preview("Light") {
    DoneNotes(summary: BatchSummary(jobs: []), access: .denied, deletion: .deleted(3))
}

#Preview("Dark") {
    DoneNotes(summary: BatchSummary(jobs: []), access: .full, deletion: .failed)
        .preferredColorScheme(.dark)
}
