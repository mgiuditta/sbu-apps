import SwiftUI

/// The dial's arc: 240°, open at the bottom like a car's speedometer, filled clockwise up to `fraction`.
///
/// It fits a 4:3 box, not a square: the open bottom of the circle is not drawn, so it leaves no empty
/// band under the dial. The box is `Self.aspectRatio`; the arc's ends touch its bottom edge.
struct DialArc: Shape {
    /// Width over height of the box that holds the whole arc.
    static let aspectRatio = 4.0 / 3.0

    private static let start = Angle.degrees(150)
    private static let sweep = 240.0

    /// How much of the arc to draw, 0...1.
    var fraction: Double = 1

    var animatableData: Double {
        get { fraction }
        set { fraction = newValue }
    }

    func path(in rect: CGRect) -> Path {
        // The ends sit at 30° below the centre: the arc's height is 1.5 radii.
        let radius = min(rect.width / 2, rect.height / 1.5)
        let center = CGPoint(x: rect.midX, y: rect.midY + radius * 0.25)
        let end = Self.start + .degrees(Self.sweep * min(1, max(0, fraction)))
        var path = Path()
        path.addArc(center: center, radius: radius, startAngle: Self.start, endAngle: end, clockwise: false)
        return path
    }
}
