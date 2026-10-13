import SbuKit
import SwiftUI

/// The end of a queue: nothing left here, and the way to the bin.
struct SwipeDoneView: View {
    let isEmptyQueue: Bool
    let binCount: Int
    let reviewBin: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: SbuTheme.space4) {
            Image(systemName: "checkmark.circle")
                .font(.largeTitle)
                .fontWeight(.medium)
                .foregroundStyle(.tint)
                .accessibilityHidden(true)

            Text(isEmptyQueue ? "Niente da vedere qui." : "Hai visto tutto qui.")
                .font(SbuTheme.headline)
                .foregroundStyle(SbuTheme.ink)

            Text("Le foto che hai messo nel cestino restano nella libreria finché non le elimini dal cestino.")
                .font(SbuTheme.subheadline)
                .foregroundStyle(SbuTheme.inkMuted)
                .multilineTextAlignment(.center)

            VStack(spacing: SbuTheme.space3) {
                if binCount > 0 {
                    SbuButton("Rivedi il cestino", action: reviewBin)
                }
                SbuButton("Torna all'elenco", kind: .secondary) {
                    dismiss()
                }
            }
            .padding(.top, SbuTheme.space2)
        }
        .padding(SbuTheme.space4)
    }
}

#Preview("Light") {
    SwipeDoneView(isEmptyQueue: false, binCount: 4) {}
        .tint(SbuTheme.accentClean)
}

#Preview("Dark") {
    SwipeDoneView(isEmptyQueue: true, binCount: 0) {}
        .tint(SbuTheme.accentClean)
        .preferredColorScheme(.dark)
}
