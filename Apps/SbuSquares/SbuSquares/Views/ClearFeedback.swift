import SbuKit
import SwiftUI

/// Over the board after a move that completes lines: the points it scored and, from the second
/// line in a row, the combo. It stays until the next piece is picked up.
struct ClearFeedback: View {
    let points: Int
    let combo: Int

    var body: some View {
        VStack(spacing: SbuTheme.space1) {
            if combo > 1 {
                Text("Combo \(combo)")
                    .font(SbuTheme.headline)
            }
            Text(points, format: .number.sign(strategy: .always()))
                .font(SbuTheme.title2)
                .monospacedDigit()
        }
        .foregroundStyle(SbuTheme.ink)
        .padding(.horizontal, SbuTheme.space3)
        .padding(.vertical, SbuTheme.space2)
        // Paper with a line, not an ink block: dark surfaces are the Closure's alone.
        .background(SbuTheme.paper, in: .rect(cornerRadius: SbuTheme.radiusCard))
        .overlay {
            RoundedRectangle(cornerRadius: SbuTheme.radiusCard)
                .strokeBorder(SbuTheme.line, lineWidth: SbuTheme.hairline)
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

#Preview("Light") {
    ClearFeedback(points: 128, combo: 3).padding(SbuTheme.space4).sbuPaper()
}

#Preview("Dark") {
    ClearFeedback(points: 18, combo: 1).padding(SbuTheme.space4).sbuPaper().preferredColorScheme(.dark)
}
