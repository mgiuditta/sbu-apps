import Foundation
import Testing
@testable import SbuSudoku

struct GameStoreTests {
    let defaults: UserDefaults

    init() {
        let name = "test.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: name)!
        defaults.removePersistentDomain(forName: name)
    }

    @Test func aWonGameSetsTheRecordWithoutTheClosureTheFirstTime() async {
        let store = GameStore(defaults: defaults)
        await store.startGame(.easy)
        solve(store)
        #expect(store.record(for: .easy) == store.game?.score)
        #expect(!store.isShowingClosure)
        #expect(store.wins.count == 1)
    }

    @Test func theGameIsSavedAfterEveryMove() async throws {
        let store = GameStore(defaults: defaults)
        await store.startGame(.medium)
        let cell = try #require(store.game?.givens.firstIndex(of: 0))
        store.select(cell)
        store.enter(try #require(store.game?.solution[cell]))
        #expect(GameStore(defaults: defaults).game == store.game)
    }

    @Test func turningTheLimitOffReachesTheGameInPlay() async {
        let store = GameStore(defaults: defaults)
        await store.startGame(.easy)
        store.preferences.hasMistakeLimit = false
        #expect(store.game?.hasMistakeLimit == false)
    }

    @Test func theDailyCanBeStartedOnceADay() async {
        let store = GameStore(defaults: defaults)
        let now = Date(timeIntervalSince1970: 1_792_400_000)
        await store.startDaily(now: now)
        let first = store.game
        await store.startGame(.easy)
        await store.startDaily(now: now)
        #expect(first?.day != nil)
        #expect(store.game?.difficulty == .easy)
        #expect(store.hasPlayedDaily(now: now))
    }

    private func solve(_ store: GameStore) {
        guard let game = store.game else { return }
        for cell in 0..<81 where game.givens[cell] == 0 {
            store.select(cell)
            store.enter(game.solution[cell])
        }
    }
}
