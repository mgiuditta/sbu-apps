import SwiftUI

/// A share button for the screen's figure: it shares the figure card, a 1080 × 1350 picture of
/// the figure on paper signed `Sbu <Nome> · sbu.dev`. Place it next to the figure, in `ink`.
public struct SbuFigureShareLink: View {
    private let card: SbuFigureCardImage

    /// Creates the share button.
    /// - Parameter card: The card it shares.
    public init(_ card: SbuFigureCardImage) {
        self.card = card
    }

    public var body: some View {
        ShareLink(item: card, preview: SharePreview(Text(verbatim: card.appName))) {
            Label {
                Text("Condividi la cifra", bundle: SbuTheme.bundle)
            } icon: {
                Image(systemName: "square.and.arrow.up")
                    .fontWeight(.medium)
            }
        }
        .tint(SbuTheme.ink)
    }
}

#Preview("Light") {
    SbuFigureShareLink(SbuFigureCardImage(value: "12", word: "giorni di fila", appName: "Sbu Habits", accent: .habits))
        .padding(SbuTheme.space4)
        .sbuPaper()
}

#Preview("Dark") {
    SbuFigureShareLink(SbuFigureCardImage(value: "12", word: "giorni di fila", appName: "Sbu Habits", accent: .habits))
        .padding(SbuTheme.space4)
        .sbuPaper()
        .preferredColorScheme(.dark)
}
