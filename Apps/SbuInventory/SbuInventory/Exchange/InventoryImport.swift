import Foundation
import SwiftData

/// Adds the lines of an inventory file to the store: folders by path, created when missing, items with
/// their photos and fields. An item whose id is already here is skipped, so importing your own export
/// twice never doubles anything.
enum InventoryImport {
    static func apply(_ file: ImportFile, into context: ModelContext, calendar: Calendar = .current) -> ImportResult {
        var result = ImportResult()
        var folders = FolderResolver(context: context)
        let existingIDs = Set(((try? context.fetch(FetchDescriptor<Item>())) ?? []).map(\.uuid))
        var definitions = ((try? context.fetch(FetchDescriptor<FieldDefinition>())) ?? [])
        var seenIDs: Set<UUID> = []

        for row in file.rows where row.kind == .folder {
            let folder = folders.folder(at: row.path + [row.name])
            if let code = row.code, let folder {
                LabelLinker.link(code, to: .folder(folder), in: context)
            }
        }

        for row in file.rows where row.kind == .item {
            if let id = row.id, existingIDs.contains(id) || !seenIDs.insert(id).inserted {
                result.skipped += 1
                continue
            }
            let item = Item(name: row.name, quantity: row.quantity, folder: folders.folder(at: row.path))
            if let id = row.id { item.uuid = id }
            item.minimumQuantity = row.minimumQuantity
            item.unitPrice = row.unitPrice
            item.purchaseDate = row.purchaseDate
            item.tags = TagList.normalized(row.tags)
            item.notes = row.notes
            context.insert(item)

            for (order, path) in row.photos.prefix(PhotoProcessor.maxPhotos).enumerated() {
                guard let data = file.photos[path], let processed = PhotoProcessor.prepareImported(data) else { continue }
                let photo = ItemPhoto(data: processed.data, thumbnail: processed.thumbnail, order: order)
                context.insert(photo)
                photo.item = item
            }
            for cell in row.fields {
                let definition = definitions.first { SearchKey.fold($0.name) == SearchKey.fold(cell.column.name) } ?? {
                    let created = FieldDefinition(name: cell.column.name, kind: cell.column.kind, order: (definitions.map(\.order).max() ?? -1) + 1)
                    context.insert(created)
                    definitions.append(created)
                    return created
                }()
                let value = FieldValue(definition: definition, item: item)
                context.insert(value)
                value.setFileText(cell.value, kind: definition.kind, calendar: calendar)
            }
            if let code = row.code {
                LabelLinker.link(code, to: .item(item), in: context)
            }
            item.refreshSearchKey()
            result.added += 1
        }
        result.folders = folders.created
        try? context.save()
        return result
    }
}
