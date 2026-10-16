import Foundation

/// The one figure of the grid screen. With a sheet, the side of a cell ("2 cm"), since that is
/// what you rule on the paper; without one, columns × rows ("4 × 6").
nonisolated struct GridFigure: Equatable, Sendable {
    nonisolated enum Kind: Equatable, Sendable {
        /// The side of a cell in the sheet's unit.
        case cell(length: Double, unit: LengthUnit)
        /// Columns × rows.
        case count(GridCount)
    }

    let kind: Kind
    /// What VoiceOver reads for the figure.
    let spoken: String
    /// The line under the figure: the sheet and its cells, or whether the cells are square.
    let context: String?

    init(paper: PaperSettings, settings: GridSettings, count: GridCount, locale: Locale = .autoupdatingCurrent) {
        if paper.format.isSheet {
            kind = .cell(length: paper.cellLength, unit: paper.unit)
            spoken = LengthFormat.spoken(paper.cellLength, unit: paper.unit, locale: locale)
            let sheet = String(localized: paper.format.title)
            let orientation = String(localized: paper.orientation.title).lowercased(with: locale)
            let cells = GridCountFormatStyle(locale: locale).format(count)
            context = String(localized: "\(sheet) \(orientation), \(cells) celle", comment: "Under the cell size: A4 verticale, 11 × 15 celle.")
        } else {
            kind = .count(count)
            spoken = count.spoken
            context = settings.hasSquareCells ? String(localized: "Celle quadrate") : nil
        }
    }
}
