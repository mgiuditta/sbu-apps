import CoreGraphics

/// Where the lines of a grid fall on a picture: the pure geometry behind the overlay, the
/// export and the PDF, so the three always agree.
///
/// Lines start from the top left corner, one cell apart. When the cells do not fit a whole number
/// of times, the last column or row is cut where the picture ends, as on a real sheet ruled from
/// its corner.
nonisolated struct GridLayout: Equatable, Sendable {
    /// Strokes and numbers are drawn at this scale on a picture whose shorter side is this long,
    /// and grow with it: the export at full resolution looks like the screen.
    static let referenceSide: CGFloat = 360
    /// Beyond this many columns or rows the grid would be a grey veil: it is not drawn.
    static let maximumCount = 400

    let size: CGSize
    let cell: CGSize
    /// Columns, the last one possibly cut.
    let columnCount: Int
    /// Rows, the last one possibly cut.
    let rowCount: Int
    /// The x of every line inside the picture, left to right; the frame is not included.
    let verticalLines: [CGFloat]
    /// The y of every line inside the picture, top to bottom; the frame is not included.
    let horizontalLines: [CGFloat]

    init(size: CGSize, rule: CellRule) {
        self.size = size
        let cell = rule.cellSize(in: size)
        let columns = Self.count(length: size.width, step: cell.width)
        let rows = Self.count(length: size.height, step: cell.height)
        guard columns > 0, rows > 0, columns <= Self.maximumCount, rows <= Self.maximumCount else {
            self.cell = .zero
            columnCount = 0
            rowCount = 0
            verticalLines = []
            horizontalLines = []
            return
        }
        self.cell = cell
        columnCount = columns
        rowCount = rows
        verticalLines = (1..<columns).map { CGFloat($0) * cell.width }
        horizontalLines = (1..<rows).map { CGFloat($0) * cell.height }
    }

    /// Whether there is a grid to draw.
    var isEmpty: Bool { columnCount == 0 }

    /// How many cells of `step` it takes to cover `length`, the last one possibly cut. A leftover
    /// thinner than a thousandth of a cell is rounding, not a column.
    static func count(length: CGFloat, step: CGFloat) -> Int {
        guard length.isFinite, step.isFinite, length > 0, step > 0 else { return 0 }
        let cells = length / step
        guard cells <= CGFloat(maximumCount + 1) else { return maximumCount + 1 }
        return max(Int((cells - 0.001).rounded(.up)), 1)
    }

    /// Both diagonals of every cell, whole: the last column and row run past the picture, which
    /// clips them, so the diagonals keep the same angle everywhere.
    var diagonals: [GridSegment] {
        guard isEmpty == false else { return [] }
        var segments: [GridSegment] = []
        segments.reserveCapacity(columnCount * rowCount * 2)
        for row in 0..<rowCount {
            for column in 0..<columnCount {
                let minX = CGFloat(column) * cell.width
                let minY = CGFloat(row) * cell.height
                let maxX = minX + cell.width
                let maxY = minY + cell.height
                segments.append(GridSegment(start: CGPoint(x: minX, y: minY), end: CGPoint(x: maxX, y: maxY)))
                segments.append(GridSegment(start: CGPoint(x: maxX, y: minY), end: CGPoint(x: minX, y: maxY)))
            }
        }
        return segments
    }

    /// The middle of the visible part of every column, for its number.
    var columnCenters: [CGFloat] {
        (0..<columnCount).map { column in
            let start = CGFloat(column) * cell.width
            return (start + min(start + cell.width, size.width)) / 2
        }
    }

    /// The middle of the visible part of every row, for its number.
    var rowCenters: [CGFloat] {
        (0..<rowCount).map { row in
            let start = CGFloat(row) * cell.height
            return (start + min(start + cell.height, size.height)) / 2
        }
    }

    /// How much strokes and numbers grow on this picture compared with the reference.
    var scale: CGFloat {
        guard size.width.isFinite, size.height.isFinite, size.width > 0, size.height > 0 else { return 0 }
        return min(size.width, size.height) / Self.referenceSide
    }

    /// The width of the lines for a chosen line width, never wider than a fifth of a cell.
    func strokeWidth(for lineWidth: Double) -> CGFloat {
        guard isEmpty == false, lineWidth.isFinite, lineWidth > 0 else { return 0 }
        return min(CGFloat(lineWidth) * scale, min(cell.width, cell.height) / 5)
    }

    /// The point size of the row and column numbers: a third of a cell, kept between 8 and 14
    /// points at the reference size so they stay legible and inside the cell.
    var numberSize: CGFloat {
        guard isEmpty == false else { return 0 }
        let third = min(cell.width, cell.height) / 3
        return min(max(third, 8 * scale), 14 * scale)
    }
}
