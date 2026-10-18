import SbuKit
import SwiftUI

/// The score, the one figure of the screen, closed by the full stop that turns `.set` once the
/// game beats the Record. Under it, in `inkMuted`, the Record and the lines cleared.
struct ScoreFigure: View {
    let score: Int
    let record: Int
    let lines: Int
    let beatsRecord: Bool
    /// The point size, on the grid: 72 to 144 (ADR-0015).
    let size: CGFloat

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .lastTextBaseline, spacing: 0) {
                Text(score, format: .number)
                    .font(.sbuFigure(size: size, width: SbuTheme.figureWidthMid))
                    .monospacedDigit()
                    .foregroundStyle(SbuTheme.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .contentTransition(.numericText(value: Double(score)))
                    .animation(SbuMotion.animation(SbuMotion.base, reduceMotion: reduceMotion), value: score)
                SbuFullStop(beatsRecord ? .set : .waiting, size: size > SbuTheme.figureHeroMin / 2 ? .hero : .inline)
            }
            HStack {
                Text("Record \(max(record, score), format: .number)")
                Spacer()
                Text("\(lines) righe")
            }
            .font(SbuTheme.subheadline)
            .foregroundStyle(SbuTheme.inkMuted)
            .monospacedDigit()
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Punteggio \(score), record \(max(record, score)), \(lines) righe")
    }
}

#Preview("Light") {
    VStack(spacing: SbuTheme.space6) {
        ScoreFigure(score: 1_240, record: 980, lines: 14, beatsRecord: true, size: 120)
        ScoreFigure(score: 36, record: 980, lines: 1, beatsRecord: false, size: 72)
    }
    .padding(SbuTheme.space4)
    .sbuPaper()
    .environment(\.sbuAccent, .squares)
}

#Preview("Dark") {
    ScoreFigure(score: 1_240, record: 980, lines: 14, beatsRecord: true, size: 120)
        .padding(SbuTheme.space4)
        .sbuPaper()
        .environment(\.sbuAccent, .squares)
        .preferredColorScheme(.dark)
}
