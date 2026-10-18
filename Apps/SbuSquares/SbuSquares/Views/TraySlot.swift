import SbuKit
import SwiftUI

/// One of the three places of the tray: the piece at half the board's size, or nothing once used.
struct TraySlot: View {
    let slot: Int
    let piece: Piece?
    let cell: CGFloat
    /// Hidden while it is dragged: the floating copy takes its place.
    let isDragged: Bool
    /// Dimmed when the piece no longer fits anywhere.
    let fits: Bool
    let isSelected: Bool
    let select: () -> Void

    var body: some View {
        ZStack {
            if let piece {
                PieceShape(piece: piece, cell: cell)
                    .opacity(isDragged ? 0 : fits ? 1 : 0.3)
                    .padding(SbuTheme.space2)
                    .overlay {
                        RoundedRectangle(cornerRadius: SbuTheme.radiusCard)
                            .strokeBorder(SbuTheme.ink, lineWidth: SbuTheme.hairline)
                            .opacity(isSelected && !isDragged ? 1 : 0)
                    }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(.rect)
        .accessibilityElement()
        .accessibilityLabel(piece.map { Text("Pezzo da \($0.cells.count) quadretti, \($0.width) per \($0.height)") } ?? Text("Posto vuoto"))
        .accessibilityValue(isSelected ? Text("Scelto") : Text(verbatim: ""))
        .accessibilityHint(piece == nil ? Text(verbatim: "") : Text("Sceglilo, poi tocca una casella della griglia."))
        .accessibilityAddTraits(piece == nil ? [] : .isButton)
        .accessibilityAction(.default, select)
    }
}

#Preview("Light") {
    HStack {
        TraySlot(slot: 0, piece: Piece.catalog[10], cell: 22, isDragged: false, fits: true, isSelected: true) {}
        TraySlot(slot: 1, piece: Piece.catalog[15], cell: 22, isDragged: false, fits: false, isSelected: false) {}
        TraySlot(slot: 2, piece: nil, cell: 22, isDragged: false, fits: true, isSelected: false) {}
    }
    .frame(height: 120)
    .sbuPaper()
}

#Preview("Dark") {
    HStack {
        TraySlot(slot: 0, piece: Piece.catalog[10], cell: 22, isDragged: false, fits: true, isSelected: false) {}
        TraySlot(slot: 1, piece: Piece.catalog[15], cell: 22, isDragged: false, fits: true, isSelected: false) {}
    }
    .frame(height: 120)
    .sbuPaper()
    .preferredColorScheme(.dark)
}
