/// A puzzle with one solution: the cells it gives and the whole solution.
///
/// The original reads its puzzles from a catalog; these are generated on the device from a seed,
/// with the number of givens of the original's difficulties.
nonisolated struct Puzzle: Codable, Hashable, Sendable {
    /// The given value of each cell, 0 where the player fills it in.
    let givens: [Int]
    let solution: [Int]

    /// Fills a grid, then empties cells in a random order while the solution stays the only one,
    /// down to a number of givens drawn from the difficulty's range. When an attempt stops above
    /// the range, it starts again from a new grid, and keeps the closest of a few.
    init(difficulty: Difficulty, seed: UInt64) {
        var generator = SeededGenerator(seed: seed)
        let target = generator.int(in: difficulty.givens)
        var best: (givens: [Int], solution: [Int])?
        // ponytail: random removal reaches about 24 givens at best; a technique-graded generator if Extreme needs fewer.
        for _ in 0..<12 {
            let solution = Solver.filledGrid(using: &generator)
            var givens = solution
            var count = Units.cellCount
            for cell in generator.shuffled(Array(0..<Units.cellCount)) where count > target {
                let value = givens[cell]
                givens[cell] = 0
                if Solver.countSolutions(givens) == 1 {
                    count -= 1
                } else {
                    givens[cell] = value
                }
            }
            if best == nil || count < best!.givens.count(where: { $0 != 0 }) { best = (givens, solution) }
            if count <= difficulty.givens.upperBound { break }
        }
        givens = best!.givens
        solution = best!.solution
    }

    init(givens: [Int], solution: [Int]) {
        self.givens = givens
        self.solution = solution
    }
}
