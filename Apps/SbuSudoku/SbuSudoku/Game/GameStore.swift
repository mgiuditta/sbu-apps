import Foundation
import Observation

/// The game in play, the settings, the Records and the wins, saved on the device after every move.
@Observable
final class GameStore {
    private(set) var game: Game?
    /// The best score of a game won, for each difficulty.
    private(set) var records: [Difficulty: Int]
    private(set) var wins: [Win]
    /// The day of the last Sudoku of the day started: one attempt a day.
    private(set) var lastDailyDay: Date?
    /// A new puzzle is being generated.
    private(set) var isGenerating = false
    var preferences: Preferences {
        didSet { preferencesChanged() }
    }

    /// Set when a game is won above a Record that already existed: the Closure shows it.
    var isShowingClosure = false

    private let defaults: UserDefaults
    /// When time was last added, to count wall-clock play time while the app is in front.
    private var lastTick: Date?

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        game = Self.decode(Game.self, defaults.data(forKey: Key.game))
        records = Self.decode([Difficulty: Int].self, defaults.data(forKey: Key.records)) ?? [:]
        wins = Self.decode([Win].self, defaults.data(forKey: Key.wins)) ?? []
        lastDailyDay = defaults.object(forKey: Key.lastDailyDay) as? Date
        preferences = Self.decode(Preferences.self, defaults.data(forKey: Key.preferences)) ?? Preferences()
    }

    var rules: Rules { preferences.rules }

    func record(for difficulty: Difficulty) -> Int {
        records[difficulty] ?? 0
    }

    /// Whether the game in play is above a Record that already exists: the full stop turns `.set`.
    var beatsRecord: Bool {
        guard let game, game.failure == nil else { return false }
        let record = record(for: game.difficulty)
        return record > 0 && game.score > record
    }

    func proposedDifficulty(now: Date = .now) -> Difficulty {
        DifficultyAdvisor.proposal(wins: wins, now: now, draw: .random(in: 0..<1))
    }

    func hasPlayedDaily(now: Date = .now) -> Bool {
        lastDailyDay == DailyPuzzle.day(of: now)
    }

    // MARK: Moves

    func select(_ cell: Int) {
        update { $0.selected = $0.selected == cell ? nil : cell }
    }

    func toggleNoting() {
        update { $0.isNoting.toggle() }
    }

    @discardableResult
    func enter(_ digit: Int) -> Entry {
        var entry = Entry.ignored
        update { entry = $0.enter(digit, rules: rules) }
        return entry
    }

    @discardableResult
    func erase() -> Entry {
        var entry = Entry.ignored
        update { entry = $0.erase(rules: rules) }
        return entry
    }

    @discardableResult
    func hint() -> Entry {
        var entry = Entry.ignored
        update { entry = $0.hint(rules: rules) }
        return entry
    }

    func undo() {
        update { $0.undo() }
    }

    func takeSecondChance() {
        update { $0.takeSecondChance() }
        lastTick = nil
    }

    /// Adds the time since the last tick; `nil` stops counting, while the app is in the background.
    func tick(now: Date?) {
        defer { lastTick = now }
        guard let now, let lastTick, game?.isOver == false else { return }
        // ponytail: a gap over a minute counts as a minute, in case a tick was missed while suspended.
        update { $0.addTime(min(max(now.timeIntervalSince(lastTick), 0), 60)) }
    }

    // MARK: Games

    func startGame(_ difficulty: Difficulty) async {
        isGenerating = true
        let puzzle = await Self.makePuzzle(difficulty, seed: .random(in: 1 ... .max))
        begin(Game(puzzle: puzzle, difficulty: difficulty, hasMistakeLimit: preferences.hasMistakeLimit))
    }

    func startDaily(now: Date = .now) async {
        let day = DailyPuzzle.day(of: now)
        guard lastDailyDay != day else { return }
        lastDailyDay = day
        defaults.set(day, forKey: Key.lastDailyDay)
        isGenerating = true
        let puzzle = await Self.makeDaily(day)
        begin(Game(puzzle: puzzle, difficulty: DailyPuzzle.difficulty, hasMistakeLimit: preferences.hasMistakeLimit, day: day))
    }

    func resetRecords() {
        records = [:]
        save(records, Key.records)
    }

    private func begin(_ game: Game) {
        lastTick = nil
        isGenerating = false
        self.game = game
        save(game, Key.game)
    }

    @concurrent
    private static func makePuzzle(_ difficulty: Difficulty, seed: UInt64) async -> Puzzle {
        Puzzle(difficulty: difficulty, seed: seed)
    }

    @concurrent
    private static func makeDaily(_ day: Date) async -> Puzzle {
        DailyPuzzle.puzzle(for: day)
    }

    private func update(_ change: (inout Game) -> Void) {
        guard var game else { return }
        let wasSolved = game.isSolved
        change(&game)
        self.game = game
        if !wasSolved, game.isSolved { finish(game) }
        // ponytail: time alone is saved every tick too; a few hundred bytes a second.
        save(game, Key.game)
    }

    private func finish(_ game: Game) {
        let now = Date.now
        wins = wins.filter { now.timeIntervalSince($0.date) <= DifficultyAdvisor.window } + [Win(date: now, difficulty: game.difficulty)]
        save(wins, Key.wins)
        let record = record(for: game.difficulty)
        guard game.score > record else { return }
        isShowingClosure = record > 0
        records[game.difficulty] = game.score
        save(records, Key.records)
    }

    private func preferencesChanged() {
        save(preferences, Key.preferences)
        if !preferences.hasMistakeLimit { update { $0.turnOffMistakeLimit() } }
    }

    private func save(_ value: some Encodable, _ key: String) {
        defaults.set(try? JSONEncoder().encode(value), forKey: key)
    }

    private static func decode<T: Decodable>(_ type: T.Type, _ data: Data?) -> T? {
        data.flatMap { try? JSONDecoder().decode(type, from: $0) }
    }

    private enum Key {
        static let game = "game"
        static let records = "records"
        static let wins = "wins"
        static let lastDailyDay = "lastDailyDay"
        static let preferences = "preferences"
    }
}
