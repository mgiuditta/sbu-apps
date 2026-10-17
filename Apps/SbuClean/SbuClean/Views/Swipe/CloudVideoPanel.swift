import SbuKit
import SwiftUI

/// Over the frame of a video kept only in iCloud: what it is, and Scarica, or the progress with
/// Annulla, or Riprova after a failed download.
struct CloudVideoPanel: View {
    let isDownloading: Bool
    let failed: Bool
    let fraction: Double
    let download: () -> Void
    let cancel: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space2) {
            if isDownloading {
                ProgressView(value: fraction) {
                    Text("Scarico da iCloud: \(fraction.formatted(.percent.precision(.fractionLength(0))))")
                        .font(SbuTheme.footnote)
                        .monospacedDigit()
                        .foregroundStyle(SbuTheme.ink)
                }
                Button("Annulla", action: cancel)
                    .buttonStyle(SbuFieldPillStyle())
            } else {
                Label(failed ? "Non è stato possibile scaricare il video. Controlla la connessione." : "Questo video è solo in iCloud.", systemImage: "icloud")
                    .font(SbuTheme.footnote)
                    .foregroundStyle(SbuTheme.ink)
                Button(failed ? "Riprova" : "Scarica da iCloud", action: download)
                    .buttonStyle(SbuFieldPillStyle())
            }
        }
        .padding(SbuTheme.space3)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(SbuTheme.paper, in: .rect(cornerRadius: SbuTheme.radiusCard))
    }
}

#Preview("Light") {
    VStack {
        CloudVideoPanel(isDownloading: false, failed: false, fraction: 0, download: {}, cancel: {})
        CloudVideoPanel(isDownloading: true, failed: false, fraction: 0.42, download: {}, cancel: {})
    }
    .padding()
    .background(SbuTheme.surfaceSunken)
    .environment(\.sbuAccent, .clean)
}

#Preview("Dark") {
    CloudVideoPanel(isDownloading: false, failed: true, fraction: 0, download: {}, cancel: {})
        .padding()
        .background(SbuTheme.surfaceSunken)
        .environment(\.sbuAccent, .clean)
        .preferredColorScheme(.dark)
}
