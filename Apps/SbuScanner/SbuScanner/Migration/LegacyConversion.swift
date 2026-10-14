import Foundation

/// The 1.x values in the 2.0's terms.
nonisolated enum LegacyConversion {
    /// From bwip-js's name first, then expo-camera's; QR when neither is known, as the 1.x did.
    static func symbology(_ legacy: String?, codeType: String) -> Symbology {
        if let legacy, let match = bwip[legacy] { return match }
        return camera[codeType] ?? .qr
    }

    /// `toISOString()`, with or without milliseconds.
    static func date(_ text: String) -> Date? {
        (try? Date(text, strategy: Date.ISO8601FormatStyle(includingFractionalSeconds: true)))
            ?? (try? Date(text, strategy: Date.ISO8601FormatStyle()))
    }

    private static let camera: [String: Symbology] = [
        "aztec": .aztec, "codabar": .codabar, "code128": .code128, "code39": .code39, "code93": .code93,
        "datamatrix": .dataMatrix, "ean13": .ean13, "ean8": .ean8, "itf14": .itf14, "pdf417": .pdf417,
        "qr": .qr, "upc_a": .ean13, "upc_e": .upce,
    ]

    // UPC-A is EAN-13 with a leading zero; the 1.x creator's DataBar has no 2.0 name, so it reads as Code 128.
    private static let bwip: [String: Symbology] = [
        "qrcode": .qr, "microqrcode": .qr, "azteccode": .aztec, "datamatrix": .dataMatrix, "pdf417": .pdf417,
        "micropdf417": .pdf417, "ean13": .ean13, "upca": .ean13, "ean8": .ean8, "upce": .upce, "code128": .code128,
        "code39": .code39, "code93": .code93, "itf14": .itf14, "interleaved2of5": .itf14,
        "rationalizedCodabar": .codabar, "databaromni": .code128, "databarlimited": .code128, "databarexpanded": .code128,
    ]
}
