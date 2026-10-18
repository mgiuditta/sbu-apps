import Foundation
import Observation

/// The games in play and the Record, saved on the device after every move.
@Observable
final class GameStore {
    private(set) var daily: Game
    private(set) var free: Game
    private(set) var record: Int
    var mode: GameMode {
        didSet { defaults.set(mode.rawValue, forKey: Key.mode) }
    }

    /// Set when a game ends above a Record that already existed: the Closure shows it.
    var isShowingClosure = false

    private let defaults: UserDefaults
    /// When the last piece went down, to count play time; not saved, so time away does not count.
    private var lastMove: Date?

    init(defaults: UserDefaults = .standard, now: Date = .now) {
        self.defaults = defaults
        let record = defaults.integer(forKey: Key.record)
        self.record = record
        mode = defaults.string(forKey: Key.mode).flatMap(GameMode.init) ?? .daily
        let seed = GameMode.dailySeed(for: now)
        if let saved = Self.load(Key.daily, from: defaults), saved.seed == seed {
            daily = saved
        } else {
            daily = Self.newGame(mode: .daily, seed: seed, recordToBeat: record, defaults: defaults)
        }
        free = Self.load(Key.free, from: defaults) ?? Self.newFreeGame(recordToBeat: record, defaults: defaults)
    }

    /// The game of the current mode.
    var game: Game {
        mode == .daily ? daily : free
    }

    /// Puts a piece down in the current game; `nil` if it does not fit.
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

    /// Starts a new free game and shows it.
    func startFreeGame() {
        mode = .free
        lastMove = nil
        store(Self.newFreeGame(recordToBeat: record, defaults: defaults))
    }

    /// Moves to today's Partita del giorno if the day changed while the app was open.
    func refreshDaily(now: Date = .now) {
        let seed = GameMode.dailySeed(for: now)
        guard daily.seed != seed else { return }
        store(Self.newGame(mode: .daily, seed: seed, recordToBeat: record, defaults: defaults))
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
        switch game.mode {
        case .daily: daily = game
        case .free: free = game
        }
        defaults.set(try? JSONEncoder().encode(game), forKey: game.mode == .daily ? Key.daily : Key.free)
    }

    private static func load(_ key: String, from defaults: UserDefaults) -> Game? {
        defaults.data(forKey: key).flatMap { try? JSONDecoder().decode(Game.self, from: $0) }
    }

    private static func newFreeGame(recordToBeat: Int, defaults: UserDefaults) -> Game {
        newGame(mode: .free, seed: .random(in: .min ... .max), recordToBeat: recordToBeat, defaults: defaults)
    }

    /// A game that leaves out the shapes the last one ended with, and carries the assists.
    private static func newGame(mode: GameMode, seed: UInt64, recordToBeat: Int, defaults: UserDefaults) -> Game {
        let avoiding = defaults.array(forKey: Key.leftInHand) as? [Int] ?? []
        return Game(mode: mode, seed: seed, recordToBeat: recordToBeat, avoiding: avoiding, assists: defaults.integer(forKey: Key.assists))
    }

    private enum Key {
        static let daily = "game.daily"
        static let free = "game.free"
        static let record = "record"
        static let mode = "mode"
        static let leftInHand = "lastGame.leftInHand"
        static let assists = "assists"
    }
}
