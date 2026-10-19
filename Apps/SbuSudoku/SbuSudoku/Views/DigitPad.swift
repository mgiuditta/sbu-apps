import SbuKit
import SwiftUI

/// The digits 1 to 9, each with how many more can go on the grid.
struct DigitPad: View {
    let game: Game
    let disablesUsedDigits: Bool
    let enter: (Int) -> Void

    var body: some View {
        HStack(spacing: SbuTheme.space1) {
            ForEach(1...Units.size, id: \.self) { digit in
                let remaining = game.remaining(digit)
                Button {
                    enter(digit)
                } label: {
                    VStack(spacing: 0) {
                        Text(digit, format: .number)
                            .font(.title.weight(.medium))
                            .foregroundStyle(SbuTheme.ink)
                        Text(remaining, format: .number)
                            .font(.caption2)
                            .foregroundStyle(SbuTheme.inkMuted)
                    }
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .frame(maxWidth: .infinity, minHeight: SbuTheme.controlRoundSm)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .opacity(disablesUsedDigits && remaining == 0 ? 0 : 1)
                .disabled(disablesUsedDigits && remaining == 0)
                .accessibilityLabel(Text(digit, format: .number))
                .accessibilityValue(game.isNoting ? Text("Nota, ne mancano \(remaining)") : Text("Ne mancano \(remaining)"))
            }
        }
    }
}

#Preview("Light") {
    DigitPad(game: Game(puzzle: Puzzle(difficulty: .easy, seed: 1), difficulty: .easy), disablesUsedDigits: true, enter: { _ in })
        .padding()
        .sbuPaper()
}

#Preview("Dark") {
    DigitPad(game: Game(puzzle: Puzzle(difficulty: .easy, seed: 1), difficulty: .easy), disablesUsedDigits: true, enter: { _ in })
        .padding()
        .sbuPaper()
        .preferredColorScheme(.dark)
}
