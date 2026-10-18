import Foundation
import Testing
@testable import SbuSquares

struct GameTests {
    /// The catalog indices of the first tray of 18 October 2026, as dealt when this test was written.
    private static let pinnedTray = [18, 1, 21]

    /// Plays the first piece that fits, at the first cell it fits, until the game ends.
    private func playOut(_ game: inout Game, maxMoves: Int = 500) -> Int {
        var moves = 0
        while !game.isOver, moves < maxMoves {
            let current = game
            let move = (0..<3).lazy.compactMap { slot in
                current.piece(in: slot).flatMap { piece in
                    Board.allCells.first { current.board.canPlace(piece, at: $0) }.map { (slot, $0) }
                }
            }.first
            guard let (slot, cell) = move else { break }
            game.place(slot: slot, at: cell)
            moves += 1
        }
        return moves
    }

    @Test func theSameSeedDealsTheSamePieces() {
        var first = Game(mode: .daily, seed: 20_261_018, recordToBeat: 0)
        var second = Game(mode: .daily, seed: 20_261_018, recordToBeat: 0)
        #expect(playOut(&first) == playOut(&second))
        #expect(first == second)
    }

    @Test func theDailySeedIsStableAcrossVersions() {
        // Pinned: changing the generator or the catalog would change everyone's Partita del giorno.
        let game = Game(mode: .daily, seed: 20_261_018, recordToBeat: 0)
        let pieces = (0..<3).compactMap { game.piece(in: $0) }.compactMap { Piece.catalog.firstIndex(of: $0) }
        #expect(pieces == Self.pinnedTray)
    }

    @Test func aPlacementThatDoesNotFitChangesNothing() throws {
        var game = Game(mode: .free, seed: 1, recordToBeat: 0)
        let before = game
        #expect(game.place(slot: 0, at: Cell(row: 9, column: 9)) == nil)
        #expect(game == before)
    }

    @Test func theTrayRefillsAfterTheThirdPiece() throws {
        var game = Game(mode: .free, seed: 2, recordToBeat: 0)
        for slot in 0..<3 {
            let piece = try #require(game.piece(in: slot))
            let cell = try #require(Board.allCells.first { game.board.canPlace(piece, at: $0) })
            game.place(slot: slot, at: cell)
        }
        #expect((0..<3).allSatisfy { game.piece(in: $0) != nil })
    }

    @Test func aGameEndsWhenNoPieceFits() {
        var game = Game(mode: .free, seed: 99, recordToBeat: 0)
        _ = playOut(&game)
        #expect(game.isOver)
        let fitting = (0..<3).compactMap { game.piece(in: $0) }.filter(game.board.hasRoom(for:))
        #expect(fitting.isEmpty)
    }

    @Test func beatingTheRecordNeedsMoreThanIt() {
        var game = Game(mode: .free, seed: 5, recordToBeat: 3)
        #expect(!game.beatsRecord)
        _ = playOut(&game, maxMoves: 4)
        #expect(game.beatsRecord)
    }

    @Test func aGameSurvivesSavingAndLoading() throws {
        var game = Game(mode: .free, seed: 11, recordToBeat: 40)
        _ = playOut(&game, maxMoves: 7)
        let data = try JSONEncoder().encode(game)
        #expect(try JSONDecoder().decode(Game.self, from: data) == game)
    }

    @Test(arguments: [("2026-10-18", 20_261_018 as UInt64), ("2027-01-02", 20_270_102)])
    func theDailySeedIsTheDate(day: String, seed: UInt64) throws {
        let date = try Date(day, strategy: .iso8601.year().month().day())
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .gmt
        #expect(GameMode.dailySeed(for: date, calendar: calendar) == seed)
    }
}
