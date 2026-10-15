import Foundation

/// What a CSV column can hold, and the headers it is recognised by: this app's own, plus the
/// usual English and Italian names other services export.
nonisolated enum ImportField: String, CaseIterable, Identifiable, Sendable {
    case type
    case date
    case odometer
    case quantity
    case totalPrice
    case unitPrice
    case full
    case partial
    case missed
    case station
    case service
    case note

    var id: Self { self }

    var name: LocalizedStringResource {
        switch self {
        case .type: "Tipo di voce"
        case .date: "Data"
        case .odometer: "Contachilometri"
        case .quantity: "Quantità"
        case .totalPrice: "Importo totale"
        case .unitPrice: "Prezzo per unità"
        case .full: "Pieno"
        case .partial: "Parziale"
        case .missed: "Rifornimento saltato"
        case .station: "Distributore"
        case .service: "Intervento"
        case .note: "Note"
        }
    }

    /// Headers that mean this field, lowercased, without spaces or underscores.
    var headers: [String] {
        switch self {
        case .type: ["tipo", "type", "entrytype", "recordtype"]
        case .date: ["data", "date", "fuelupdate", "datetime", "day", "giorno"]
        case .odometer: ["contachilometri", "odometer", "odometro", "odo", "km", "mileage", "chilometraggio"]
        case .quantity: ["litri", "litres", "liters", "gallons", "usgallons", "ukgallons", "imperialgallons", "galloni", "quantity", "quantita", "quantità", "volume", "fuel", "carburante"]
        case .totalPrice: ["importo", "totale", "total", "totalprice", "prezzototale", "cost", "costo", "amount", "spesa"]
        case .unitPrice: ["price", "unitprice", "priceperunit", "pricepergallon", "priceperliter", "priceperlitre", "prezzo", "prezzounitario", "prezzoallitro"]
        case .full: ["pieno", "full", "fulltank", "isfull"]
        case .partial: ["partial", "partialfuelup", "parziale"]
        case .missed: ["saltato", "missed", "missedfuelup", "missedprevious", "rifornimentosaltato"]
        case .station: ["distributore", "station", "brand", "location", "stazione"]
        case .service: ["intervento", "service", "servizio", "manutenzione", "title", "titolo"]
        case .note: ["note", "notes", "nota", "comment", "commento"]
        }
    }

    static func normalised(_ header: String) -> String {
        header.lowercased().filter { !$0.isWhitespace && $0 != "_" && $0 != "-" && $0 != "." }
    }

    /// The units the headers name, if any: "gallons" or "miles" in a column the mapping uses.
    static func units(_ header: [String], mapping: [ImportField: Int]) -> (distance: DistanceUnit?, volume: VolumeUnit?) {
        func name(_ field: ImportField) -> String {
            guard let index = mapping[field], header.indices.contains(index) else { return "" }
            return normalised(header[index])
        }
        let quantity = name(.quantity), odometer = name(.odometer)
        let volume: VolumeUnit? = quantity.contains("gal") ? (quantity.contains("uk") || quantity.contains("imp") ? .imperialGallons : .usGallons)
            : quantity.contains("lit") ? .litres : nil
        let distance: DistanceUnit? = odometer.contains("mi") && !odometer.contains("km") ? .miles : odometer.contains("km") ? .kilometres : nil
        return (distance, volume)
    }

    /// Picks a column for each field from the header line; each column goes to one field at most.
    static func guess(_ header: [String]) -> [ImportField: Int] {
        let names = header.map(normalised)
        var mapping: [ImportField: Int] = [:]
        var taken: Set<Int> = []
        for field in allCases {
            for candidate in field.headers {
                if let index = names.firstIndex(of: candidate), !taken.contains(index) {
                    mapping[field] = index
                    taken.insert(index)
                    break
                }
            }
        }
        return mapping
    }
}
