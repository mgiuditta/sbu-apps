import UIKit

extension ItemPhoto {
    /// Plain photos drawn on the spot, for previews only.
    static func previewSamples(_ count: Int = 3) -> [ItemPhoto] {
        let colors: [UIColor] = [.systemTeal, .systemOrange, .systemIndigo]
        return (0..<count).compactMap { index in
            let image = UIGraphicsImageRenderer(size: CGSize(width: 600, height: 400)).image { context in
                colors[index % colors.count].setFill()
                context.fill(CGRect(x: 0, y: 0, width: 600, height: 400))
            }
            guard let processed = PhotoProcessor.process(image) else { return nil }
            return ItemPhoto(data: processed.data, thumbnail: processed.thumbnail, order: index)
        }
    }
}
