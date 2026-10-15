import SwiftUI

/// What a custom field holds.
nonisolated enum FieldKind: String, CaseIterable, Codable, Sendable {
    case text, number, date, money

    var title: LocalizedStringResource {
        switch self {
        case .text: "Testo"
        case .number: "Numero"
        case .date: "Data"
        case .money: "Importo"
        }
    }
}
