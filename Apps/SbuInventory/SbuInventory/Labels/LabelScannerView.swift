import SwiftUI
import VisionKit

/// The live camera reading barcodes and QR codes: hands back the first one it sees, once.
///
/// Only a label to find an item: the content of the code is never shown or opened.
struct LabelScannerView: UIViewControllerRepresentable {
    let found: (String) -> Void

    /// Whether this iPhone can read codes with the camera (A12 or later, not the simulator).
    static var isSupported: Bool {
        DataScannerViewController.isSupported
    }

    /// Whether it can right now: camera allowed and not restricted.
    static var isAvailable: Bool {
        DataScannerViewController.isAvailable
    }

    func makeUIViewController(context: Context) -> DataScannerViewController {
        let scanner = DataScannerViewController(
            recognizedDataTypes: [.barcode()],
            qualityLevel: .balanced,
            recognizesMultipleItems: false,
            isHighFrameRateTrackingEnabled: false,
            isGuidanceEnabled: true,
            isHighlightingEnabled: true
        )
        scanner.delegate = context.coordinator
        try? scanner.startScanning()
        return scanner
    }

    func updateUIViewController(_ scanner: DataScannerViewController, context: Context) {}

    static func dismantleUIViewController(_ scanner: DataScannerViewController, coordinator: Coordinator) {
        scanner.stopScanning()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(found: found)
    }

    final class Coordinator: NSObject, DataScannerViewControllerDelegate {
        private let found: (String) -> Void
        private var hasFound = false

        init(found: @escaping (String) -> Void) {
            self.found = found
        }

        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            for item in addedItems {
                guard !hasFound, case let .barcode(barcode) = item, let payload = barcode.payloadStringValue,
                      let code = LabelLinker.normalized(payload) else { continue }
                hasFound = true
                dataScanner.stopScanning()
                found(code)
            }
        }
    }
}
