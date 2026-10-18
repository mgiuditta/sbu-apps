import Foundation
import Observation

/// The game in play and the Record, saved on the device after every move.
@Observable
final class GameStore {
    private(set) var game: Game
    private(set) var record: Int

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
    }

    /// Puts a piece down; `nil` if it does not fit.
    @discardableResult
    func place(slot: Int, at origin: Cell, now: Date = .now) -> Placement? {
        var game = game
        // ponytail: a pause longer than a minute counts as a minute; the original adjusts play time its own way.
        let elapsed = lastMove.map { min(max(now.timeIntervalSince($0), 0), 60) } ?? 0
        guard let placement = game.place(slot: slot, at: origin, elapsed: elapsed) else { return nil }
        lastMove = now
        if game.isOver { finish(game) }
        store(game)
        return placement
    }

    /// Starts a new game.
    func startNewGame() {
        lastMove = nil
        store(Self.newGame(recordToBeat: record, defaults: defaults))
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

    private func store(_ game: Game) {
        self.game = game
        defaults.set(try? JSONEncoder().encode(game), forKey: Key.game)
    }

    /// A game that leaves out the shapes the last one ended with, and carries the assists.
    private static func newGame(recordToBeat: Int, defaults: UserDefaults) -> Game {
        let avoiding = defaults.array(forKey: Key.leftInHand) as? [Int] ?? []
        return Game(seed: .random(in: .min ... .max), recordToBeat: recordToBeat, avoiding: avoiding, assists: defaults.integer(forKey: Key.assists))
    }

    private enum Key {
        static let game = "game"
        static let record = "record"
        static let leftInHand = "lastGame.leftInHand"
        static let assists = "assists"
    }
}
