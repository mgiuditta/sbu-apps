import Testing
@testable import SbuSquares

struct DealerTests {
    private let pool = Array(Piece.catalog.indices)

    /// A board with `cells` filled.
    private func board(_ cells: [Cell]) -> BitBoard {
        var board = Board()
        for cell in cells {
            board.apply(Placement(covered: [cell], rows: [], columns: []))
        }
        return BitBoard(board)
    }

    /// Every cell from row `fromRow` down, but those in `except`.
    private func filled(rowsFrom fromRow: Int, except: Set<Cell>) -> [Cell] {
        Board.allCells.filter { $0.row >= fromRow && !except.contains($0) }
    }

    @Test func theGeneratorIsParkMillerRoundedToSixDecimals() {
        var generator = SeededGenerator(seed: 1)
        #expect(generator.random() == 0.000008)
        #expect(generator.state == 16_807)
        #expect(generator.random() == 0.131538)
    }

    @Test func theCatalogHasTheOriginalsFortyTwoShapes() {
        #expect(Piece.catalog.count == 42)
        #expect(Set(Piece.catalog).count == 41)
        #expect(Piece.catalog[Piece.index(ofID: 40)] == Piece.catalog[Piece.index(ofID: 41)])
        #expect(!Dealer.pool.contains(Piece.single))
        #expect(Dealer.pool.allSatisfy { !Dealer.diagonals.contains($0) })
        #expect(Dealer.small.allSatisfy { Piece.catalog[$0].cells.count <= 3 })
        #expect(Piece.catalog[Piece.index(ofID: 13)].cells.count == 9)
    }

    @Test(arguments: [1 as UInt64, 7, 42, 20_261_018])
    func entropyDealsBigPiecesThatCanAllGoDownAndRoughenTheBoard(seed: UInt64) throws {
        var generator = SeededGenerator(seed: seed)
        let half = board(filled(rowsFrom: 4, except: [Cell(row: 4, column: 0)]))
        let triple = try #require(Dealer.entropy(pool: Dealer.pool, on: half, using: &generator))
        #expect(triple.reduce(0) { $0 + Piece.catalog[$1].cells.count } >= Dealer.entropyCells)
        #expect(half.survives(triple))
    }

    @Test(arguments: [1 as UInt64, 7, 42, 20_261_018])
    func randomNoDeathDealsATrayThatCanAllGoDown(seed: UInt64) {
        var generator = SeededGenerator(seed: seed)
        let crowded = board(filled(rowsFrom: 2, except: [Cell(row: 4, column: 3), Cell(row: 6, column: 6)]))
        let triple = Dealer.randomNoDeath(pool: pool, on: crowded, using: &generator)
        #expect(triple.count == 3)
        #expect(crowded.survives(triple))
    }

    @Test func theHardPuzzleHasAThirdPieceThatFitsOnlyAfterALine() throws {
        // Rows 1–7 filled but for column 0 of rows 3–7 and the last cell of rows 1–2: the 3 × 3
        // square cannot fit until a bar in column 0 clears rows 3–7.
        let holes = Set((3...7).map { Cell(row: $0, column: 0) } + [Cell(row: 1, column: 7), Cell(row: 2, column: 7)])
        let cells = filled(rowsFrom: 1, except: holes)
        let crowded = board(cells)
        var generator = SeededGenerator(seed: 3)
        let triple = try #require(Dealer.hard(pool: pool, on: crowded, using: &generator))
        #expect(crowded.fits(piece: triple[0]))
        #expect(!crowded.fits(piece: triple[1]))
        #expect(crowded.fits(piece: triple[2]))
        #expect(crowded.survives(triple))
    }

    @Test func fillCoversTheLastHoleOfALine() throws {
        let hole = Cell(row: 7, column: 4)
        let crowded = board(filled(rowsFrom: 7, except: [hole]))
        var generator = SeededGenerator(seed: 9)
        let triple = try #require(Dealer.fill(pool: pool, on: crowded, using: &generator))
        #expect(BitBoard.placements[triple[0]].contains { crowded.fits($0) && crowded.completes($0) })
    }

    @Test func fillHasNothingToDoOnAnEmptyBoard() {
        var generator = SeededGenerator(seed: 9)
        #expect(Dealer.fill(pool: pool, on: board([]), using: &generator) == nil)
    }

    @Test func noLinesDealsPiecesThatCannotCompleteALine() throws {
        let crowded = board(filled(rowsFrom: 7, except: [Cell(row: 7, column: 4)]))
        var generator = SeededGenerator(seed: 4)
        let triple = try #require(Dealer.noLines(pool: pool, on: crowded, using: &generator))
        for piece in triple {
            #expect(!BitBoard.placements[piece].contains { crowded.fits($0) && crowded.completes($0) })
        }
    }

    @Test(arguments: [
        ([[1], [2], [1], [2]], true),
        ([[1], [2], [3], [1], [2], [3]], true),
        ([[1], [2], [3], [4]], false),
        ([[1], [1]], false),
    ])
    func repeatingTraysAreALoop(recent: [[Int]], isLoop: Bool) {
        #expect(Dealer.isLoop(recent) == isLoop)
    }

    @Test func theSameTrayTwiceGetsANewMiddlePiece() {
        var generator = SeededGenerator(seed: 5)
        let tray = [4, 8, 2]
        let varied = Dealer.varied(tray, after: tray, pool: pool, on: board([]), using: &generator)
        #expect(varied[0] == 4 && varied[2] == 2)
        #expect(varied[1] != 8)
    }

    @Test func aDeadTrayIsSecured() {
        // Only the diagonal is free: nothing but the single cell fits.
        let crowded = board(Board.allCells.filter { $0.row != $0.column })
        var generator = SeededGenerator(seed: 6)
        let square = Piece.index(ofID: 13)
        let secured = Dealer.secured([square, square, square], pool: pool, on: crowded, using: &generator)
        #expect(crowded.survives(secured))
    }
}
