/// The geometry of the 9×9 grid: cells are numbered 0 to 80, row by row.
nonisolated enum Units {
    static let size = 9
    static let box = 3
    static let cellCount = size * size

    static func row(of cell: Int) -> Int { cell / size }
    static func column(of cell: Int) -> Int { cell % size }
    static func box(of cell: Int) -> Int { row(of: cell) / box * box + column(of: cell) / box }

    static let rows: [[Int]] = (0..<size).map { row in (0..<size).map { row * size + $0 } }
    static let columns: [[Int]] = (0..<size).map { column in (0..<size).map { $0 * size + column } }
    static let boxes: [[Int]] = (0..<size).map { box in
        let top = box / Self.box * Self.box, left = box % Self.box * Self.box
        return (0..<size).map { (top + $0 / Self.box) * size + left + $0 % Self.box }
    }

    /// The other cells in the same row, column or box.
    static let peers: [[Int]] = (0..<cellCount).map { cell in
        Array(Set(rows[row(of: cell)] + columns[column(of: cell)] + boxes[box(of: cell)]).subtracting([cell])).sorted()
    }
}
