import SbuKit
import SwiftUI

/// The file is being read: how far, and the way to stop.
struct ImportProgressView: View {
    let progress: Double
    let cancel: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SbuTheme.space4) {
                Text("Leggo la chat")
                    .font(SbuTheme.title2)
                    .foregroundStyle(SbuTheme.ink)
                    .accessibilityAddTraits(.isHeader)
                ProgressView(value: progress)
                    .accessibilityLabel(Text("Lettura"))
                    .accessibilityValue(Text(progress, format: .percent.precision(.fractionLength(0))))
                Text("Sull'iPhone, senza internet. Una chat lunga richiede qualche secondo.")
                    .font(SbuTheme.footnote)
                    .foregroundStyle(SbuTheme.inkMuted)
            }
            .padding(SbuTheme.space4)
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Annulla", action: cancel)
            }
        }
    }
}

#Preview("Light") {
    NavigationStack { ImportProgressView(progress: 0.4, cancel: {}) }
}

#Preview("Dark") {
    NavigationStack { ImportProgressView(progress: 0.4, cancel: {}) }
        .preferredColorScheme(.dark)
}
