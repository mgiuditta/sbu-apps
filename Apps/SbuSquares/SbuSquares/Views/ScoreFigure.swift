import SbuKit
import SwiftUI

/// The score, the one figure of the screen, closed by the full stop that turns `.set` once the
/// game beats the Record. Under it, in `inkMuted`, what the last line scored and the combo.
struct ScoreFigure: View {
    let score: Int
    let beatsRecord: Bool
    /// The points of the last move that completed lines, `nil` until the next one.
    let gain: Int?
    let combo: Int
    /// The point size, on the grid: 72 to 144 (ADR-0015).
    let size: CGFloat

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var gainText: String {
        guard let gain else { return " " }
        let points = gain.formatted(.number.sign(strategy: .always()))
        return combo > 1 ? String(localized: "\(points) · combo \(combo)") : points
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
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
            // Always there, blank between lines, so the board never moves.
            Text(verbatim: gainText)
                .font(SbuTheme.subheadline)
                .foregroundStyle(SbuTheme.inkMuted)
                .monospacedDigit()
                .contentTransition(.opacity)
                .animation(SbuMotion.animation(SbuMotion.short, reduceMotion: reduceMotion), value: gainText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Punteggio \(score)")
    }
}

#Preview("Light") {
    VStack(spacing: SbuTheme.space6) {
        ScoreFigure(score: 1_240, beatsRecord: true, gain: 128, combo: 3, size: 120)
        ScoreFigure(score: 36, beatsRecord: false, gain: nil, combo: 0, size: 72)
        ScoreFigure(score: 123_456_789, beatsRecord: true, gain: 18, combo: 1, size: 144)
    }
    .padding(SbuTheme.space4)
    .sbuPaper()
    .environment(\.sbuAccent, .squares)
}

#Preview("Dark") {
    ScoreFigure(score: 1_240, beatsRecord: true, gain: 128, combo: 3, size: 120)
        .padding(SbuTheme.space4)
        .sbuPaper()
        .environment(\.sbuAccent, .squares)
        .preferredColorScheme(.dark)
}
