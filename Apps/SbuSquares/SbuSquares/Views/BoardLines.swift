import SbuKit
import SwiftUI

/// The inner lines of the board, one hairline between cells.
struct BoardLines: View {
    var body: some View {
        Canvas { context, size in
            let cell = size.width / CGFloat(Board.size)
            var path = Path()
            for index in 1..<Board.size {
                let offset = CGFloat(index) * cell
                path.move(to: CGPoint(x: offset, y: 0))
                path.addLine(to: CGPoint(x: offset, y: size.height))
                path.move(to: CGPoint(x: 0, y: offset))
                path.addLine(to: CGPoint(x: size.width, y: offset))
            }
            context.stroke(path, with: .color(SbuTheme.line), lineWidth: SbuTheme.hairline)
        }
        .accessibilityHidden(true)
    }
}

#Preview("Light") {
    BoardLines().frame(width: 320, height: 320)
}

#Preview("Dark") {
    BoardLines().frame(width: 320, height: 320).preferredColorScheme(.dark)
}
