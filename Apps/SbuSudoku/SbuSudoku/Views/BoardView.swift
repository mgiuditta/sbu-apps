import SbuKit
import SwiftUI

/// The 9×9 grid. Tapping a cell selects it; VoiceOver reads each cell's place, digit and notes.
struct BoardView: View {
    let game: Game
    let preferences: Preferences
    let select: (Int) -> Void

    private var selectedDigit: Int? {
        guard let selected = game.selected else { return nil }
        let value = game.value(at: selected)
        return value == 0 ? nil : value
    }

    var body: some View {
        Grid(horizontalSpacing: 0, verticalSpacing: 0) {
            ForEach(0..<Units.size, id: \.self) { row in
                GridRow {
                    ForEach(0..<Units.size, id: \.self) { column in
                        cell(row * Units.size + column)
                    }
                }
            }
        }
        .overlay { BoardLines() }
        .aspectRatio(1, contentMode: .fit)
    }

    private func cell(_ index: Int) -> some View {
        let state = game.state(of: index, rules: preferences.rules)
        return Button {
            select(index)
        } label: {
            CellView(
                value: game.value(at: index),
                notes: game.notes(at: index),
                state: state,
                look: look(of: index),
                highlightedDigit: preferences.highlightsSameDigits ? selectedDigit : nil,
                isDuplicate: preferences.highlightsDuplicates && isDuplicate(index)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Riga \(Units.row(of: index) + 1), colonna \(Units.column(of: index) + 1)")
        .accessibilityValue(accessibilityValue(of: index, state: state))
        .accessibilityAddTraits(game.selected == index ? .isSelected : [])
    }

    private func look(of index: Int) -> CellLook {
        guard let selected = game.selected else { return .plain }
        if index == selected { return .selected }
        if preferences.highlightsSameDigits, let selectedDigit, game.value(at: index) == selectedDigit { return .sameDigit }
        if preferences.highlightsAreas, Units.peers[selected].contains(index) { return .area }
        return .plain
    }

    /// Whether a peer holds the same digit.
    private func isDuplicate(_ index: Int) -> Bool {
        let value = game.value(at: index)
        return value != 0 && Units.peers[index].contains { game.value(at: $0) == value }
    }

    private func accessibilityValue(of index: Int, state: CellState) -> String {
        let value = game.value(at: index)
        if value == 0 {
            let notes = (1...Units.size).filter { game.notes(at: index) & (1 << $0) != 0 }
            if notes.isEmpty { return String(localized: "Vuota") }
            return String(localized: "Note \(notes.map(String.init).formatted(.list(type: .and)))")
        }
        switch state {
        case .constant: return String(localized: "\(value), fissa")
        case .error: return String(localized: "\(value), sbagliata")
        default: return value.formatted()
        }
    }
}

#Preview("Light") {
    var game = Game(puzzle: Puzzle(difficulty: .medium, seed: 1), difficulty: .medium)
    game.selected = 40
    return BoardView(game: game, preferences: Preferences(), select: { _ in })
        .padding()
        .sbuPaper()
}

#Preview("Dark") {
    BoardView(game: Game(puzzle: Puzzle(difficulty: .hard, seed: 2), difficulty: .hard), preferences: Preferences(), select: { _ in })
        .padding()
        .sbuPaper()
        .preferredColorScheme(.dark)
}
