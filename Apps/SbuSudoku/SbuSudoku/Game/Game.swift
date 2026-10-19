import Foundation

/// One game with the original's rules.
///
/// - A digit is a mistake when it differs from the solution. Each wrong digit counts, the same one
///   again too; with the limit on, the third mistake ends the game.
/// - A note clears the cell's digit; a digit clears the cell's notes and, with the setting on,
///   takes itself out of the notes of its row, column and box.
/// - Tapping the digit a cell already holds clears it.
/// - Undo keeps 25 steps, and gives back neither points nor mistakes. Cells placed by a hint stay.
/// - A correct cell scores once: the most points within five seconds of the last correct cell, a
///   tenth less every five seconds after, never under a tenth; times five for each row, column and
///   box it completes. A hint reveals the selected cell, locks it, and scores the most points
///   plus the same. Nothing takes points away.
nonisolated struct Game: Codable, Hashable, Sendable {
    static let historyLimit = 25
    static let mistakeLimit = 3
    /// The seconds after which a correct cell is worth a tenth less.
    static let decayPeriod = 5.0
    /// A note bit that marks notes written by a hint: undo leaves them.
    static let hintNoteBit = 1 << (Units.size + 1)

    let difficulty: Difficulty
    let givens: [Int]
    let solution: [Int]
    /// The date of the Sudoku of the day this game plays, if it is one.
    let day: Date?

    /// 0 empty, 1 to 9 a digit the player can change, 10 to 18 a digit placed by a hint (9 + digit).
    private(set) var cells: [Int]
    /// Bit `n` is the note for digit `n`.
    private(set) var notes: [Int]
    /// The cells that have already scored.
    private(set) var rewarded: [Bool]
    private(set) var history: [Snapshot] = []
    private(set) var mistakes = 0
    private(set) var timePlayed = 0.0
    /// When the last correct cell was placed, in play time.
    private(set) var lastScoredTime = 0.0
    private(set) var score = 0
    private(set) var hintsUsed = 0
    /// Fixed when the game starts: during the game it can only be turned off.
    private(set) var hasMistakeLimit: Bool
    private(set) var failure: FailReason?
    var selected: Int?
    var isNoting = false

    init(puzzle: Puzzle, difficulty: Difficulty, hasMistakeLimit: Bool = true, day: Date? = nil) {
        self.difficulty = difficulty
        givens = puzzle.givens
        solution = puzzle.solution
        self.day = day
        self.hasMistakeLimit = hasMistakeLimit
        cells = Array(repeating: 0, count: Units.cellCount)
        notes = Array(repeating: 0, count: Units.cellCount)
        rewarded = Array(repeating: false, count: Units.cellCount)
    }

    // MARK: Reading

    /// The digit in a cell, 0 if empty.
    func value(at cell: Int) -> Int {
        if givens[cell] != 0 { return givens[cell] }
        let value = cells[cell]
        return value > Units.size ? value - Units.size : value
    }

    func notes(at cell: Int) -> Int { notes[cell] }

    func isGiven(_ cell: Int) -> Bool { givens[cell] != 0 }

    func isMutable(_ cell: Int) -> Bool {
        givens[cell] == 0 && cells[cell] <= Units.size
    }

    func state(of cell: Int, rules: Rules) -> CellState {
        if !isMutable(cell) { return .constant }
        let value = value(at: cell)
        if value == 0 { return .empty }
        guard rules.checksMistakes else { return .ok }
        return value == solution[cell] ? .ok : .error
    }

    /// How many more times a digit can go on the grid; wrong digits count too.
    func remaining(_ digit: Int) -> Int {
        max(0, Units.size - (0..<Units.cellCount).count { value(at: $0) == digit })
    }

    var isSolved: Bool {
        (0..<Units.cellCount).allSatisfy { value(at: $0) == solution[$0] }
    }

    var isOver: Bool { isSolved || failure != nil }

    /// Every cell holds a digit, but not the solution: only shown when nothing else gave it away.
    var isFilledWrong: Bool {
        (0..<Units.cellCount).allSatisfy { value(at: $0) != 0 } && !isSolved
    }

    var canUndo: Bool { !history.isEmpty && !isOver }

    // MARK: Moves

    /// A digit on the selected cell: a note while noting, otherwise the digit, or nothing if the
    /// cell already holds it.
    @discardableResult
    mutating func enter(_ digit: Int, rules: Rules) -> Entry {
        guard let cell = selected, !isOver else { return .ignored }
        guard isMutable(cell) else { return .given }
        if rules.checksMistakes, value(at: cell) == solution[cell] { return .alreadyCorrect }
        if isNoting {
            toggleNote(digit, at: cell)
            return .noted
        }
        if value(at: cell) == digit {
            clear(cell)
            return .erased
        }
        place(digit, at: cell, byHint: false, rules: rules)
        return .placed
    }

    /// Clears the selected cell's digit and notes.
    @discardableResult
    mutating func erase(rules: Rules) -> Entry {
        guard let cell = selected, !isOver else { return .ignored }
        guard isMutable(cell) else { return .given }
        if rules.checksMistakes, value(at: cell) == solution[cell] { return .alreadyCorrect }
        guard value(at: cell) != 0 || notes[cell] != 0 else { return .ignored }
        clear(cell)
        return .erased
    }

    /// Reveals the selected cell and locks it.
    @discardableResult
    mutating func hint(rules: Rules) -> Entry {
        guard let cell = selected, !isOver else { return .ignored }
        guard isMutable(cell) else { return .given }
        if value(at: cell) == solution[cell] { return .alreadyCorrect }
        hintsUsed += 1
        place(solution[cell], at: cell, byHint: true, rules: rules)
        return .placed
    }

    /// Takes back the last step. Cells placed by a hint and the notes a hint wrote stay; points
    /// and mistakes stay too.
    mutating func undo() {
        guard canUndo, let snapshot = history.popLast() else { return }
        for cell in 0..<Units.cellCount {
            let current = cells[cell], previous = snapshot.cells[cell]
            if current > Units.size || current == previous || (current == 0 && notes[cell] & Self.hintNoteBit != 0) {
                if notes[cell] & Self.hintNoteBit == 0 { notes[cell] = snapshot.notes[cell] }
            } else {
                cells[cell] = previous
                notes[cell] = snapshot.notes[cell]
                score(cell, completing: [], byHint: false)
            }
        }
        if let cell = snapshot.selected, cells[cell] <= Units.size { selected = cell }
    }

    /// After the third mistake: one mistake less, and the game goes on. The next mistake ends it again.
    mutating func takeSecondChance() {
        guard failure == .mistakes else { return }
        mistakes -= 1
        failure = nil
    }

    mutating func turnOffMistakeLimit() {
        hasMistakeLimit = false
    }

    mutating func addTime(_ seconds: Double) {
        guard !isOver, seconds > 0 else { return }
        timePlayed += seconds
    }

    // MARK: Rules

    private mutating func toggleNote(_ digit: Int, at cell: Int) {
        saveSnapshot()
        notes[cell] = (notes[cell] ^ (1 << digit)) & ~Self.hintNoteBit
        cells[cell] = 0
    }

    private mutating func clear(_ cell: Int) {
        saveSnapshot()
        cells[cell] = 0
        notes[cell] = 0
    }

    private mutating func place(_ digit: Int, at cell: Int, byHint: Bool, rules: Rules) {
        if !byHint { saveSnapshot() }
        cells[cell] = byHint ? Units.size + digit : digit
        notes[cell] = 0
        let state = state(of: cell, rules: rules)
        let completed = state == .ok || (state == .constant && byHint) ? completedGroups(at: cell, rules: rules) : []
        score(cell, completing: completed, byHint: byHint)
        if state == .error { mistakes += 1 }
        if rules.removesNotes {
            for peer in Units.peers[cell] { notes[peer] &= ~(1 << digit) }
        }
        if digit != solution[cell], hasMistakeLimit, mistakes >= Self.mistakeLimit {
            failure = .mistakes
        }
    }

    private func completedGroups(at cell: Int, rules: Rules) -> CompletedGroups {
        let isFilledAndOk = { [self] (cell: Int) in [.ok, .constant].contains(state(of: cell, rules: rules)) }
        var groups: CompletedGroups = []
        if Units.rows[Units.row(of: cell)].allSatisfy(isFilledAndOk) { groups.insert(.row) }
        if Units.columns[Units.column(of: cell)].allSatisfy(isFilledAndOk) { groups.insert(.column) }
        if Units.boxes[Units.box(of: cell)].allSatisfy(isFilledAndOk) { groups.insert(.box) }
        if !groups.isEmpty, (0..<Units.cellCount).allSatisfy(isFilledAndOk) { groups.insert(.grid) }
        return groups
    }

    /// The points of a correct cell placed now, completing `groups`.
    func points(completing groups: CompletedGroups, byHint: Bool) -> Int {
        let steps = Int(((timePlayed - lastScoredTime) / Self.decayPeriod).rounded(.down))
        let base = min(max(difficulty.maxPoints - steps * difficulty.minPoints, difficulty.minPoints), difficulty.maxPoints)
        let multiplier = 5 * groups.count
        return byHint ? difficulty.maxPoints + base * multiplier : max(1, multiplier) * base
    }

    private mutating func score(_ cell: Int, completing groups: CompletedGroups, byHint: Bool) {
        guard value(at: cell) == solution[cell], !rewarded[cell] else { return }
        rewarded[cell] = true
        score += points(completing: groups, byHint: byHint)
        lastScoredTime = timePlayed
    }

    private mutating func saveSnapshot() {
        history.append(Snapshot(cells: cells, notes: notes, selected: selected))
        if history.count > Self.historyLimit { history.removeFirst(history.count - Self.historyLimit) }
    }
}
