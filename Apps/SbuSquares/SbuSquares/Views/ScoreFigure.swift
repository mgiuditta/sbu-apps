import SbuKit
import SwiftUI

/// The score, the one figure of the screen, centred above the board and closed by the full stop
/// that turns `.set` once the game beats the Record.
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
                // Combo scoring reaches millions: the figure shrinks rather than truncate.
                .minimumScaleFactor(0.3)
                .contentTransition(.numericText(value: Double(score)))
                .animation(SbuMotion.animation(SbuMotion.base, reduceMotion: reduceMotion), value: score)
            SbuFullStop(beatsRecord ? .set : .waiting, size: size > SbuTheme.figureHeroMin / 2 ? .hero : .inline)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Punteggio \(score)")
    }
}

#Preview("Light") {
    VStack(spacing: SbuTheme.space6) {
        ScoreFigure(score: 1_240, beatsRecord: true, size: 120)
        ScoreFigure(score: 36, beatsRecord: false, size: 72)
        ScoreFigure(score: 123_456_789, beatsRecord: true, size: 144)
    }
    .padding(SbuTheme.space4)
    .sbuPaper()
    .environment(\.sbuAccent, .squares)
}

#Preview("Dark") {
    ScoreFigure(score: 1_240, beatsRecord: true, size: 120)
        .padding(SbuTheme.space4)
        .sbuPaper()
        .environment(\.sbuAccent, .squares)
        .preferredColorScheme(.dark)
}
