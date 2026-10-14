import SwiftUI

/// The codes the creator draws: QR for any content, and two barcodes for products and labels.
nonisolated enum CodeFormat: String, Codable, CaseIterable, Sendable {
    case qr
    case ean13
    case code128

    var symbology: Symbology {
        switch self {
        case .qr: .qr
        case .ean13: .ean13
        case .code128: .code128
        }
    }

    var title: LocalizedStringResource {
        switch self {
        case .qr: "Codice QR"
        case .ean13: "Codice a barre EAN-13"
        case .code128: "Codice a barre Code 128"
        }
    }
}
