/// Backtracking over candidate bitmasks, the cell with fewest candidates first.
nonisolated enum Solver {
    /// How many solutions `grid` has (0 is empty), counting no further than `limit`.
    static func countSolutions(_ grid: [Int], limit: Int = 2) -> Int {
        guard var state = State(grid) else { return 0 }
        var count = 0
        search(&state, count: &count, limit: limit, order: nil)
        return count
    }

    /// A complete valid grid, the digits tried in an order drawn from `generator`.
    static func filledGrid(using generator: inout SeededGenerator) -> [Int] {
        var state = State(Array(repeating: 0, count: Units.cellCount))!
        var count = 0
        let order = generator.shuffled(Array(1...Units.size))
        // One random order per cell keeps the search cheap and the grid uniform enough.
        let orders = (0..<Units.cellCount).map { _ in generator.shuffled(order) }
        search(&state, count: &count, limit: 1, order: orders)
        return state.solution
    }

    private struct State {
        var grid: [Int]
        var rows = [Int](repeating: 0, count: Units.size)
        var columns = [Int](repeating: 0, count: Units.size)
        var boxes = [Int](repeating: 0, count: Units.size)
        var solution: [Int] = []

        init?(_ grid: [Int]) {
            self.grid = grid
            for (cell, value) in grid.enumerated() where value != 0 {
                let bit = 1 << value
                let row = Units.row(of: cell), column = Units.column(of: cell), box = Units.box(of: cell)
                if rows[row] & bit != 0 || columns[column] & bit != 0 || boxes[box] & bit != 0 { return nil }
                rows[row] |= bit
                columns[column] |= bit
                boxes[box] |= bit
            }
        }

        func candidates(_ cell: Int) -> Int {
            ~(rows[Units.row(of: cell)] | columns[Units.column(of: cell)] | boxes[Units.box(of: cell)]) & 0b11_1111_1110
        }

        mutating func set(_ cell: Int, _ value: Int) {
            let bit = 1 << value
            grid[cell] = value
            rows[Units.row(of: cell)] ^= bit
            columns[Units.column(of: cell)] ^= bit
            boxes[Units.box(of: cell)] ^= bit
        }
    }

    private static func search(_ state: inout State, count: inout Int, limit: Int, order: [[Int]]?) {
        var best = -1, bestCandidates = 0, bestCount = Units.size + 1
        for cell in 0..<Units.cellCount where state.grid[cell] == 0 {
            let candidates = state.candidates(cell)
            let options = candidates.nonzeroBitCount
            if options < bestCount {
                best = cell
                bestCandidates = candidates
                bestCount = options
                if options <= 1 { break }
            }
        }
        guard best >= 0 else {
            count += 1
            if state.solution.isEmpty { state.solution = state.grid }
            return
        }
        for value in order?[best] ?? Array(1...Units.size) where bestCandidates & (1 << value) != 0 {
            state.set(best, value)
            search(&state, count: &count, limit: limit, order: order)
            state.set(best, value)
            state.grid[best] = 0
            if count >= limit { return }
        }
    }
}
