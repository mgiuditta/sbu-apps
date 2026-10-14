import Foundation

/// The columns an import understands, each known by the names the 1.0, Sbu 2.0 and common spreadsheets give it.
nonisolated enum CSVColumn: String, CaseIterable, Sendable {
    case name, price, currency, cycle, date, category, trial, trialEnd, notes, status, reminder, list, paymentMethod, website

    var headers: [String] {
        switch self {
        case .name: ["nome", "name", "servizio", "service", "abbonamento", "subscription", "titolo", "title"]
        case .price: ["importo", "prezzo", "price", "amount", "costo", "cost"]
        case .currency: ["valuta", "currency"]
        case .cycle: ["ciclo_fatturazione", "ciclo", "cycle", "billing cycle", "billing period", "frequency", "frequenza", "period"]
        case .date: ["prossimo_rinnovo", "prossimo pagamento", "prossimo rinnovo", "next payment", "next payment date", "next billing date", "renewal date", "data", "date", "start date", "data di inizio"]
        case .category: ["categoria", "category"]
        case .trial: ["in_prova", "prova", "trial", "free trial"]
        case .trialEnd: ["fine_prova", "fine prova", "trial end", "trial ends"]
        case .notes: ["note", "notes"]
        case .status: ["stato", "status"]
        case .reminder: ["promemoria_giorni", "reminder days"]
        case .list: ["lista", "list"]
        case .paymentMethod: ["metodo_pagamento", "metodo di pagamento", "payment method"]
        case .website: ["sito", "url", "website"]
        }
    }

    /// Matches a header ignoring case, accents, spaces and underscores.
    static func match(_ header: String) -> CSVColumn? {
        let key = normalized(header)
        return allCases.first { $0.headers.map(normalized).contains(key) }
    }

    private static func normalized(_ text: String) -> String {
        text.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: Locale(identifier: "en_US_POSIX"))
            .replacingOccurrences(of: "_", with: " ")
            .split(whereSeparator: \.isWhitespace).joined(separator: " ")
    }
}
