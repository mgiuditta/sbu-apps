import SbuKit
import SwiftUI

/// The progress of a compression: the download from iCloud first if needed, then the copy,
/// with Annulla.
struct CompressionProgressView: View {
    let isDownloading: Bool
    let fraction: Double
    let cancel: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space2) {
            ProgressView(value: fraction) {
                Group {
                    if isDownloading {
                        Text("Scarico da iCloud: \(fraction.formatted(.percent.precision(.fractionLength(0))))")
                    } else {
                        Text("Comprimo: \(fraction.formatted(.percent.precision(.fractionLength(0))))")
                    }
                }
                .font(SbuTheme.subheadline)
                .monospacedDigit()
                .foregroundStyle(SbuTheme.ink)
            }
            Button("Annulla", action: cancel)
                .buttonStyle(SbuFieldPillStyle())
        }
    }
}

#Preview("Light") {
    CompressionProgressView(isDownloading: true, fraction: 0.3) {}
        .padding()
        .environment(\.sbuAccent, .clean)
}

#Preview("Dark") {
    CompressionProgressView(isDownloading: false, fraction: 0.7) {}
        .padding()
        .environment(\.sbuAccent, .clean)
        .preferredColorScheme(.dark)
}
