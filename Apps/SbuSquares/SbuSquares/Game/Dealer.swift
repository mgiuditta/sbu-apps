/// How the original deals three pieces: strategies that read the board, each returning catalog
/// indices, all drawing from the game's seeded generator.
nonisolated enum Dealer {
    /// Shapes of three cells or fewer, out of the pool past 2000 points.
    static let small = Set([1, 6, 27, 28, 15, 3, 2, 5, 4, 37, 38, 39, 40, 41].map(Piece.index(ofID:)))
    /// The random pool: every shape but the single cell, which comes only as a last resort.
    static let pool = Array(Piece.catalog.indices.dropFirst())
    /// Cells a tray needs, at least, to raise the entropy.
    static let entropyCells = 15
    /// The triple of last resort.
    static let fallback = [5, 4, 5].map(Piece.index(ofID:))
    /// Score above which the small shapes leave the pool.
    static let smallLimit = 2000
    /// Trays remembered to spot a loop.
    static let memory = 10

    // ponytail: random draws are capped like the original's 100 ms timeout, but by count so a seed always deals the same.
    private static let attempts = 50
    private static let hardBudget = 200

    /// Three pieces that can all go down: random picks among those that fit now, else two single
    /// cells around the piece that leaves the tidiest board.
    static func randomNoDeath(pool: [Int], on board: BitBoard, using generator: inout SeededGenerator) -> [Int] {
        let fitting = pool.filter { board.fits(piece: $0) }
        let candidates = fitting.isEmpty ? [Piece.single] : fitting
        for _ in 0..<attempts {
            let triple = (0..<3).map { _ in generator.element(of: candidates) }
            if board.survives(triple) { return triple }
        }
        return [Piece.single, tidiest(pool: pool, on: board), Piece.single]
    }

    /// Entropy: three pieces of 15 cells or more that can all go down and leave the board rougher,
    /// more filled ↔ empty changes, even each put where it fits tidiest; `nil` if none turns up.
    static func entropy(pool: [Int], on board: BitBoard, using generator: inout SeededGenerator) -> [Int]? {
        let fitting = pool.filter { board.fits(piece: $0) }
        guard !fitting.isEmpty else { return nil }
        draw: for _ in 0..<attempts {
            let triple = (0..<3).map { _ in generator.element(of: fitting) }
            guard triple.reduce(0, { $0 + Piece.catalog[$1].cells.count }) >= entropyCells, board.survives(triple) else { continue }
            var after = board
            for piece in triple {
                guard let mask = tidiestMask(of: piece, on: after) else { continue draw }
                after.put(mask)
            }
            if after.edge > board.edge { return triple }
        }
        return nil
    }

    /// The puzzle: two pieces that fit and a third that fits only once the first two complete a
    /// line, the triple where that happens most often; `nil` if every piece fits.
    static func hard(pool: [Int], on board: BitBoard, using generator: inout SeededGenerator) -> [Int]? {
        let fitting = generator.shuffled(pool.filter { board.fits(piece: $0) })
        let blocked = generator.shuffled(pool.filter { !board.fits(piece: $0) })
        var best: (triple: [Int], ratio: Double)?
        var budget = hardBudget
        for third in blocked {
            for (index, first) in fitting.enumerated() {
                for second in fitting[index...] {
                    guard budget > 0 else { return best?.triple }
                    budget -= 1
                    let triple = [first, second, third]
                    let ratio = unlockRatio(triple, on: board)
                    if ratio > (best?.ratio ?? 0) { best = (triple, ratio) }
                }
            }
        }
        return best?.triple
    }

    /// Of every way to put two of `triple` down, in every order, the share that completes a line
    /// and leaves room for the third.
    static func unlockRatio(_ triple: [Int], on board: BitBoard) -> Double {
        var tries = 0
        var wins = 0
        for (x, y, z) in [(0, 1, 2), (0, 2, 1), (1, 0, 2), (1, 2, 0), (2, 0, 1), (2, 1, 0)] {
            for first in BitBoard.placements[triple[x]] where board.fits(first) {
                var afterFirst = board
                let firstLines = afterFirst.put(first)
                for second in BitBoard.placements[triple[y]] where afterFirst.fits(second) {
                    tries += 1
                    var afterSecond = afterFirst
                    if firstLines + afterSecond.put(second) > 0, afterSecond.fits(piece: triple[z]) { wins += 1 }
                }
            }
        }
        return tries == 0 ? 0 : Double(wins) / Double(tries)
    }

    /// Fill and clear: for each slot, a piece that covers the last empty cell of a row or column;
    /// `nil` if no line is one cell short.
    static func fill(pool: [Int], on board: BitBoard, using generator: inout SeededGenerator) -> [Int]? {
        var board = board
        var triple: [Int] = []
        for _ in 0..<3 {
            var pick: (piece: Int, mask: UInt64)?
            search: for hole in generator.shuffled(board.lastHoles) {
                for piece in generator.shuffled(pool) {
                    if let mask = BitBoard.placements[piece].first(where: { $0 & hole != 0 && board.fits($0) }) {
                        pick = (piece, mask)
                        break search
                    }
                }
            }
            if pick == nil {
                guard !triple.isEmpty else { return nil }
                let fitting = pool.filter { board.fits(piece: $0) }
                let piece = fitting.isEmpty ? Piece.single : generator.element(of: fitting)
                pick = BitBoard.placements[piece].first(where: board.fits).map { (piece, $0) }
            }
            guard let pick else { return triple + Array(repeating: Piece.single, count: 3 - triple.count) }
            board.put(pick.mask)
            triple.append(pick.piece)
        }
        return triple
    }

    /// Against farming: three pieces that fit together and cannot complete a line anywhere now;
    /// `nil` if there are none.
    static func noLines(pool: [Int], on board: BitBoard, using generator: inout SeededGenerator) -> [Int]? {
        let quiet = pool.filter { piece in
            let masks = BitBoard.placements[piece].filter(board.fits)
            return !masks.isEmpty && !masks.contains(where: board.completes)
        }
        guard !quiet.isEmpty else { return nil }
        for _ in 0..<attempts {
            let triple = (0..<3).map { _ in generator.element(of: quiet) }
            if board.survives(triple) { return triple }
        }
        return nil
    }

    /// Whether the last trays repeat, two to five at a time.
    static func isLoop(_ recent: [[Int]]) -> Bool {
        (2...5).contains { length in
            guard recent.count >= 2 * length else { return false }
            let tail = Array(recent.suffix(2 * length))
            return Array(tail.prefix(length)) == Array(tail.suffix(length))
        }
    }

    /// The safety check: `triple` if it can all go down, else with its middle piece, then its last
    /// two, redrawn, else a random triple that can.
    static func secured(_ triple: [Int], pool: [Int], on board: BitBoard, using generator: inout SeededGenerator) -> [Int] {
        if triple.count == 3, board.survives(triple) { return triple }
        let fitting = pool.filter { board.fits(piece: $0) }
        if triple.count == 3, !fitting.isEmpty {
            for redrawn in [[1], [1, 2]] {
                for _ in 0..<attempts {
                    var candidate = triple
                    for slot in redrawn { candidate[slot] = generator.element(of: fitting) }
                    if board.survives(candidate) { return candidate }
                }
            }
        }
        return randomNoDeath(pool: pool, on: board, using: &generator)
    }

    /// The final check: a tray equal to the last one, or three of the same shape, gets a new middle piece.
    static func varied(_ triple: [Int], after previous: [Int]?, pool: [Int], on board: BitBoard, using generator: inout SeededGenerator) -> [Int] {
        guard triple.count == 3 else { return fallback }
        guard triple == previous || Set(triple).count == 1 else { return triple }
        let others = pool.filter { $0 != triple[1] && board.fits(piece: $0) }
        guard !others.isEmpty else { return triple }
        for _ in 0..<attempts {
            var candidate = triple
            candidate[1] = generator.element(of: others)
            if board.survives(candidate) { return candidate }
        }
        return triple
    }

    /// The position of `piece` that leaves the fewest filled ↔ empty changes, `nil` if it does not fit.
    private static func tidiestMask(of piece: Int, on board: BitBoard) -> UInt64? {
        BitBoard.placements[piece].filter(board.fits).min { first, second in
            var afterFirst = board, afterSecond = board
            afterFirst.put(first)
            afterSecond.put(second)
            return afterFirst.edge < afterSecond.edge
        }
    }

    /// The piece and position that leave the fewest filled ↔ empty changes.
    private static func tidiest(pool: [Int], on board: BitBoard) -> Int {
        var best = (piece: Piece.single, edge: Int.max)
        for piece in pool {
            for mask in BitBoard.placements[piece] where board.fits(mask) {
                var after = board
                after.put(mask)
                if after.edge <= best.edge { best = (piece, after.edge) }
            }
        }
        return best.piece
    }
}
