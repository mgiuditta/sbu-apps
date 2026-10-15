import Foundation

/// The fixed columns of the inventory file, each known by the names spreadsheets and other apps give it.
nonisolated enum InventoryColumn: String, CaseIterable, Sendable {
    case kind, id, name, quantity, minimum, path, price, currency, date, tags, code, notes, photos

    /// The name this app writes.
    var header: String { headers[0] }

    var headers: [String] {
        switch self {
        case .kind: ["tipo", "type", "kind"]
        case .id: ["id", "uuid"]
        case .name: ["nome", "name", "oggetto", "item", "item name", "titolo", "title"]
        case .quantity: ["quantita", "quantity", "qty", "qta"]
        case .minimum: ["quantita_minima", "minimo", "minimum", "minimum quantity", "min quantity", "min level"]
        case .path: ["percorso", "posizione", "cartella", "folder", "location", "path", "luogo"]
        case .price: ["prezzo_unitario", "prezzo", "price", "unit price", "valore", "value", "costo", "cost"]
        case .currency: ["valuta", "currency"]
        case .date: ["data_acquisto", "data d'acquisto", "purchase date", "data", "date"]
        case .tags: ["tag", "tags"]
        case .code: ["etichetta", "codice", "codice a barre", "barcode", "qr", "code"]
        case .notes: ["note", "notes", "descrizione", "description"]
        case .photos: ["foto", "photos", "immagini", "images"]
        }
    }

    /// Matches a header ignoring case, accents, spaces and underscores.
    static func match(_ header: String) -> InventoryColumn? {
        let key = normalized(header)
        return allCases.first { $0.headers.map(normalized).contains(key) }
    }

    private static func normalized(_ text: String) -> String {
        SearchKey.fold(text.replacingOccurrences(of: "_", with: " "))
    }
}
