import SbuKit
import SwiftUI

/// A piece in its color, one square per cell, inset like the board's.
struct PieceShape: View {
    let piece: Piece
    let cell: CGFloat
    let color: Color

    var body: some View {
        Canvas { context, _ in
            let inset = cell * 0.08
            for square in piece.cells {
                let rect = CGRect(x: CGFloat(square.column) * cell, y: CGFloat(square.row) * cell, width: cell, height: cell)
                context.fill(Path(rect.insetBy(dx: inset, dy: inset)), with: .color(color))
            }
        }
        .frame(width: CGFloat(piece.width) * cell, height: CGFloat(piece.height) * cell)
        .accessibilityHidden(true)
    }
}

#Preview("Light") {
    PieceShape(piece: Piece.catalog[15], cell: 40, color: PieceTone.color(0))
}

#Preview("Dark") {
    PieceShape(piece: Piece.catalog[15], cell: 40, color: PieceTone.color(0)).preferredColorScheme(.dark)
}
