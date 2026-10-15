import Foundation

/// The inventory as a CSV file: one line per item, plus one per folder so empty folders and box labels
/// come back too. Numbers use a point and days are yyyy-MM-dd, so the file reads the same in any language.
nonisolated enum InventoryCSV {
    /// Why a file can't be read.
    enum Failure: Error, Equatable {
        /// Nothing in it, or not text.
        case empty
        /// No column for the item's name.
        case noNameColumn
    }

    static let pathSeparator = " > "
    static let listSeparator = "; "

    // MARK: - Writing

    static func text(_ rows: [InventoryRow], fields: [FieldColumn], calendar: Calendar) -> String {
        let fixed: [InventoryColumn] = [.kind, .id, .name, .quantity, .minimum, .path, .price, .currency, .date, .tags, .code, .notes, .photos]
        let header = fixed.map(\.header) + fields.map(\.header)
        let lines = rows.map { row in
            let values: [String] = [
                row.kind.rawValue,
                row.id?.uuidString ?? "",
                row.name,
                row.kind == .item ? String(row.quantity) : "",
                row.minimumQuantity.map(String.init) ?? "",
                row.path.joined(separator: pathSeparator),
                row.unitPrice.map(CSVValue.text) ?? "",
                row.unitPrice == nil ? "" : row.currency ?? "",
                row.purchaseDate.map { CSVValue.day($0, calendar: calendar) } ?? "",
                row.tags.joined(separator: listSeparator),
                row.code ?? "",
                row.notes,
                row.photos.joined(separator: listSeparator),
            ]
            let custom = fields.map { column in row.fields.first { $0.column == column }?.value ?? "" }
            return CSVTable.line(values + custom)
        }
        return "\u{FEFF}" + ([CSVTable.line(header)] + lines).joined(separator: "\n") + "\n"
    }

    // MARK: - Reading

    static func rows(_ text: String, calendar: Calendar) throws(Failure) -> [InventoryRow] {
        let table = CSVTable.rows(text)
        guard let header = table.first else { throw .empty }
        var columns: [InventoryColumn: Int] = [:]
        var fieldColumns: [(FieldColumn, Int)] = []
        for (index, title) in header.enumerated() {
            if let field = FieldColumn(header: title) {
                fieldColumns.append((field, index))
            } else if let column = InventoryColumn.match(title), columns[column] == nil {
                columns[column] = index
            }
        }
        guard columns[.name] != nil else { throw .noNameColumn }

        return table.dropFirst().compactMap { cells in
            func cell(_ column: InventoryColumn) -> String {
                guard let index = columns[column], index < cells.count else { return "" }
                return cells[index].trimmingCharacters(in: .whitespacesAndNewlines)
            }
            var row = InventoryRow()
            row.name = cell(.name)
            guard !row.name.isEmpty else { return nil }
            row.kind = InventoryRowKind(text: cell(.kind))
            row.id = UUID(uuidString: cell(.id))
            row.quantity = max(CSVValue.integer(cell(.quantity)) ?? 1, 0)
            row.minimumQuantity = CSVValue.integer(cell(.minimum)).map { max($0, 0) }
            row.path = cell(.path)
                .split(whereSeparator: { $0 == ">" || $0 == "›" })
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
            row.unitPrice = CSVValue.decimal(cell(.price))
            row.currency = cell(.currency).isEmpty ? nil : cell(.currency).uppercased()
            row.purchaseDate = CSVValue.date(cell(.date), calendar: calendar)
            row.tags = list(cell(.tags), separators: ";,")
            row.code = cell(.code).isEmpty ? nil : cell(.code)
            row.notes = cell(.notes)
            row.photos = list(cell(.photos), separators: ";")
            row.fields = fieldColumns.compactMap { column, index in
                guard index < cells.count else { return nil }
                let value = cells[index].trimmingCharacters(in: .whitespacesAndNewlines)
                return value.isEmpty ? nil : CustomFieldCell(column: column, value: value)
            }
            return row
        }
    }

    private static func list(_ text: String, separators: String) -> [String] {
        text.split(whereSeparator: { separators.contains($0) })
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }
}
