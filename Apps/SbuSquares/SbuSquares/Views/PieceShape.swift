import SbuKit
import SwiftUI

/// A piece drawn in ink, one square per cell, inset like the board's.
struct PieceShape: View {
    let piece: Piece
    let cell: CGFloat

    var body: some View {
        Canvas { context, _ in
            let inset = cell * 0.08
            for square in piece.cells {
                let rect = CGRect(x: CGFloat(square.column) * cell, y: CGFloat(square.row) * cell, width: cell, height: cell)
                context.fill(Path(rect.insetBy(dx: inset, dy: inset)), with: .color(SbuTheme.ink))
            }
        }
        .frame(width: CGFloat(piece.width) * cell, height: CGFloat(piece.height) * cell)
        .accessibilityHidden(true)
    }
}

#Preview("Light") {
    PieceShape(piece: Piece.catalog[15], cell: 40)
}

#Preview("Dark") {
    PieceShape(piece: Piece.catalog[15], cell: 40).preferredColorScheme(.dark)
}
