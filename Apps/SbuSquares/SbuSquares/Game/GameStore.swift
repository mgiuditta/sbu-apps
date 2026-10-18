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

    init(defaults: UserDefaults = .standard, now: Date = .now) {
        self.defaults = defaults
        let record = defaults.integer(forKey: Key.record)
        self.record = record
        mode = defaults.string(forKey: Key.mode).flatMap(GameMode.init) ?? .daily
        let seed = GameMode.dailySeed(for: now)
        if let saved = Self.load(Key.daily, from: defaults), saved.seed == seed {
            daily = saved
        } else {
            daily = Game(mode: .daily, seed: seed, recordToBeat: record)
        }
        free = Self.load(Key.free, from: defaults) ?? Self.newFreeGame(recordToBeat: record)
    }

    /// The game of the current mode.
    var game: Game {
        mode == .daily ? daily : free
    }

    /// Puts a piece down in the current game; `nil` if it does not fit.
    @discardableResult
    func place(slot: Int, at origin: Cell) -> Placement? {
        var game = game
        guard let placement = game.place(slot: slot, at: origin) else { return nil }
        if game.isOver { finish(game) }
        store(game)
        return placement
    }

    /// Starts a new free game and shows it.
    func startFreeGame() {
        mode = .free
        store(Self.newFreeGame(recordToBeat: record))
    }

    /// Moves to today's Partita del giorno if the day changed while the app was open.
    func refreshDaily(now: Date = .now) {
        let seed = GameMode.dailySeed(for: now)
        guard daily.seed != seed else { return }
        store(Game(mode: .daily, seed: seed, recordToBeat: record))
    }

    /// Forgets the Record.
    func resetRecord() {
        record = 0
        defaults.set(0, forKey: Key.record)
    }

    private func finish(_ game: Game) {
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

    private static func newFreeGame(recordToBeat: Int) -> Game {
        Game(mode: .free, seed: .random(in: .min ... .max), recordToBeat: recordToBeat)
    }

    private enum Key {
        static let daily = "game.daily"
        static let free = "game.free"
        static let record = "record"
        static let mode = "mode"
    }
}
