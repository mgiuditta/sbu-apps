import CoreGraphics

/// How big a cell is on a picture of a given size.
nonisolated enum CellRule: Hashable, Sendable {
    /// The picture split into equal columns and rows; cells take the picture's shape.
    case divide(columns: Int, rows: Int)
    /// Square cells, `columns` across; the last row is cut where the picture ends.
    case square(columns: Int)
    /// Square cells of a real length on a sheet `paperWidth` wide, in the same unit: the picture
    /// is the sheet, so the last column and row are cut where the sheet ends.
    case physical(cellLength: Double, paperWidth: Double)

    /// The cell size on a picture of `size`; zero when either makes no sense.
    func cellSize(in size: CGSize) -> CGSize {
        guard size.width.isFinite, size.height.isFinite, size.width > 0, size.height > 0 else { return .zero }
        switch self {
        case let .divide(columns, rows):
            guard columns > 0, rows > 0 else { return .zero }
            return CGSize(width: size.width / CGFloat(columns), height: size.height / CGFloat(rows))
        case let .square(columns):
            guard columns > 0 else { return .zero }
            let side = size.width / CGFloat(columns)
            return CGSize(width: side, height: side)
        case let .physical(cellLength, paperWidth):
            guard cellLength.isFinite, paperWidth.isFinite, cellLength > 0, paperWidth > 0 else { return .zero }
            let side = size.width * cellLength / paperWidth
            return CGSize(width: side, height: side)
        }
    }
}
