import SwiftUI

/// The figure as a card to share: 1080 × 1350 pixels of squared paper with the figure, its word, the
/// `.set` full stop and `Sbu <Nome> · sbu.dev` in the cartiglio face.
///
/// Always light: a shared picture keeps the paper whatever the phone's appearance. Drawn at a fixed
/// size, so the hero figure does not snap to a grid it measures on screen.
struct SbuFigureCard: View {
    /// The card in points; rendered at `scale` it is 1080 × 1350, the 4:5 portrait of social feeds.
    static let size = CGSize(width: 360, height: 450)
    static let scale: CGFloat = 3

    let value: String
    let unit: String?
    let word: LocalizedStringResource
    let appName: String
    let accent: SbuAccent

    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.gridCell) {
            Spacer(minLength: 0)
            SbuFigure(
                value: value,
                unit: unit,
                fullStop: .set,
                context: Text(word),
                accessibilityLabel: nil,
                scale: .fixed(SbuFigure.heroSize(for: value + (unit ?? "")), .hero)
            )
            Spacer(minLength: 0)
            Text(verbatim: Self.signature(appName: appName))
                .font(.sbuCartiglio)
                .tracking(SbuTheme.cartiglioSize * SbuTheme.cartiglioTracking)
                .foregroundStyle(SbuTheme.inkMuted)
                .lineLimit(1)
        }
        // Left on a vertical grid line one cell in from the paper's margin, top and bottom one cell in.
        .padding(.horizontal, SbuTheme.gridOffset + SbuTheme.gridCell)
        .padding(.vertical, SbuTheme.gridCell)
        .frame(width: Self.size.width, height: Self.size.height, alignment: .leading)
        .background { SbuPaper(grid: true) }
        .environment(\.sbuAccent, accent)
        .environment(\.colorScheme, .light)
    }

    /// "SBU SUBSCRIPTIONS · SBU.DEV": the app and where to find it, the only words besides the figure.
    static func signature(appName: String) -> String {
        "\(appName) · sbu.dev".uppercased()
    }
}

#Preview("Light") {
    SbuFigureCard(value: "544,34 €", unit: nil, word: "all'anno", appName: "Sbu Subscriptions", accent: .subscriptions)
}

#Preview("Dark") {
    // The card stays light: it is a picture of paper.
    SbuFigureCard(value: "12", unit: nil, word: "giorni di fila", appName: "Sbu Habits", accent: .habits)
        .preferredColorScheme(.dark)
}
