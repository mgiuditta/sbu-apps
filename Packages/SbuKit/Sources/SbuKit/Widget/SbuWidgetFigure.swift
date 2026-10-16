import SwiftUI
import WidgetKit

/// The one widget layout of Sbu: the figure (64), its full stop and a label, on paper with the grid.
///
/// Waiting while there is nothing to count or the process runs, set at the end; one `.set` full stop
/// per widget. On the Lock Screen the full stop is `.widgetAccentable()`; inline it is `■`.
public struct SbuWidgetFigure: View {
    private let value: String
    private let unit: String?
    private let label: Text
    private let fullStop: SbuFullStop.State
    private let accent: SbuAccent

    @Environment(\.widgetFamily) private var family

    /// Creates the widget figure.
    /// - Parameters:
    ///   - value: The figure, formatted for the locale.
    ///   - unit: A unit right after the value, such as `°`.
    ///   - label: What the figure counts, such as "giorni di fila".
    ///   - fullStop: `.set` when final, `.waiting` while counting or empty.
    ///   - accent: The app's accent, for the `.set` full stop.
    public init(value: String, unit: String? = nil, label: Text, fullStop: SbuFullStop.State = .set, accent: SbuAccent) {
        self.value = value
        self.unit = unit
        self.label = label
        self.fullStop = fullStop
        self.accent = accent
    }

    public var body: some View {
        content
            .environment(\.sbuAccent, accent)
            .containerBackground(for: .widget) {
                SbuPaper(grid: true)
            }
    }

    @ViewBuilder private var content: some View {
        switch family {
        case .accessoryInline:
            Text(verbatim: value + (unit ?? "") + (fullStop == .absent ? " " : " \u{25A0} ")) + label
        case .accessoryCircular, .accessoryRectangular, .accessoryCorner:
            VStack(alignment: .leading, spacing: 0) {
                SbuFigure(value: value, unit: unit, fullStop: fullStop, context: nil, accessibilityLabel: accessibility, scale: .fixed(SbuTheme.figureLive, .mark))
                label
                    .font(SbuTheme.caption)
                    .lineLimit(1)
            }
        default:
            VStack(alignment: .leading, spacing: SbuTheme.space1) {
                Spacer(minLength: 0)
                SbuFigure(value: value, unit: unit, fullStop: fullStop, context: nil, accessibilityLabel: accessibility, scale: .fixed(SbuTheme.figureWidget, .inline))
                label
                    .font(SbuTheme.subheadline)
                    .foregroundStyle(SbuTheme.inkMuted)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        }
    }

    private var accessibility: Text {
        Text(verbatim: value + (unit ?? "") + ", ") + label
    }
}

#Preview("Light") {
    SbuWidgetFigure(value: "12", label: Text(verbatim: "giorni di fila"), accent: .habits)
        .frame(width: 170, height: 170)
        .sbuPaper()
}

#Preview("Dark") {
    SbuWidgetFigure(value: "0", label: Text(verbatim: "giorni di fila"), fullStop: .waiting, accent: .habits)
        .frame(width: 170, height: 170)
        .sbuPaper()
        .preferredColorScheme(.dark)
}
