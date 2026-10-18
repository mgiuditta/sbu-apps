import CoreGraphics

/// A piece being dragged from the tray.
struct PieceDrag: Equatable {
    let slot: Int
    let piece: Piece
    let tone: Int
    /// The finger, in the game's coordinate space.
    var location: CGPoint
    /// Where the finger started, to fly the piece back if it does not fit.
    let start: CGPoint
    /// Whether the piece has grown to board size and risen above the finger.
    var isLifted = false
    /// The cell the piece would land on, `nil` while it does not fit.
    var origin: Cell?
}
