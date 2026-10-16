import Foundation

/// Which way the sheet stands.
nonisolated enum PaperOrientation: String, Codable, CaseIterable, Identifiable, Sendable {
    case portrait
    case landscape

    var id: Self { self }

    var title: LocalizedStringResource {
        switch self {
        case .portrait: "Verticale"
        case .landscape: "Orizzontale"
        }
    }
}
