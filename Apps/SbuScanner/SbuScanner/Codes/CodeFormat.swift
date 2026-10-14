import SwiftUI

/// The codes the creator draws: 2D codes for any content, barcodes for products and labels.
nonisolated enum CodeFormat: String, Codable, CaseIterable, Sendable {
    case qr
    case aztec
    case pdf417
    case ean13
    case ean8
    case upca
    case upce
    case code128
    case code39
    case itf14
    case codabar

    /// The symbology a scanner reports; UPC-A reads as an EAN-13 that starts with 0.
    var symbology: Symbology {
        switch self {
        case .qr: .qr
        case .aztec: .aztec
        case .pdf417: .pdf417
        case .ean13, .upca: .ean13
        case .ean8: .ean8
        case .upce: .upce
        case .code128: .code128
        case .code39: .code39
        case .itf14: .itf14
        case .codabar: .codabar
        }
    }

    var title: LocalizedStringResource {
        switch self {
        case .qr: "Codice QR"
        case .aztec: "Codice Aztec"
        case .pdf417: "Codice PDF417"
        case .ean13: "Codice a barre EAN-13"
        case .ean8: "Codice a barre EAN-8"
        case .upca: "Codice a barre UPC-A"
        case .upce: "Codice a barre UPC-E"
        case .code128: "Codice a barre Code 128"
        case .code39: "Codice a barre Code 39"
        case .itf14: "Codice a barre ITF-14"
        case .codabar: "Codice a barre Codabar"
        }
    }

    /// What the code will hold: check digits added and verified, Code 39 in capitals; `nil` when the
    /// format can't hold the text.
    func normalized(_ text: String) -> String? {
        guard !text.isEmpty else { return nil }
        switch self {
        case .qr, .aztec, .pdf417: return text
        case .ean13: return EAN13.normalized(text)
        case .ean8: return EAN8.normalized(text)
        case .upca: return UPCA.normalized(text)
        case .upce: return UPCE.normalized(text)
        case .code128: return text.allSatisfy(\.isASCII) ? text : nil
        case .code39: return Code39.normalized(text)
        case .itf14: return ITF14.normalized(text)
        case .codabar: return Codabar.normalized(text)
        }
    }

    /// The hint under the number field for the barcodes with a fixed length.
    var lengthHint: LocalizedStringResource? {
        switch self {
        case .ean13: "EAN-13: 12 cifre, l'ultima la calcola Sbu Scanner, o 13 con quella giusta."
        case .ean8: "EAN-8: 7 cifre, l'ultima la calcola Sbu Scanner, o 8 con quella giusta."
        case .upca: "UPC-A: 11 cifre, l'ultima la calcola Sbu Scanner, o 12 con quella giusta."
        case .upce: "UPC-E: 6 cifre, o 7 con il sistema 0 o 1 davanti, o 8 con la cifra di controllo."
        case .itf14: "ITF-14: 13 cifre, l'ultima la calcola Sbu Scanner, o 14 con quella giusta."
        case .code39: "Code 39: lettere maiuscole, cifre, spazio e - . $ / + %."
        case .codabar: "Codabar: cifre e - $ : / . +"
        default: nil
        }
    }
}
