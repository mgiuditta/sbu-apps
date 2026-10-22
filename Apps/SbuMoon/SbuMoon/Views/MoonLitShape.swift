import SwiftUI

/// The lit part of the moon, from `MoonDisc`, in the largest circle that fits the rect.
nonisolated struct MoonLitShape: Shape {
    let disc: MoonDisc

    func path(in rect: CGRect) -> Path {
        let radius = min(rect.width, rect.height) / 2
        let center = CGPoint(x: rect.midX, y: rect.midY)

        var path = Path()
        guard disc.illumination > 0 else { return path }
        path.addLines(disc.litOutline(center: center, radius: radius))
        path.closeSubpath()
        return path
    }
}
