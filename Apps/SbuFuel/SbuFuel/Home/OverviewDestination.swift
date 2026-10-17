import SwiftUI

/// The parts of the log the tool screen opens, in this order.
enum OverviewDestination: String, CaseIterable, Identifiable {
    case history
    case costs
    case services

    /// Also the row's accessibility identifier.
    var id: String { rawValue }

    var title: LocalizedStringKey {
        switch self {
        case .history: "Storico"
        case .costs: "Spese e grafici"
        case .services: "Manutenzione"
        }
    }

    var systemImage: String {
        switch self {
        case .history: "list.bullet.rectangle"
        case .costs: "chart.bar"
        case .services: "wrench.and.screwdriver"
        }
    }
}
