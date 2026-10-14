/// The kind of code read or made: how the bars or squares are arranged, not what they say.
nonisolated enum Symbology: String, Codable, CaseIterable, Sendable {
    case qr
    case aztec
    case dataMatrix
    case pdf417
    case ean13
    case ean8
    case upce
    case code39
    case code93
    case code128
    case itf14
    case codabar

    /// The standard name, the same in every language.
    var name: String {
        switch self {
        case .qr: "QR"
        case .aztec: "Aztec"
        case .dataMatrix: "Data Matrix"
        case .pdf417: "PDF417"
        case .ean13: "EAN-13"
        case .ean8: "EAN-8"
        case .upce: "UPC-E"
        case .code39: "Code 39"
        case .code93: "Code 93"
        case .code128: "Code 128"
        case .itf14: "ITF-14"
        case .codabar: "Codabar"
        }
    }

    /// Codes printed on products in shops: their content is a number to look up, not a message.
    var isProduct: Bool {
        switch self {
        case .ean13, .ean8, .upce: true
        default: false
        }
    }

    /// Squares in two dimensions rather than a row of bars.
    var isTwoDimensional: Bool {
        switch self {
        case .qr, .aztec, .dataMatrix, .pdf417: true
        default: false
        }
    }
}
