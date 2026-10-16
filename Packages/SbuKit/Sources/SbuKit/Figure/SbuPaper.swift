import SwiftUI

/// The paper of a Sbu screen: `paper`, with the notebook grid on paper areas.
///
/// The grid is one cell (`gridCell`, 24) of `grid` lines, `gridLineWidth` thick, drawn in a
/// `Canvas`. A vertical line falls on the horizontal margin (`gridOffset`), and a horizontal line
/// on the top of the safe area, so content laid out in cells from there sits on the grid. Use the
/// grid only on paper areas (figure zone, empty states, first run): never under `List` or `Form`
/// rows, never under the person's photos, PDFs or previews.
public struct SbuPaper: View {
    /// The coordinate space `.sbuPaper` names on its view: y = 0 is a grid line.
    nonisolated static let space = "sbu.paper"

    private let grid: Bool

    /// Creates the paper.
    /// - Parameter grid: Whether to draw the grid.
    public init(grid: Bool = true) {
        self.grid = grid
    }

    public var body: some View {
        GeometryReader { proxy in
            let top = proxy.safeAreaInsets.top
            ZStack {
                SbuTheme.paper
                if grid {
                    Canvas { context, size in
                        context.fill(Self.lines(in: size, top: top), with: .color(SbuTheme.grid))
                    }
                }
            }
            .ignoresSafeArea()
        }
        .accessibilityHidden(true)
    }

    /// The grid lines covering `size`, a horizontal one at `top` and a vertical one at `gridOffset`.
    static func lines(in size: CGSize, top: CGFloat) -> Path {
        let cell = SbuTheme.gridCell
        let width = SbuTheme.gridLineWidth
        var path = Path()
        var x = SbuTheme.gridOffset.truncatingRemainder(dividingBy: cell)
        while x <= size.width {
            path.addRect(CGRect(x: x - width / 2, y: 0, width: width, height: size.height))
            x += cell
        }
        var y = top.truncatingRemainder(dividingBy: cell)
        while y <= size.height {
            path.addRect(CGRect(x: 0, y: y - width / 2, width: size.width, height: width))
            y += cell
        }
        return path
    }
}

public extension View {
    /// Puts the view on Sbu paper: `paper`, with the notebook grid when `grid` is `true`.
    func sbuPaper(grid: Bool = true) -> some View {
        background { SbuPaper(grid: grid) }
            .coordinateSpace(.named(SbuPaper.space))
    }
}

#Preview("Light") {
    Text(verbatim: "Carta")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sbuPaper()
}

#Preview("Dark") {
    Text(verbatim: "Carta")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sbuPaper()
        .preferredColorScheme(.dark)
}
