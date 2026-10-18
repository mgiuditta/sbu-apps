import SbuKit
import SwiftUI

/// The piece under the finger: it grows from tray size to board size and rises above the finger.
struct FloatingPiece: View {
    let drag: PieceDrag
    let boardCell: CGFloat
    let trayScale: CGFloat

    var body: some View {
        let frame = DropTarget.pieceFrame(width: drag.piece.width, height: drag.piece.height, at: drag.location, cell: boardCell)
        PieceShape(piece: drag.piece, cell: boardCell, color: PieceTone.color(drag.tone))
            .scaleEffect(drag.isLifted ? 1 : trayScale)
            .position(drag.isLifted ? CGPoint(x: frame.midX, y: frame.midY) : drag.location)
            .allowsHitTesting(false)
    }
}

#Preview("Light") {
    FloatingPiece(drag: PieceDrag(slot: 0, piece: Piece.catalog[17], tone: 4, location: CGPoint(x: 160, y: 300), start: .zero, isLifted: true), boardCell: 44, trayScale: 0.5)
        .sbuPaper()
}

#Preview("Dark") {
    FloatingPiece(drag: PieceDrag(slot: 0, piece: Piece.catalog[17], tone: 4, location: CGPoint(x: 160, y: 300), start: .zero, isLifted: true), boardCell: 44, trayScale: 0.5)
        .sbuPaper()
        .preferredColorScheme(.dark)
}
