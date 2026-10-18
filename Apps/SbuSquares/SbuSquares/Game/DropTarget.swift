import CoreGraphics

/// Where a dragged piece lands: the board cell under its top-left corner.
nonisolated enum DropTarget {
    /// How far above the finger the dragged piece floats, in cells, so the finger never hides it.
    static let lift: CGFloat = 1.25

    /// The frame of a piece of `size` cells dragged with the finger at `location`: centred
    /// horizontally on the finger, its bottom edge `lift` cells above it.
    static func pieceFrame(width: Int, height: Int, at location: CGPoint, cell: CGFloat) -> CGRect {
        let size = CGSize(width: CGFloat(width) * cell, height: CGFloat(height) * cell)
        return CGRect(x: location.x - size.width / 2, y: location.y - lift * cell - size.height, width: size.width, height: size.height)
    }

    /// The cell nearest to the top-left corner of `pieceFrame` on a board drawn in `board`.
    static func origin(of pieceFrame: CGRect, on board: CGRect) -> Cell {
        let cell = board.width / CGFloat(Board.size)
        return Cell(
            row: Int(((pieceFrame.minY - board.minY) / cell).rounded()),
            column: Int(((pieceFrame.minX - board.minX) / cell).rounded())
        )
    }
}
