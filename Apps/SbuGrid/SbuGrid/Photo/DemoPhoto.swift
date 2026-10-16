import UIKit

/// A still life drawn in code, for previews, UI tests and the App Store screenshots: a jug, a
/// pear and an apple on a table, lit from the left. No photo from the library is ever bundled.
///
/// The colors are the picture's own, like those of any photo: they are not interface colors.
nonisolated enum DemoPhoto {
    static let size = CGSize(width: 1200, height: 1600)

    static func stillLife(size: CGSize = size) -> CGImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = true
        let image = UIGraphicsImageRenderer(size: size, format: format).image { context in
            let cg = context.cgContext
            let width = size.width
            let height = size.height

            // Wall and table.
            UIColor(red: 0.86, green: 0.82, blue: 0.74, alpha: 1).setFill()
            cg.fill(CGRect(x: 0, y: 0, width: width, height: height * 0.62))
            UIColor(red: 0.55, green: 0.38, blue: 0.26, alpha: 1).setFill()
            cg.fill(CGRect(x: 0, y: height * 0.62, width: width, height: height * 0.38))

            // Shadows to the right of each object.
            UIColor(white: 0, alpha: 0.18).setFill()
            cg.fillEllipse(in: CGRect(x: width * 0.30, y: height * 0.68, width: width * 0.42, height: height * 0.05))
            cg.fillEllipse(in: CGRect(x: width * 0.62, y: height * 0.80, width: width * 0.30, height: height * 0.04))
            cg.fillEllipse(in: CGRect(x: width * 0.10, y: height * 0.84, width: width * 0.30, height: height * 0.04))

            // The jug.
            let jug = UIBezierPath()
            jug.move(to: CGPoint(x: width * 0.38, y: height * 0.22))
            jug.addLine(to: CGPoint(x: width * 0.58, y: height * 0.22))
            jug.addCurve(
                to: CGPoint(x: width * 0.62, y: height * 0.70),
                controlPoint1: CGPoint(x: width * 0.56, y: height * 0.36),
                controlPoint2: CGPoint(x: width * 0.74, y: height * 0.52)
            )
            jug.addLine(to: CGPoint(x: width * 0.34, y: height * 0.70))
            jug.addCurve(
                to: CGPoint(x: width * 0.38, y: height * 0.22),
                controlPoint1: CGPoint(x: width * 0.22, y: height * 0.52),
                controlPoint2: CGPoint(x: width * 0.40, y: height * 0.36)
            )
            jug.close()
            UIColor(red: 0.27, green: 0.42, blue: 0.56, alpha: 1).setFill()
            jug.fill()
            let handle = UIBezierPath(ovalIn: CGRect(x: width * 0.58, y: height * 0.32, width: width * 0.14, height: height * 0.16))
            handle.lineWidth = width * 0.025
            UIColor(red: 0.22, green: 0.35, blue: 0.47, alpha: 1).setStroke()
            handle.stroke()
            UIColor(white: 1, alpha: 0.35).setFill()
            UIBezierPath(ovalIn: CGRect(x: width * 0.39, y: height * 0.40, width: width * 0.05, height: height * 0.16)).fill()

            // The pear.
            let pear = UIBezierPath()
            pear.move(to: CGPoint(x: width * 0.76, y: height * 0.62))
            pear.addCurve(
                to: CGPoint(x: width * 0.76, y: height * 0.84),
                controlPoint1: CGPoint(x: width * 0.66, y: height * 0.70),
                controlPoint2: CGPoint(x: width * 0.60, y: height * 0.84)
            )
            pear.addCurve(
                to: CGPoint(x: width * 0.76, y: height * 0.62),
                controlPoint1: CGPoint(x: width * 0.92, y: height * 0.84),
                controlPoint2: CGPoint(x: width * 0.86, y: height * 0.70)
            )
            UIColor(red: 0.74, green: 0.70, blue: 0.24, alpha: 1).setFill()
            pear.fill()

            // The apple.
            UIColor(red: 0.70, green: 0.18, blue: 0.14, alpha: 1).setFill()
            cg.fillEllipse(in: CGRect(x: width * 0.12, y: height * 0.74, width: width * 0.22, height: height * 0.12))
            UIColor(white: 1, alpha: 0.3).setFill()
            cg.fillEllipse(in: CGRect(x: width * 0.16, y: height * 0.76, width: width * 0.05, height: height * 0.03))
        }
        // ponytail: a UIGraphicsImageRenderer image is always backed by a CGImage.
        return image.cgImage!
    }
}
