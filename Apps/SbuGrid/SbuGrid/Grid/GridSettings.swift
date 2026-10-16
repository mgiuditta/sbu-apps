import Foundation

/// How the grid looks over the photo: the same choices, in the same order, as DrawinGrid's grid
/// settings, plus GridArt's diagonals and opacity.
///
/// Every value is clamped to its range, also when decoded: a stored value from an older version
/// or an absurd one can never draw zero columns or a line wider than a cell.
nonisolated struct GridSettings: Codable, Hashable, Sendable {
    static let columnRange = 1...50
    static let rowRange = 1...50
    /// In points on a photo whose shorter side is `GridLayout.referenceSide` long.
    static let lineWidthRange: ClosedRange<Double> = 0.5...8
    static let lineWidthStep = 0.5
    static let opacityRange: ClosedRange<Double> = 0.1...1
    static let opacityStep = 0.05

    private var storedColumns = 4
    private var storedRows = 6
    private var storedLineWidth = 1.0
    private var storedOpacity = 0.8

    var lineTone = LineTone.dark
    /// Square cells: the rows follow the columns and the photo's shape.
    var hasSquareCells = true
    var showsDiagonals = false
    var showsNumbers = false
    var isBlackAndWhite = false

    init() {}

    var columns: Int {
        get { storedColumns }
        set { storedColumns = Self.clamp(newValue, to: Self.columnRange) }
    }

    /// The rows the user chose; with square cells the grid ignores them and `GridLayout` counts its own.
    var rows: Int {
        get { storedRows }
        set { storedRows = Self.clamp(newValue, to: Self.rowRange) }
    }

    var lineWidth: Double {
        get { storedLineWidth }
        set { storedLineWidth = Self.clamp(newValue, to: Self.lineWidthRange) }
    }

    var opacity: Double {
        get { storedOpacity }
        set { storedOpacity = Self.clamp(newValue, to: Self.opacityRange) }
    }

    /// The rule that sizes the cells when no sheet of paper is set.
    var cellRule: CellRule {
        hasSquareCells ? .square(columns: columns) : .divide(columns: columns, rows: rows)
    }

    static func clamp(_ value: Int, to range: ClosedRange<Int>) -> Int {
        min(max(value, range.lowerBound), range.upperBound)
    }

    /// Not a number falls back to the lower bound.
    static func clamp(_ value: Double, to range: ClosedRange<Double>) -> Double {
        value.isNaN ? range.lowerBound : min(max(value, range.lowerBound), range.upperBound)
    }

    // MARK: Codable

    private enum CodingKeys: String, CodingKey {
        case columns, rows, lineWidth, opacity, lineTone, hasSquareCells, showsDiagonals, showsNumbers, isBlackAndWhite
    }

    /// Missing keys take the default and out-of-range values the nearest bound, so settings saved
    /// by any version always open.
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let defaults = GridSettings()
        columns = try container.decodeIfPresent(Int.self, forKey: .columns) ?? defaults.columns
        rows = try container.decodeIfPresent(Int.self, forKey: .rows) ?? defaults.rows
        lineWidth = try container.decodeIfPresent(Double.self, forKey: .lineWidth) ?? defaults.lineWidth
        opacity = try container.decodeIfPresent(Double.self, forKey: .opacity) ?? defaults.opacity
        lineTone = (try? container.decodeIfPresent(LineTone.self, forKey: .lineTone)) ?? defaults.lineTone
        hasSquareCells = try container.decodeIfPresent(Bool.self, forKey: .hasSquareCells) ?? defaults.hasSquareCells
        showsDiagonals = try container.decodeIfPresent(Bool.self, forKey: .showsDiagonals) ?? defaults.showsDiagonals
        showsNumbers = try container.decodeIfPresent(Bool.self, forKey: .showsNumbers) ?? defaults.showsNumbers
        isBlackAndWhite = try container.decodeIfPresent(Bool.self, forKey: .isBlackAndWhite) ?? defaults.isBlackAndWhite
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(columns, forKey: .columns)
        try container.encode(rows, forKey: .rows)
        try container.encode(lineWidth, forKey: .lineWidth)
        try container.encode(opacity, forKey: .opacity)
        try container.encode(lineTone, forKey: .lineTone)
        try container.encode(hasSquareCells, forKey: .hasSquareCells)
        try container.encode(showsDiagonals, forKey: .showsDiagonals)
        try container.encode(showsNumbers, forKey: .showsNumbers)
        try container.encode(isBlackAndWhite, forKey: .isBlackAndWhite)
    }
}
