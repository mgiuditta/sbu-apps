import Foundation

/// How many columns and rows a grid has, as the figure of the grid screen shows them: "4 × 6".
nonisolated struct GridCount: Codable, Hashable, Sendable {
    let columns: Int
    let rows: Int

    init(columns: Int, rows: Int) {
        self.columns = columns
        self.rows = rows
    }

    init(_ layout: GridLayout) {
        self.init(columns: layout.columnCount, rows: layout.rowCount)
    }

    /// What VoiceOver reads for the figure: "4 colonne per 6 righe".
    var spoken: String {
        let columns = String(localized: "\(columns) colonne", comment: "Plural: 1 colonna, 2 colonne.")
        let rows = String(localized: "\(rows) righe", comment: "Plural: 1 riga, 2 righe.")
        return String(localized: "\(columns) per \(rows)", comment: "Columns by rows, spoken: 4 colonne per 6 righe.")
    }
}
