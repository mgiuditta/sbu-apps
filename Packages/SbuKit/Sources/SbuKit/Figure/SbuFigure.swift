import CoreText
import SwiftUI

/// The one figure of a screen, in `ink`, closed by the full stop.
///
/// Bricolage Grotesque ExtraBold with tabular figures. On the tool screen the size snaps to the grid
/// (216, 192, 168 or 144 by length) and the baseline falls on a grid line of `.sbuPaper`. The figure
/// never wraps: it narrows on the `wdth` axis (100, 87, 75) and only then scales down. VoiceOver reads
/// it as one element, figure and context together; the full stop is silent.
public struct SbuFigure: View {
    /// How big the figure is drawn.
    enum Scale: Hashable {
        /// The tool screen: snapped to the grid by length, closed by the hero full stop.
        case hero
        /// A fixed size, for widgets and Live Activities.
        case fixed(CGFloat, SbuFullStop.Size)
    }

    private let value: String
    private let unit: String?
    private let fullStop: SbuFullStop.State
    private let context: Text?
    private let label: Text?
    private let scale: Scale

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.sbuIsOnPaper) private var isOnPaper
    @State private var gridOffset: CGFloat = 0
    @State private var hasSnapped = false

    /// Creates the figure.
    /// - Parameters:
    ///   - value: The figure, already formatted for the locale (`12`, `47,90 €`, `0,0`).
    ///   - unit: A unit drawn right after the value in the same face, such as `°`; `nil` for none.
    ///   - fullStop: `.set` when the figure is final, `.waiting` while counting or empty.
    ///   - context: One line under the figure in `inkMuted`, such as "giorni di fila".
    ///   - accessibilityLabel: What VoiceOver reads instead of value, unit and context.
    public init(
        value: String,
        unit: String? = nil,
        fullStop: SbuFullStop.State = .set,
        context: Text? = nil,
        accessibilityLabel: Text? = nil
    ) {
        self.init(value: value, unit: unit, fullStop: fullStop, context: context, accessibilityLabel: accessibilityLabel, scale: .hero)
    }

    init(value: String, unit: String?, fullStop: SbuFullStop.State, context: Text?, accessibilityLabel: Text?, scale: Scale) {
        self.value = value
        self.unit = unit
        self.fullStop = fullStop
        self.context = context
        label = accessibilityLabel
        self.scale = scale
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space3) {
            figure
            if let context {
                context
                    .font(SbuTheme.body)
                    .foregroundStyle(SbuTheme.inkMuted)
                    // Never squeezed under its line height by a tight stack around the figure.
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
    }

    @ViewBuilder private var figure: some View {
        switch scale {
        case .hero:
            let size = Self.heroSize(for: text)
            line(size: size, fullStop: .hero)
                // The baseline sits on the bottom of a block whose top is on a grid line; the
                // descenders (the comma of "6,0") get whole cells under it.
                .frame(height: size, alignment: .bottom)
                .padding(.bottom, Self.descentInCells(size: size))
                .padding(.top, isOnPaper ? gridOffset : 0)
                .onGeometryChange(for: CGFloat.self) { proxy in
                    proxy.frame(in: .named(SbuPaper.space)).minY
                } action: { minY in
                    // Off paper (a List row, a sheet) there is no grid to meet: snapping there
                    // would only feed layout back into itself.
                    // Snap once, on the first layout: self-sizing containers (List rows) and scrolling
                    // move the block again after the offset changes, and following them never settles.
                    guard isOnPaper, !hasSnapped else { return }
                    hasSnapped = true
                    gridOffset = Self.offsetToGrid(minY)
                }
        case .fixed(let size, let stop):
            line(size: size, fullStop: stop)
        }
    }

    private func line(size: CGFloat, fullStop stopSize: SbuFullStop.Size) -> some View {
        ViewThatFits(in: .horizontal) {
            glyphs(size: size, width: SbuTheme.figureWidthMax, stop: stopSize)
            glyphs(size: size, width: SbuTheme.figureWidthMid, stop: stopSize)
            glyphs(size: size, width: SbuTheme.figureWidthMin, stop: stopSize)
            glyphs(size: size, width: SbuTheme.figureWidthMin, stop: stopSize)
                .minimumScaleFactor(Self.minimumScale)
        }
        .alignmentGuide(.bottom) { dimensions in dimensions[.lastTextBaseline] }
    }

    private func glyphs(size: CGFloat, width: CGFloat, stop: SbuFullStop.Size) -> some View {
        HStack(alignment: .lastTextBaseline, spacing: 0) {
            Text(verbatim: text)
                .font(.sbuFigure(size: size, width: width))
                .foregroundStyle(SbuTheme.ink)
                .lineLimit(1)
                .contentTransition(.numericText())
                .animation(SbuMotion.animation(SbuMotion.base, reduceMotion: reduceMotion), value: text)
            SbuFullStop(fullStop, size: stop)
        }
    }

    private var text: String {
        value + (unit ?? "")
    }

    private var accessibilityText: Text {
        if let label { return label }
        guard let context else { return Text(verbatim: text) }
        return Text(verbatim: text + ", ") + context
    }

    /// How far the last instance may shrink, so a very long figure still fits on one line.
    static let minimumScale: CGFloat = 0.4

    /// The hero size for a figure, in whole grid cells: shorter figures are bigger.
    static func heroSize(for text: String) -> CGFloat {
        let cells = SbuTheme.figureHeroMax / SbuTheme.gridCell - CGFloat(max(text.count - 2, 0))
        return max(cells * SbuTheme.gridCell, SbuTheme.figureHeroMin)
    }

    /// The room under the baseline for descenders, rounded up to whole grid cells.
    static func descentInCells(size: CGFloat) -> CGFloat {
        let descent = CTFontGetDescent(SbuFont.figure(size: size, width: SbuTheme.figureWidthMax))
        return (descent / SbuTheme.gridCell).rounded(.up) * SbuTheme.gridCell
    }

    /// The padding that moves a block starting at `minY` down to the next grid line.
    static func offsetToGrid(_ minY: CGFloat) -> CGFloat {
        let remainder = minY.truncatingRemainder(dividingBy: SbuTheme.gridCell)
        let offset = remainder > 0 ? SbuTheme.gridCell - remainder : -remainder
        // Under a pixel is rounding, not a gap.
        return offset < 0.5 || SbuTheme.gridCell - offset < 0.5 ? 0 : offset
    }
}

#Preview("Light") {
    SbuFigurePreview()
}

#Preview("Dark") {
    SbuFigurePreview()
        .preferredColorScheme(.dark)
}

#Preview("AX5") {
    SbuFigurePreview()
        .dynamicTypeSize(.accessibility5)
}

private struct SbuFigurePreview: View {
    @State private var days = 12

    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space6) {
            SbuFigure(value: days.formatted(), context: Text(verbatim: "giorni di fila"))
            SbuFigure(value: "47,90 €", fullStop: .waiting)
            SbuFigure(value: "0,0", unit: "°", fullStop: .absent)
            Stepper(value: $days) { Text(verbatim: "Giorni") }
        }
        .padding(.horizontal, SbuTheme.space4)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .sbuPaper()
        .environment(\.sbuAccent, .habits)
    }
}
