import Testing
@testable import SbuSquares

struct BoardTests {
    private let domino = Piece("##")

    @Test func aPieceFitsOnEmptyCellsInsideTheBoard() {
        let board = Board()
        #expect(board.canPlace(domino, at: Cell(row: 0, column: 6)))
        #expect(!board.canPlace(domino, at: Cell(row: 0, column: 7)))
        #expect(!board.canPlace(domino, at: Cell(row: -1, column: 0)))
    }

    @Test func aPieceDoesNotFitOverAFilledCell() throws {
        var board = Board()
        board.apply(try #require(board.preview(Piece("#"), at: Cell(row: 3, column: 3))))
        #expect(!board.canPlace(domino, at: Cell(row: 3, column: 2)))
        #expect(board.canPlace(domino, at: Cell(row: 3, column: 4)))
    }

    @Test func completingARowAndAColumnTogetherClearsBoth() throws {
        var board = Board()
        // Row 0 and column 0, all but the corner.
        let bar = Piece("#######")
        board.apply(try #require(board.preview(bar, at: Cell(row: 0, column: 1))))
        board.apply(try #require(board.preview(Piece("#", "#", "#", "#", "#", "#", "#"), at: Cell(row: 1, column: 0))))
        let corner = try #require(board.preview(Piece("#"), at: Cell(row: 0, column: 0)))
        #expect(corner.rows == [0])
        #expect(corner.columns == [0])
        #expect(corner.cleared.count == 15)
        board.apply(corner)
        #expect(board.filledCount == 0)
    }

    @Test(arguments: [(0, 1), (1, 11), (2, 41), (3, 91)])
    func linesCompletedTogetherScoreSquared(lines: Int, points: Int) {
        let placement = Placement(covered: [Cell(row: 0, column: 0)], rows: Array(0..<lines), columns: [])
        #expect(placement.points == points)
    }

    @Test func everyCatalogShapeStartsAtTheTopLeft() {
        for piece in Piece.catalog {
            #expect(piece.cells.map(\.row).min() == 0)
            #expect(piece.cells.map(\.column).min() == 0)
            #expect(Set(piece.cells).count == piece.cells.count)
        }
    }
}
