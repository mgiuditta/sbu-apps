import Foundation
import SwiftData

/// "Prova con un esempio": one folder with a small house inside, so you see how folders, quantities and
/// "Da ricomprare" work before typing anything. Deleting the folder takes it all away.
enum InventorySample {
    @discardableResult
    static func insert(into context: ModelContext, wrapped: Bool = true) -> Folder? {
        let top = wrapped ? Folder(name: String(localized: "Esempio")) : nil
        if let top { context.insert(top) }

        let house = add(String(localized: "Casa"), in: top, context)
        let garage = add(String(localized: "Garage"), in: house, context)
        let box = add(String(localized: "Scatola 3"), in: garage, context)
        let kitchen = add(String(localized: "Cucina"), in: house, context)

        item(String(localized: "Trapano"), 1, in: box, price: "89", tags: [String(localized: "attrezzi")], context)
        item(String(localized: "Cacciaviti"), 6, in: box, price: "4.5", tags: [String(localized: "attrezzi")], context)
        item(String(localized: "Pile AA"), 2, in: garage, minimum: 4, price: "0.8", context)
        item(String(localized: "Bicicletta"), 1, in: garage, price: "420", context)
        item(String(localized: "Moka"), 1, in: kitchen, price: "32", context)
        item(String(localized: "Capsule di caffè"), 18, in: kitchen, minimum: 10, price: "0.35", context)
        item(String(localized: "Bicchieri"), 12, in: kitchen, context)
        try? context.save()
        return top
    }

    private static func add(_ name: String, in parent: Folder?, _ context: ModelContext) -> Folder {
        let folder = Folder(name: name, parent: parent)
        context.insert(folder)
        return folder
    }

    private static func item(_ name: String, _ quantity: Int, in folder: Folder, minimum: Int? = nil, price: String? = nil, tags: [String] = [], _ context: ModelContext) {
        let item = Item(name: name, quantity: quantity, folder: folder)
        context.insert(item)
        item.minimumQuantity = minimum
        item.unitPrice = price.flatMap { Decimal(string: $0, locale: Locale(identifier: "en_US_POSIX")) }
        item.tags = tags
        item.refreshSearchKey()
    }
}
