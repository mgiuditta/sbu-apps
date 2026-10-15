import Foundation
import SwiftData

/// The item form's working copy: nothing touches the store until you tap Salva.
struct ItemDraft: Equatable {
    var name = ""
    var quantity = 1
    /// The "Da ricomprare" threshold; `nil` when off.
    var minimumQuantity: Int?
    var unitPrice: Decimal?
    var purchaseDate: Date?
    var notes = ""
    var tags: [String] = []
    var code: String?
    var folder: Folder?
    var photos: [PhotoDraft] = []
    /// Custom field entries by field id.
    var fields: [UUID: FieldEntry] = [:]

    /// A new item in `folder`, with a scanned label already on it when there is one.
    init(folder: Folder?, code: String? = nil) {
        self.folder = folder
        self.code = code
    }

    init(item: Item) {
        name = item.name
        quantity = item.quantity
        minimumQuantity = item.minimumQuantity
        unitPrice = item.unitPrice
        purchaseDate = item.purchaseDate
        notes = item.notes
        tags = item.tags
        code = item.code
        folder = item.folder
        photos = item.sortedPhotos.compactMap { photo in
            guard let data = photo.data else { return nil }
            return PhotoDraft(id: photo.uuid, data: data, thumbnail: photo.thumbnail ?? Data())
        }
        for value in item.fieldValues ?? [] {
            guard let definition = value.definition else { continue }
            fields[definition.uuid] = FieldEntry(text: value.text ?? "", number: value.number, date: value.date)
        }
    }

    var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var canSave: Bool {
        !trimmedName.isEmpty
    }

    /// Adds a tag typed in the form, once, trimmed.
    mutating func addTag(_ text: String) {
        tags = TagList.normalized(tags + [text])
    }

    /// Writes the draft into `item`: photos in their new order (removed ones deleted), fields, label, search key.
    func apply(to item: Item, definitions: [FieldDefinition], context: ModelContext) {
        item.name = trimmedName
        item.quantity = max(quantity, 0)
        item.minimumQuantity = minimumQuantity.map { max($0, 0) }
        item.unitPrice = unitPrice.map { max($0, 0) }
        item.purchaseDate = purchaseDate
        item.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        item.tags = TagList.normalized(tags)
        item.folder = folder

        let kept = Set(photos.map(\.id))
        for photo in item.photos ?? [] where !kept.contains(photo.uuid) {
            context.delete(photo)
        }
        let existing = Dictionary((item.photos ?? []).map { ($0.uuid, $0) }, uniquingKeysWith: { first, _ in first })
        for (order, draft) in photos.prefix(PhotoProcessor.maxPhotos).enumerated() {
            if let photo = existing[draft.id] {
                photo.order = order
            } else {
                let photo = ItemPhoto(data: draft.data, thumbnail: draft.thumbnail, order: order)
                photo.uuid = draft.id
                context.insert(photo)
                photo.item = item
            }
        }

        for definition in definitions {
            let entry = fields[definition.uuid] ?? FieldEntry()
            let value = (item.fieldValues ?? []).first { $0.definition?.uuid == definition.uuid }
            if entry.isEmpty(for: definition.kind) {
                if let value { context.delete(value) }
                continue
            }
            let target = value ?? {
                let created = FieldValue(definition: definition, item: item)
                context.insert(created)
                return created
            }()
            target.text = definition.kind == .text ? entry.text.trimmingCharacters(in: .whitespacesAndNewlines) : nil
            target.number = definition.kind == .number || definition.kind == .money ? entry.number : nil
            target.date = definition.kind == .date ? entry.date : nil
        }

        if let code = code.flatMap(LabelLinker.normalized) {
            if code != item.code { LabelLinker.link(code, to: .item(item), in: context) }
        } else {
            item.code = nil
        }
        item.updatedAt = .now
        item.refreshSearchKey()
    }
}
