import CoreGraphics
import Testing
@testable import SbuSquares

struct DropTargetTests {
    @Test func thePieceFloatsAboveTheFinger() {
        let frame = DropTarget.pieceFrame(width: 2, height: 1, at: CGPoint(x: 100, y: 200), cell: 40)
        #expect(frame == CGRect(x: 60, y: 110, width: 80, height: 40))
    }

    @Test func theOriginIsTheNearestCell() {
        let board = CGRect(x: 16, y: 300, width: 320, height: 320)
        let piece = CGRect(x: 16 + 40 * 2 + 15, y: 300 + 40 * 5 - 18, width: 40, height: 40)
        #expect(DropTarget.origin(of: piece, on: board) == Cell(row: 5, column: 2))
    }
}
