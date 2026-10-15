import Foundation

/// Turns the rows of a CSV file into fuel-ups and services, with the columns and units you chose.
///
/// Rows without a date, or fuel-ups without an odometer reading or a quantity, are skipped; so are
/// entries already in the log (a fuel-up on the same day at the same reading, a service on the same
/// day with the same name), which makes importing the same file twice harmless.
nonisolated struct CSVImporter: Sendable {
    struct Options: Equatable, Sendable {
        var distanceUnit: DistanceUnit
        var volumeUnit: VolumeUnit
        var dateOrder: DateOrder
    }

    struct Result: Equatable, Sendable {
        var entries: [ImportedEntry] = []
        /// Rows that could not be read.
        var unreadable = 0
        /// Rows already in the log, or twice in the file.
        var duplicates = 0
    }

    static let serviceTypes: Set<String> = ["intervento", "service", "servizio", "manutenzione", "maintenance", "expense", "spesa"]

    let header: [String]
    let rows: [[String]]

    /// Reads a file's text: the first non-empty line is the header.
    init?(text: String) {
        let table = CSVTable.rows(text)
        guard let header = table.first, table.count > 1 else { return nil }
        self.header = header.map { $0.trimmingCharacters(in: .whitespaces) }
        rows = Array(table.dropFirst())
    }

    func entries(mapping: [ImportField: Int], options: Options, existing: [ImportedEntry], calendar: Calendar) -> Result {
        var result = Result()
        var seen = existing
        for row in rows {
            guard let entry = entry(row, mapping: mapping, options: options, calendar: calendar) else {
                result.unreadable += 1
                continue
            }
            if seen.contains(where: { Self.isSame($0, entry, calendar: calendar) }) {
                result.duplicates += 1
                continue
            }
            seen.append(entry)
            result.entries.append(entry)
        }
        return result
    }

    /// The text of a field's column in a row, trimmed; empty when the field has no column.
    static func cell(_ field: ImportField, in row: [String], mapping: [ImportField: Int]) -> String {
        guard let index = mapping[field], row.indices.contains(index) else { return "" }
        return row[index].trimmingCharacters(in: .whitespaces)
    }

    private func entry(_ row: [String], mapping: [ImportField: Int], options: Options, calendar: Calendar) -> ImportedEntry? {
        func cell(_ field: ImportField) -> String { Self.cell(field, in: row, mapping: mapping) }
        guard let date = options.dateOrder.date(from: cell(.date), calendar: calendar) else { return nil }
        let odometerKm = CSVValue.double(cell(.odometer), isReading: true).flatMap { $0 > 0 ? options.distanceUnit.km(from: $0) : nil }
        let note = cell(.note)
        if Self.serviceTypes.contains(cell(.type).lowercased()) {
            let title = cell(.service)
            let cost = CSVValue.decimal(cell(.totalPrice)) ?? 0
            return .service(title: title.isEmpty ? String(localized: "Intervento") : title, date: date, odometerKm: odometerKm, cost: max(cost, 0), note: note)
        }
        guard let odometerKm, let quantity = CSVValue.double(cell(.quantity)), quantity > 0 else { return nil }
        let litres = options.volumeUnit.litres(from: quantity)
        let total: Decimal
        if let value = CSVValue.decimal(cell(.totalPrice)) {
            total = value
        } else if let unit = CSVValue.decimal(cell(.unitPrice)) {
            total = FuelUpDraft.rounded(unit * Decimal(quantity), scale: 2)
        } else {
            total = 0
        }
        var isFull = true
        if mapping[.full] != nil { isFull = CSVValue.flag(cell(.full)) }
        if mapping[.partial] != nil, CSVValue.flag(cell(.partial)) { isFull = false }
        let record = FillRecord(date: date, odometerKm: odometerKm, litres: litres, isFull: isFull,
                                missedPrevious: CSVValue.flag(cell(.missed)), totalPrice: max(total, 0))
        return .fuel(record, station: cell(.station), note: note)
    }

    private static func isSame(_ lhs: ImportedEntry, _ rhs: ImportedEntry, calendar: Calendar) -> Bool {
        guard calendar.isDate(lhs.date, inSameDayAs: rhs.date) else { return false }
        switch (lhs, rhs) {
        case let (.fuel(left, _, _), .fuel(right, _, _)):
            return abs(left.odometerKm - right.odometerKm) < 0.5
        case let (.service(leftTitle, _, _, _, _), .service(rightTitle, _, _, _, _)):
            return leftTitle.localizedCaseInsensitiveCompare(rightTitle) == .orderedSame
        default:
            return false
        }
    }
}
