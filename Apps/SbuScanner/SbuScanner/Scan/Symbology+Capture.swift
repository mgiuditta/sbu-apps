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

    init?(metadataType: AVMetadataObject.ObjectType) {
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

    init?(visionSymbology: VNBarcodeSymbology) {
        guard let match = Self.allCases.first(where: { $0.visionSymbology == visionSymbology }) else { return nil }
        self = match
    }
}
