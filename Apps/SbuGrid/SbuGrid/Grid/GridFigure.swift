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
    /// The figure as drawn, formatted for the locale: "2,5 cm", "4 × 6".
    let value: String
    /// What VoiceOver reads for the figure.
    let spoken: String
    /// The line under the figure: the sheet and its cells, or whether the cells are square.
    let context: String?
    /// The metadata line under the screen title: "Sbu · Griglia · A4", "Sbu · Griglia · Senza foglio".
    let cartiglio: String
    /// What VoiceOver reads for the figure zone: what it measures, the figure in words, the context.
    let accessibilityLabel: String

    init(paper: PaperSettings, settings: GridSettings, count: GridCount, locale: Locale = .autoupdatingCurrent) {
        let caption: String
        let sheetName: String
        if paper.format.isSheet {
            kind = .cell(length: paper.cellLength, unit: paper.unit)
            value = LengthFormat.short(paper.cellLength, unit: paper.unit, locale: locale)
            caption = String(localized: "Cella")
            let sheet = String(localized: paper.format.title)
            sheetName = sheet
            spoken = LengthFormat.spoken(paper.cellLength, unit: paper.unit, locale: locale)
            let orientation = String(localized: paper.orientation.title).lowercased(with: locale)
            let cells = GridCountFormatStyle(locale: locale).format(count)
            context = String(localized: "\(sheet) \(orientation), \(cells) celle", comment: "Under the cell size: A4 verticale, 11 × 15 celle.")
        } else {
            kind = .count(count)
            value = GridCountFormatStyle(locale: locale).format(count)
            caption = String(localized: "Griglia")
            sheetName = String(localized: "Senza foglio", comment: "Cartiglio of the grid screen when no sheet is chosen.")
            spoken = count.spoken
            context = settings.hasSquareCells ? String(localized: "Celle quadrate") : nil
        }
        cartiglio = ["Sbu", String(localized: "Griglia"), sheetName].joined(separator: " · ")
        accessibilityLabel = [caption, spoken, context].compactMap(\.self).joined(separator: ", ")
    }
}
