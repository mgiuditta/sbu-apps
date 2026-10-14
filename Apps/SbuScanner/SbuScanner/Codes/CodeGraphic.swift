import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit

/// A code as a grid of modules (true = dark), ready to draw as PNG or SVG at any size.
///
/// A barcode is a single row; it is drawn tall. The quiet zone around it is part of the drawing,
/// so a scanner finds the edges.
nonisolated struct CodeGraphic: Equatable, Sendable {
    let rows: [[Bool]]

    var isBarcode: Bool { rows.count == 1 }
    var columns: Int { rows.first?.count ?? 0 }
    /// Modules of white on each side: four for 2D codes, ten for barcodes, as the standards ask.
    var quietZone: Int { isBarcode ? 10 : 4 }

    init(rows: [[Bool]]) {
        self.rows = rows
    }

    /// Draws `text` in `format`; `nil` when the format can't hold it (an EAN-13 with letters, an empty text).
    init?(_ text: String, format: CodeFormat) {
        guard let code = format.normalized(text) else { return nil }
        switch format {
        case .qr:
            let filter = CIFilter.qrCodeGenerator()
            filter.message = Data(code.utf8)
            filter.correctionLevel = "M"
            guard let image = filter.outputImage, let matrix = Self.matrix(of: image) else { return nil }
            rows = matrix
        case .aztec:
            let filter = CIFilter.aztecCodeGenerator()
            filter.message = Data(code.utf8)
            guard let image = filter.outputImage, let matrix = Self.matrix(of: image) else { return nil }
            rows = matrix
        case .pdf417:
            let filter = CIFilter.pdf417BarcodeGenerator()
            filter.message = Data(code.utf8)
            guard let image = filter.outputImage, let matrix = Self.matrix(of: image) else { return nil }
            rows = matrix
        case .code128:
            guard let data = code.data(using: .ascii) else { return nil }
            let filter = CIFilter.code128BarcodeGenerator()
            filter.message = data
            filter.quietSpace = 0
            filter.barcodeHeight = 1
            guard let image = filter.outputImage, let matrix = Self.matrix(of: image), let row = matrix.first else { return nil }
            rows = [row]
        case .ean13: rows = [EAN13.modules(code)]
        case .ean8: rows = [EAN8.modules(code)]
        case .upca: rows = [UPCA.modules(code)]
        case .upce: rows = [UPCE.modules(code)]
        case .code39: rows = [Code39.modules(code)]
        case .itf14: rows = [ITF14.modules(code)]
        case .codabar: rows = [Codabar.modules(code)]
        }
        guard columns > 0 else { return nil }
    }

    /// Height of the drawing in modules: square for 2D codes; for barcodes, bars a third of the width
    /// tall but never shorter than the quiet zone, plus half a quiet zone above and below.
    var heightInModules: Int {
        isBarcode ? quietZone + max(widthInModules / 3 - quietZone, quietZone) : rows.count + 2 * quietZone
    }

    var widthInModules: Int { columns + 2 * quietZone }

    /// Black on white, whatever the theme: a scanner needs the contrast, and an inverted code fails in many readers.
    func image(moduleSize: CGFloat) -> UIImage {
        let size = CGSize(width: CGFloat(widthInModules) * moduleSize, height: CGFloat(heightInModules) * moduleSize)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = true
        return UIGraphicsImageRenderer(size: size, format: format).image { context in
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            UIColor.black.setFill()
            for rect in darkRects() {
                context.fill(CGRect(x: rect.x * moduleSize, y: rect.y * moduleSize, width: rect.width * moduleSize, height: rect.height * moduleSize))
            }
        }
    }

    /// The same drawing as an SVG document, one rectangle per run of dark modules.
    var svg: String {
        let rects = darkRects().map { #"<rect x="\#(Int($0.x))" y="\#(Int($0.y))" width="\#(Int($0.width))" height="\#(Int($0.height))"/>"# }
        return """
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 \(widthInModules) \(heightInModules)" shape-rendering="crispEdges">
        <rect width="100%" height="100%" fill="#fff"/>
        <g fill="#000">\(rects.joined())</g>
        </svg>
        """
    }

    /// Runs of dark modules in module units, quiet zone included.
    private func darkRects() -> [(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat)] {
        // Barcodes: half a quiet zone above and below the bars, which take the rest of the height.
        let barTop = quietZone / 2
        let barHeight = heightInModules - quietZone
        var rects: [(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat)] = []
        for (y, row) in rows.enumerated() {
            var x = 0
            while x < row.count {
                guard row[x] else {
                    x += 1
                    continue
                }
                let start = x
                while x < row.count, row[x] { x += 1 }
                let top = isBarcode ? barTop : quietZone + y
                rects.append((CGFloat(quietZone + start), CGFloat(top), CGFloat(x - start), CGFloat(isBarcode ? barHeight : 1)))
            }
        }
        return rects
    }

    /// Reads a generator's output, one pixel per module, cropped to the dark modules.
    private static func matrix(of image: CIImage) -> [[Bool]]? {
        let context = CIContext(options: [.useSoftwareRenderer: false])
        guard let cgImage = context.createCGImage(image, from: image.extent) else { return nil }
        let width = cgImage.width
        let height = cgImage.height
        var pixels = [UInt8](repeating: 255, count: width * height)
        let drawn = pixels.withUnsafeMutableBytes { buffer -> Bool in
            guard let bitmap = CGContext(
                data: buffer.baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width,
                space: CGColorSpaceCreateDeviceGray(), bitmapInfo: CGImageAlphaInfo.none.rawValue
            ) else { return false }
            bitmap.interpolationQuality = .none
            bitmap.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
            return true
        }
        guard drawn else { return nil }
        let grid = (0..<height).map { y in (0..<width).map { x in pixels[y * width + x] < 128 } }
        // The generators add their own margin: keep only the rows and columns with ink.
        guard let top = grid.firstIndex(where: { $0.contains(true) }),
              let bottom = grid.lastIndex(where: { $0.contains(true) }),
              let left = (0..<width).first(where: { x in grid.contains { $0[x] } }),
              let right = (0..<width).last(where: { x in grid.contains { $0[x] } })
        else { return nil }
        return grid[top...bottom].map { Array($0[left...right]) }
    }
}
