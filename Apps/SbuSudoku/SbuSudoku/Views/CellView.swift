import SbuKit
import SwiftUI

/// One cell: its digit, or its notes in a 3×3 grid of small digits.
///
/// Given digits and those a hint placed are semibold ink, the player's are regular ink, mistakes
/// are `danger` (the mistake count says it in words under the score).
struct CellView: View {
    let value: Int
    let notes: Int
    let state: CellState
    let look: CellLook
    /// The selected cell's digit, to pick out the same note.
    let highlightedDigit: Int?
    /// Repeats a digit of its row, column or box.
    let isDuplicate: Bool

    var body: some View {
        ZStack {
            Rectangle().fill(background)
            if value != 0 {
                Text(value, format: .number)
                    .font(.title2.weight(state == .constant ? .semibold : .regular))
                    .foregroundStyle(state == .error ? SbuTheme.danger : SbuTheme.ink)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
            } else if notes != 0 {
                NotesView(notes: notes, highlightedDigit: highlightedDigit)
            }
            if isDuplicate {
                Rectangle()
                    .strokeBorder(SbuTheme.danger, lineWidth: SbuTheme.checkboxStroke)
            }
            if look == .selected {
                Rectangle()
                    .strokeBorder(SbuTheme.ink, lineWidth: SbuTheme.checkboxStroke)
            }
        }
        .contentShape(Rectangle())
    }

    private var background: Color {
        switch look {
        case .plain: SbuTheme.surfaceRaised
        case .area: SbuTheme.surfaceSunken
        case .selected, .sameDigit: SbuTheme.line
        }
    }
}

#Preview("Light") {
    HStack(spacing: 0) {
        CellView(value: 5, notes: 0, state: .constant, look: .plain, highlightedDigit: nil, isDuplicate: false)
        CellView(value: 3, notes: 0, state: .ok, look: .selected, highlightedDigit: 3, isDuplicate: false)
        CellView(value: 7, notes: 0, state: .error, look: .area, highlightedDigit: nil, isDuplicate: true)
        CellView(value: 0, notes: 0b10_1010_1010, state: .empty, look: .sameDigit, highlightedDigit: 3, isDuplicate: false)
    }
    .frame(width: 160, height: 40)
}

#Preview("Dark") {
    HStack(spacing: 0) {
        CellView(value: 5, notes: 0, state: .constant, look: .plain, highlightedDigit: nil, isDuplicate: false)
        CellView(value: 0, notes: 0b10_1010_1010, state: .empty, look: .area, highlightedDigit: 3, isDuplicate: false)
    }
    .frame(width: 80, height: 40)
    .preferredColorScheme(.dark)
}
