import CoreImage
import Foundation
import Testing
@testable import SbuScanner

struct CodeGraphicTests {
    /// Draws the code, then reads it back with Vision as a photo would be read: what is made scans.
    /// The simulator's Vision can't read barcodes ("Could not create inference context"), so this runs on a device.
    @Test(.enabled(if: !Self.isSimulator, "Vision reads no barcodes in the simulator"), arguments: [
        ("https://sbu.dev/apps/scanner", CodeFormat.qr, Symbology.qr),
        ("WIFI:T:WPA;S:Casa Rossi;P:girasole-42;;", .qr, .qr),
        ("Città, caffè e però", .qr, .qr),
        ("4006381333931", .ean13, .ean13),
        ("SBU-2026-0042", .code128, .code128),
    ])
    func whatIsDrawnReadsBack(text: String, format: CodeFormat, symbology: Symbology) async throws {
        let graphic = try #require(CodeGraphic(text, format: format))
        let png = try #require(graphic.image(moduleSize: 6).pngData())
        let readings = try await PhotoCodeReader.codes(in: png)
        #expect(readings == [CodeReading(raw: text, symbology: symbology)])
    }

    /// The same check for QR codes with Core Image's detector, which works in the simulator too.
    @Test(arguments: ["https://sbu.dev/apps/scanner", "WIFI:T:WPA;S:Casa Rossi;P:girasole-42;;", "Città, caffè e però"])
    func qrReadsBackWithCoreImage(text: String) throws {
        let graphic = try #require(CodeGraphic(text, format: .qr))
        let image = try #require(CIImage(image: graphic.image(moduleSize: 6)))
        let detector = try #require(CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]))
        let messages = detector.features(in: image).compactMap { ($0 as? CIQRCodeFeature)?.messageString }
        #expect(messages == [text])
    }

    nonisolated private static var isSimulator: Bool {
        #if targetEnvironment(simulator)
        true
        #else
        false
        #endif
    }

    @Test func qrIsSquareWithAQuietZone() throws {
        let graphic = try #require(CodeGraphic("ciao", format: .qr))
        #expect(graphic.rows.count == graphic.columns)
        // Version 1 is 21 modules a side.
        #expect(graphic.columns == 21)
        #expect(graphic.widthInModules == 29)
        #expect(!graphic.isBarcode)
    }

    @Test func ean13IsOneRowOf95() throws {
        let graphic = try #require(CodeGraphic("400638133393", format: .ean13))
        #expect(graphic.rows == [EAN13.modules("4006381333931")])
        #expect(graphic.isBarcode)
    }

    @Test(arguments: [("abc", CodeFormat.ean13), ("", .qr), ("caffè", .code128)])
    func refusesWhatTheFormatCannotHold(text: String, format: CodeFormat) {
        #expect(CodeGraphic(text, format: format) == nil)
    }

    @Test func svgHasOneRectPerRunAndTheRightViewBox() {
        let graphic = CodeGraphic(rows: [[true, true, false, true]])
        #expect(graphic.svg.contains(#"viewBox="0 0 24 20""#))
        #expect(graphic.svg.contains(#"<rect x="10" y="5" width="2" height="10"/>"#))
        #expect(graphic.svg.contains(#"<rect x="13" y="5" width="1" height="10"/>"#))
        #expect(graphic.svg.components(separatedBy: "<rect x=").count - 1 == 2)
    }
}
