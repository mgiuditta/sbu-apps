import SbuKit
import SwiftUI

/// A hairline between cells, and an ink line around each 3×3 box.
struct BoardLines: View {
    var body: some View {
        Canvas { context, size in
            let cell = size.width / CGFloat(Units.size)
            var thin = Path(), thick = Path()
            for index in 0...Units.size {
                let offset = CGFloat(index) * cell
                var path = Path()
                path.move(to: CGPoint(x: offset, y: 0))
                path.addLine(to: CGPoint(x: offset, y: size.height))
                path.move(to: CGPoint(x: 0, y: offset))
                path.addLine(to: CGPoint(x: size.width, y: offset))
                if index.isMultiple(of: Units.box) { thick.addPath(path) } else { thin.addPath(path) }
            }
            context.stroke(thin, with: .color(SbuTheme.line), lineWidth: SbuTheme.hairline)
            context.stroke(thick, with: .color(SbuTheme.ink), lineWidth: SbuTheme.checkboxStroke)
        }
        .accessibilityHidden(true)
        .allowsHitTesting(false)
    }
}

#Preview("Light") {
    BoardLines().frame(width: 320, height: 320).padding()
}

#Preview("Dark") {
    BoardLines().frame(width: 320, height: 320).padding().preferredColorScheme(.dark)
}
