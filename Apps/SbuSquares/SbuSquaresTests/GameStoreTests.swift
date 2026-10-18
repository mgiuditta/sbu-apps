import Foundation
import Testing
@testable import SbuSquares

struct GameStoreTests {
    private let defaults: UserDefaults

    init() {
        let suite = "squares.tests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
    }

    private func playOut(_ store: GameStore) {
        for _ in 0..<500 where !store.game.isOver {
            let move = (0..<3).lazy.compactMap { slot in
                store.game.piece(in: slot).flatMap { piece in
                    Board.allCells.first { store.game.board.canPlace(piece, at: $0) }.map { (slot, $0) }
                }
            }.first
            guard let (slot, cell) = move else { return }
            store.place(slot: slot, at: cell)
        }
    }

    @Test func theFirstRecordHasNoClosure() {
        let store = GameStore(defaults: defaults)
        store.mode = .free
        playOut(store)
        #expect(store.record == store.free.score)
        #expect(!store.isShowingClosure)
    }

    @Test func beatingAnExistingRecordShowsTheClosure() {
        defaults.set(1, forKey: "record")
        let store = GameStore(defaults: defaults)
        store.startFreeGame()
        playOut(store)
        #expect(store.isShowingClosure)
    }

    @Test func movesAreSavedAndReloaded() throws {
        let store = GameStore(defaults: defaults)
        let piece = try #require(store.game.piece(in: 0))
        let cell = try #require(Board.allCells.first { store.game.board.canPlace(piece, at: $0) })
        store.place(slot: 0, at: cell)
        #expect(GameStore(defaults: defaults).daily == store.daily)
    }

    @Test func aNewDayBringsANewDailyGame() throws {
        let day = try Date("2026-10-18T12:00:00Z", strategy: .iso8601)
        let store = GameStore(defaults: defaults, now: day)
        store.refreshDaily(now: day.addingTimeInterval(86_400))
        #expect(store.daily.seed != GameMode.dailySeed(for: day))
    }
}
