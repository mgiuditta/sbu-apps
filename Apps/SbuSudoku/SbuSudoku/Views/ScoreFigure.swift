import SbuKit
import SwiftUI

/// The score, the one figure of the screen, closed by the full stop that turns `.set` once the
/// game beats the Record of its difficulty.
struct ScoreFigure: View {
    let score: Int
    let beatsRecord: Bool
    /// The point size, on the grid: 72 to 144 (ADR-0015).
    let size: CGFloat

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        HStack(alignment: .lastTextBaseline, spacing: 0) {
            Text(score, format: .number)
                .font(.sbuFigure(size: size, width: SbuTheme.figureWidthMid))
                .monospacedDigit()
                .foregroundStyle(SbuTheme.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.3)
                .contentTransition(.numericText(value: Double(score)))
                .animation(SbuMotion.animation(SbuMotion.base, reduceMotion: reduceMotion), value: score)
            SbuFullStop(beatsRecord ? .set : .waiting, size: size > SbuTheme.figureHeroMin / 2 ? .hero : .inline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Punteggio \(score)")
    }
}

#Preview("Light") {
    VStack {
        ScoreFigure(score: 4_210, beatsRecord: true, size: 96)
        ScoreFigure(score: 0, beatsRecord: false, size: 72)
    }
    .padding()
    .sbuPaper()
    .environment(\.sbuAccent, .sudoku)
}

#Preview("Dark") {
    ScoreFigure(score: 4_210, beatsRecord: true, size: 96)
        .padding()
        .sbuPaper()
        .environment(\.sbuAccent, .sudoku)
        .preferredColorScheme(.dark)
}
