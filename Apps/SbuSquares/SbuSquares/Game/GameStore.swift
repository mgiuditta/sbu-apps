import Foundation
import Observation

/// The game in play and the Record, saved on the device after every move.
///
/// When no piece fits, the game waits for the second chance: take back the moves of the last
/// tray, up to three, once a game, or end it. The Record and the Closure come only when it ends, so the Closure plays once.
@Observable
final class GameStore {
    private(set) var game: Game
    private(set) var record: Int
    /// The game when the last tray played was dealt, its three pieces still in hand, while the
    /// second chance is still there to spend.
    private(set) var previous: Game?

    /// Set when a game ends above a Record that already existed: the Closure shows it.
    var isShowingClosure = false

    private let defaults: UserDefaults
    /// When the last piece went down, to count play time; not saved, so time away does not count.
    private var lastMove: Date?

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let record = defaults.integer(forKey: Key.record)
        self.record = record
        game = defaults.data(forKey: Key.game).flatMap { try? JSONDecoder().decode(Game.self, from: $0) }
            ?? Self.newGame(recordToBeat: record, defaults: defaults)
        previous = defaults.data(forKey: Key.previous).flatMap { try? JSONDecoder().decode(Game.self, from: $0) }
    }

    /// Whether no piece fits and the last move can still be taken back.
    var canTakeBack: Bool {
        game.isOver && previous != nil
    }

    /// Puts a piece down; `nil` if it does not fit.
    @discardableResult
    func place(slot: Int, at origin: Cell, now: Date = .now) -> Placement? {
        var game = game
        // ponytail: a pause longer than a minute counts as a minute; the original adjusts play time its own way.
        let elapsed = lastMove.map { min(max(now.timeIntervalSince($0), 0), 60) } ?? 0
        guard let placement = game.place(slot: slot, at: origin, elapsed: elapsed) else { return nil }
        lastMove = now
        let before = self.game
        let setStart = before.leftInHand.count == before.tray.count ? before : previous
        store(game, previous: game.hasUsedSecondChance ? nil : setStart)
        if game.isOver, previous == nil { finish(game) }
        return placement
    }

    /// Spends the second chance: the board, the pieces and the score as they were when the last
    /// tray played was dealt.
    func takeBack() {
        guard canTakeBack, var restored = previous else { return }
        restored.spendSecondChance()
        lastMove = nil
        store(restored, previous: nil)
    }

    /// Ends a game that is waiting for the second chance.
    func endGame() {
        guard canTakeBack else { return }
        store(game, previous: nil)
        finish(game)
    }

    /// Starts a new game, ending first one still waiting for the second chance.
    func startNewGame() {
        endGame()
        lastMove = nil
        store(Self.newGame(recordToBeat: record, defaults: defaults), previous: nil)
    }

    /// Forgets the Record.
    func resetRecord() {
        record = 0
        defaults.set(0, forKey: Key.record)
    }

    private func finish(_ game: Game) {
        defaults.set(game.leftInHand, forKey: Key.leftInHand)
        defaults.set(min(game.assists + 1, Game.maxAssists), forKey: Key.assists)
        guard game.score > record else { return }
        isShowingClosure = record > 0
        record = game.score
        defaults.set(record, forKey: Key.record)
    }

    private func store(_ game: Game, previous: Game?) {
        self.game = game
        self.previous = previous
        defaults.set(try? JSONEncoder().encode(game), forKey: Key.game)
        defaults.set(previous.flatMap { try? JSONEncoder().encode($0) }, forKey: Key.previous)
    }

    /// A game that leaves out the shapes the last one ended with, and carries the assists.
    private static func newGame(recordToBeat: Int, defaults: UserDefaults) -> Game {
        let avoiding = defaults.array(forKey: Key.leftInHand) as? [Int] ?? []
        return Game(seed: .random(in: .min ... .max), recordToBeat: recordToBeat, avoiding: avoiding, assists: defaults.integer(forKey: Key.assists))
    }

    private enum Key {
        static let game = "game"
        static let previous = "previousGame"
        static let record = "record"
        static let leftInHand = "lastGame.leftInHand"
        static let assists = "assists"
    }
}
