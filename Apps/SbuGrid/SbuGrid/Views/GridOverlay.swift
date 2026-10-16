import SbuKit
import SwiftUI

/// The grid drawn over the photo: the frame, the lines, the diagonals and the numbers.
///
/// Everything grows with the picture (`GridLayout.scale`), so the overlay on screen, the image
/// export and the PDF look the same at any size. The colors are `ink` and `surface` in their
/// light values, whatever the iPhone's appearance: a dark line stays dark on the photo.
struct GridOverlay: View {
    let rule: CellRule
    let settings: GridSettings

    var body: some View {
        Canvas { context, size in
            let layout = GridLayout(size: size, rule: rule)
            guard layout.isEmpty == false else { return }
            context.clip(to: Path(CGRect(origin: .zero, size: size)))
            let stroke = layout.strokeWidth(for: settings.lineWidth)
            let color = Self.color(for: settings.lineTone).opacity(settings.opacity)

            if settings.showsDiagonals {
                context.stroke(Self.diagonals(of: layout), with: .color(color), lineWidth: stroke / 2)
            }
            context.stroke(Self.lines(of: layout, stroke: stroke), with: .color(color), lineWidth: stroke)
            if settings.showsNumbers {
                Self.drawNumbers(of: layout, tone: settings.lineTone, in: &context)
            }
        }
        .environment(\.colorScheme, .light)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    static func color(for tone: LineTone) -> Color {
        switch tone {
        case .dark: SbuTheme.ink
        case .light: SbuTheme.surface
        }
    }

    private static func lines(of layout: GridLayout, stroke: CGFloat) -> Path {
        var path = Path()
        for x in layout.verticalLines {
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: layout.size.height))
        }
        for y in layout.horizontalLines {
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: layout.size.width, y: y))
        }
        // The frame inside the picture, so the edge lines are as thick as the others.
        path.addRect(CGRect(origin: .zero, size: layout.size).insetBy(dx: stroke / 2, dy: stroke / 2))
        return path
    }

    private static func diagonals(of layout: GridLayout) -> Path {
        var path = Path()
        for segment in layout.diagonals {
            path.move(to: segment.start)
            path.addLine(to: segment.end)
        }
        return path
    }

    /// Column numbers along the top edge, row numbers along the left one, each on a small plate
    /// of the opposite tone so it reads on any photo.
    private static func drawNumbers(of layout: GridLayout, tone: LineTone, in context: inout GraphicsContext) {
        // Part of the picture, like the lines: sized to the cell rather than by Dynamic Type,
        // so the numbers fit their cell and the export matches the screen.
        let font = Font.system(size: layout.numberSize, weight: .semibold).monospacedDigit()
        let padding = layout.numberSize / 3
        let radius = SbuTheme.radiusSm * layout.scale
        let ink = color(for: tone)
        let plate = color(for: tone.opposite).opacity(0.7)

        func draw(_ number: Int, at center: (CGSize) -> CGPoint) {
            let text = context.resolve(Text(number, format: .number).font(font).foregroundStyle(ink))
            let measured = text.measure(in: layout.size)
            let plateSize = CGSize(width: measured.width + padding * 2, height: measured.height + padding / 2)
            let point = center(plateSize)
            let rect = CGRect(x: point.x - plateSize.width / 2, y: point.y - plateSize.height / 2, width: plateSize.width, height: plateSize.height)
            context.fill(Path(roundedRect: rect, cornerRadius: radius), with: .color(plate))
            context.draw(text, at: point)
        }

        for (index, x) in layout.columnCenters.enumerated() {
            draw(index + 1) { plate in CGPoint(x: x, y: padding + plate.height / 2) }
        }
        for (index, y) in layout.rowCenters.enumerated() {
            draw(index + 1) { plate in CGPoint(x: padding + plate.width / 2, y: y) }
        }
    }
}

#Preview("Light") {
    GridOverlayPreview()
}

#Preview("Dark") {
    GridOverlayPreview()
        .preferredColorScheme(.dark)
}

private struct GridOverlayPreview: View {
    var body: some View {
        var settings = GridSettings()
        settings.showsDiagonals = true
        settings.showsNumbers = true
        return GridPicture(image: DemoPhoto.stillLife(), settings: settings, rule: settings.cellRule)
            .padding(SbuTheme.space4)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(SbuTheme.surface)
    }
}
