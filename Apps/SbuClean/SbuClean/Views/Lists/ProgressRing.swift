import SbuKit
import SwiftUI

/// A small ring that fills in the accent, track and fill of the same width.
struct ProgressRing: View {
    let fraction: Double

    private static let lineWidth: CGFloat = 3

    var body: some View {
        ZStack {
            Circle()
                .stroke(SbuTheme.line, lineWidth: Self.lineWidth)
            Circle()
                .trim(from: 0, to: max(0, min(1, fraction)))
                .stroke(.tint, style: StrokeStyle(lineWidth: Self.lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
        .padding(Self.lineWidth / 2)
        .accessibilityHidden(true)
    }
}

#Preview("Light") {
    ProgressRing(fraction: 0.4)
        .frame(width: 44, height: 44)
        .tint(SbuTheme.accentClean)
}

#Preview("Dark") {
    ProgressRing(fraction: 0.8)
        .frame(width: 44, height: 44)
        .tint(SbuTheme.accentClean)
        .preferredColorScheme(.dark)
}
