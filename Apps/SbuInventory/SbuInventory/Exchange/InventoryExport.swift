import Foundation
import SwiftData

/// Writes the whole inventory out: a CSV file, or a ZIP with that CSV and every photo.
enum InventoryExport {
    /// The CSV's name inside the archive.
    nonisolated static let csvName = "inventory.csv"
    nonisolated static let photosFolder = "photos/"

    /// Every folder and item as file lines, folders first, both by path; with the photos each item names.
    static func rows(in context: ModelContext, calendar: Calendar) -> (rows: [InventoryRow], fields: [FieldColumn], photos: [(path: String, photo: ItemPhoto)]) {
        let folders = (try? context.fetch(FetchDescriptor<Folder>())) ?? []
        let items = (try? context.fetch(FetchDescriptor<Item>())) ?? []
        let definitions = (try? context.fetch(FetchDescriptor<FieldDefinition>(sortBy: [SortDescriptor(\.order)]))) ?? []
        let tree = InventoryTree(folders: folders.map(\.node), items: [])
        let currency = Locale.current.currency?.identifier ?? "EUR"
        let fields = definitions.map { FieldColumn(name: $0.name, kind: $0.kind) }

        let folderRows = folders.map { folder in
            var row = InventoryRow()
            row.kind = .folder
            row.name = folder.name
            row.path = tree.path(of: folder.parent?.uuid)
            row.code = folder.code
            return row
        }
        var photos: [(path: String, photo: ItemPhoto)] = []
        let itemRows = items.map { item in
            var row = InventoryRow()
            row.id = item.uuid
            row.name = item.name
            row.quantity = item.quantity
            row.minimumQuantity = item.minimumQuantity
            row.path = tree.path(of: item.folder?.uuid)
            row.unitPrice = item.unitPrice
            row.currency = currency
            row.purchaseDate = item.purchaseDate
            row.tags = item.tags
            row.code = item.code
            row.notes = item.notes
            for photo in item.sortedPhotos {
                guard let data = photo.data else { continue }
                let path = photosFolder + photo.uuid.uuidString + "." + PhotoProcessor.fileExtension(of: data)
                row.photos.append(path)
                photos.append((path, photo))
            }
            row.fields = item.sortedFieldValues.compactMap { value in
                guard let definition = value.definition, !value.isEmpty else { return nil }
                return CustomFieldCell(column: FieldColumn(name: definition.name, kind: definition.kind), value: value.fileText(calendar: calendar))
            }
            return row
        }
        let byPath: (InventoryRow, InventoryRow) -> Bool = { first, second in
            let firstKey = (first.path + [first.name]).joined(separator: "\u{1}")
            let secondKey = (second.path + [second.name]).joined(separator: "\u{1}")
            return firstKey.localizedStandardCompare(secondKey) == .orderedAscending
        }
        return (folderRows.sorted(by: byPath) + itemRows.sorted(by: byPath), fields, photos)
    }

    /// Writes `sbu-inventory-<day>.csv` into `directory` and returns its URL.
    static func writeCSV(from context: ModelContext, to directory: URL = .temporaryDirectory, date: Date = .now, calendar: Calendar = .current) throws -> URL {
        let export = rows(in: context, calendar: calendar)
        let url = directory.appending(path: "sbu-inventory-\(CSVValue.day(date, calendar: calendar)).csv")
        try Data(InventoryCSV.text(export.rows, fields: export.fields, calendar: calendar).utf8).write(to: url, options: .atomic)
        return url
    }

    /// Writes `sbu-inventory-<day>.zip` into `directory`, with `inventory.csv` and the `photos` folder, and returns its URL.
    static func writeArchive(from context: ModelContext, to directory: URL = .temporaryDirectory, date: Date = .now, calendar: Calendar = .current) throws -> URL {
        let export = rows(in: context, calendar: calendar)
        let url = directory.appending(path: "sbu-inventory-\(CSVValue.day(date, calendar: calendar)).zip")
        let writer = try ZipWriter(url: url, date: date, calendar: calendar)
        try writer.add(csvName, data: Data(InventoryCSV.text(export.rows, fields: export.fields, calendar: calendar).utf8))
        for (path, photo) in export.photos {
            guard let data = photo.data else { continue }
            try writer.add(path, data: data)
        }
        try writer.finish()
        return url
    }
}
