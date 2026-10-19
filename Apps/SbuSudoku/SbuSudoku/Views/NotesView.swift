import SbuKit
import SwiftUI

/// The notes of a cell: each digit in its own place of a 3×3 grid.
struct NotesView: View {
    let notes: Int
    let highlightedDigit: Int?

    var body: some View {
        Grid(horizontalSpacing: 0, verticalSpacing: 0) {
            ForEach(0..<Units.box, id: \.self) { row in
                GridRow {
                    ForEach(1...Units.box, id: \.self) { column in
                        let digit = row * Units.box + column
                        Text(verbatim: notes & (1 << digit) != 0 ? String(digit) : " ")
                            .font(.caption2.weight(digit == highlightedDigit ? .heavy : .regular))
                            .foregroundStyle(digit == highlightedDigit ? SbuTheme.ink : SbuTheme.inkMuted)
                            .minimumScaleFactor(0.4)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
        }
        .padding(SbuTheme.hairline)
    }
}

#Preview("Light") {
    NotesView(notes: 0b11_1111_1110, highlightedDigit: 5).frame(width: 40, height: 40)
}

#Preview("Dark") {
    NotesView(notes: 0b00_1010_0110, highlightedDigit: nil).frame(width: 40, height: 40).preferredColorScheme(.dark)
}
