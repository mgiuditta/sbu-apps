import SbuKit
import SwiftUI

/// The bubble level: a target ring in the middle and the bubble, offset by the reading. Decorative.
struct BubbleView: View {
    let bubbleX: Double
    let bubbleY: Double

    @ScaledMetric private var side: CGFloat = 48

    var body: some View {
        let inset = SbuTheme.space3
        ZStack {
            Circle()
                .stroke(SbuTheme.line, lineWidth: SbuTheme.hairline)
                .frame(width: side + SbuTheme.space2, height: side + SbuTheme.space2)

            Circle()
                .fill(SbuTheme.ink)
                .frame(width: side, height: side)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .visualEffect { [bubbleX, bubbleY, side, inset] content, proxy in
                    // Travel up to the dial's inner radius, inside the ticks, minus the bubble.
                    let travel = max(0, (min(proxy.size.width, proxy.size.height) - side) / 2 - inset)
                    return content.offset(x: bubbleX * travel, y: bubbleY * travel)
                }
        }
        .accessibilityHidden(true)
    }
}

#Preview("Light") {
    BubbleView(bubbleX: 0.4, bubbleY: -0.2)
        .frame(width: 300, height: 300)
        .background(SbuTheme.surface)
}

#Preview("Dark") {
    BubbleView(bubbleX: -0.6, bubbleY: 0.3)
        .frame(width: 300, height: 300)
        .background(SbuTheme.surface)
        .preferredColorScheme(.dark)
}
