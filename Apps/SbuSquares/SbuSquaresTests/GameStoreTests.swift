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
        playOut(store)
        store.endGame()
        #expect(store.record == store.game.score)
        #expect(!store.isShowingClosure)
    }

    @Test func beatingAnExistingRecordShowsTheClosure() {
        defaults.set(1, forKey: "record")
        let store = GameStore(defaults: defaults)
        store.startNewGame()
        playOut(store)
        #expect(!store.isShowingClosure)
        store.endGame()
        #expect(store.isShowingClosure)
    }

    @Test func movesAreSavedAndReloaded() throws {
        let store = GameStore(defaults: defaults)
        let piece = try #require(store.game.piece(in: 0))
        let cell = try #require(Board.allCells.first { store.game.board.canPlace(piece, at: $0) })
        store.place(slot: 0, at: cell)
        #expect(GameStore(defaults: defaults).game == store.game)
    }

    @Test func aStuckGameWaitsForTheSecondChance() throws {
        let store = GameStore(defaults: defaults)
        playOut(store)
        let before = try #require(store.previous)
        #expect(store.canTakeBack)
        #expect(store.record == 0)

        store.takeBack()
        #expect(!store.game.isOver)
        #expect(store.game.board == before.board)
        #expect(store.game.score == before.score)
        #expect(store.game.hasUsedSecondChance)
        #expect(!store.canTakeBack)
    }

    @Test func theSecondChanceComesOnceAGame() {
        let store = GameStore(defaults: defaults)
        playOut(store)
        store.takeBack()
        playOut(store)
        #expect(store.game.isOver)
        #expect(!store.canTakeBack)
        #expect(store.record == store.game.score)
    }

    @Test func theSecondChanceSurvivesARelaunch() {
        let store = GameStore(defaults: defaults)
        playOut(store)
        let reloaded = GameStore(defaults: defaults)
        #expect(reloaded.canTakeBack)
        #expect(reloaded.previous == store.previous)
    }

    @Test func aNewGameEndsTheOneWaitingForTheSecondChance() {
        let store = GameStore(defaults: defaults)
        playOut(store)
        let score = store.game.score
        store.startNewGame()
        #expect(store.record == score)
        #expect(!store.canTakeBack)
    }

    @Test func aLostGameLeavesItsPiecesOutOfTheNextOne() {
        let store = GameStore(defaults: defaults)
        playOut(store)
        let leftInHand = Set(store.game.leftInHand)
        store.startNewGame()
        #expect(store.game.assists == 1)
        #expect(Set(store.game.leftInHand).isDisjoint(with: leftInHand))
    }
}
