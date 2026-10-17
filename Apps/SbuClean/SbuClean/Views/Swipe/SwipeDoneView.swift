import SbuKit
import SwiftUI

/// The end of a queue, or a queue with nothing to see, on gridded paper: what that means for this
/// queue, and the way to the bin.
struct SwipeDoneView: View {
    let source: SwipeSource
    let isEmptyQueue: Bool
    let binCount: Int
    let reviewBin: () -> Void

    @Environment(\.dismiss) private var dismiss

    private var message: LocalizedStringKey {
        guard isEmptyQueue else {
            return "Le foto che hai messo nel cestino restano nella libreria finché non le elimini dal cestino."
        }
        return switch source {
        case .recent: "Hai già visto tutte le foto degli ultimi 30 giorni."
        case .random: "Hai già visto tutta la libreria."
        case .onThisDay: "Nessuna foto da vedere scattata in questo giorno negli anni passati."
        case .later: "Non hai messo da parte niente. Mentre scorri, tocca Dopo per decidere più tardi."
        case .month: "Hai già visto tutto questo mese."
        case .album: "Hai già visto tutto questo album."
        case .category: "Niente da vedere in questa categoria."
        }
    }

    var body: some View {
        // On paper, as an empty state: the figure above is the bin, so no second "0" here.
        ScrollView {
            VStack(alignment: .leading, spacing: SbuTheme.space4) {
                Text(isEmptyQueue ? "Niente da vedere qui." : "Hai visto tutto qui.")
                    .font(SbuTheme.headline)
                    .foregroundStyle(SbuTheme.ink)

                Text(message)
                    .font(SbuTheme.body)
                    .foregroundStyle(SbuTheme.inkMuted)
                    .fixedSize(horizontal: false, vertical: true)

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
            .padding(.vertical, SbuTheme.space4)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollBounceBehavior(.basedOnSize)
        .sbuPaper(grid: true)
    }
}

#Preview("Light") {
    SwipeDoneView(source: .recent, isEmptyQueue: false, binCount: 4) {}
        .environment(\.sbuAccent, .clean)
}

#Preview("Dark") {
    SwipeDoneView(source: .onThisDay, isEmptyQueue: true, binCount: 0) {}
        .environment(\.sbuAccent, .clean)
        .preferredColorScheme(.dark)
}
