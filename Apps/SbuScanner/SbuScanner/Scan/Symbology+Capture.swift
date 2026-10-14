import AVFoundation
import Vision

nonisolated extension Symbology {
    /// The camera's name for this symbology.
    var metadataType: AVMetadataObject.ObjectType {
        switch self {
        case .qr: .qr
        case .aztec: .aztec
        case .dataMatrix: .dataMatrix
        case .pdf417: .pdf417
        case .ean13: .ean13
        case .ean8: .ean8
        case .upce: .upce
        case .code39: .code39
        case .code93: .code93
        case .code128: .code128
        case .itf14: .itf14
        case .codabar: .codabar
        }
    }

    /// Every camera type to ask for: Interleaved 2 of 5 too, which is how ITF-14 cartons often read.
    static var metadataTypes: [AVMetadataObject.ObjectType] {
        allCases.map(\.metadataType) + [.interleaved2of5]
    }

    init?(metadataType: AVMetadataObject.ObjectType) {
        if metadataType == .interleaved2of5 {
            self = .itf14
            return
        }
        guard let match = Self.allCases.first(where: { $0.metadataType == metadataType }) else { return nil }
        self = match
    }

    /// Vision's name for this symbology, for codes found in photos.
    var visionSymbology: VNBarcodeSymbology {
        switch self {
        case .qr: .qr
        case .aztec: .aztec
        case .dataMatrix: .dataMatrix
        case .pdf417: .pdf417
        case .ean13: .ean13
        case .ean8: .ean8
        case .upce: .upce
        case .code39: .code39
        case .code93: .code93
        case .code128: .code128
        case .itf14: .itf14
        case .codabar: .codabar
        }
    }

    /// Every Vision type to look for, Interleaved 2 of 5 included.
    static var visionSymbologies: [VNBarcodeSymbology] {
        allCases.map(\.visionSymbology) + [.i2of5, .i2of5Checksum]
    }

    init?(visionSymbology: VNBarcodeSymbology) {
        if visionSymbology == .i2of5 || visionSymbology == .i2of5Checksum {
            self = .itf14
            return
        }
        guard let match = Self.allCases.first(where: { $0.visionSymbology == visionSymbology }) else { return nil }
        self = match
    }
}
