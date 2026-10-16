import SwiftUI
import WidgetKit

/// The Live Activity layout: a label and the figure (40) with its `mark` full stop, on paper.
///
/// The full stop waits while the process runs and is `.set` at the end: the app then ends the
/// activity after `liveEndDelay` (4 s). The full stop is `.widgetAccentable()` on the Lock Screen.
public struct SbuLiveFigure: View {
    private let value: String
    private let unit: String?
    private let label: Text
    private let fullStop: SbuFullStop.State
    private let accent: SbuAccent

    /// Creates the Live Activity figure.
    /// - Parameters:
    ///   - value: The figure, formatted for the locale.
    ///   - unit: A unit right after the value.
    ///   - label: What is running, such as "Lettura".
    ///   - fullStop: `.waiting` while running, `.set` at the end.
    ///   - accent: The app's accent, for the `.set` full stop.
    public init(value: String, unit: String? = nil, label: Text, fullStop: SbuFullStop.State = .waiting, accent: SbuAccent) {
        self.value = value
        self.unit = unit
        self.label = label
        self.fullStop = fullStop
        self.accent = accent
    }

    public var body: some View {
        HStack(alignment: .lastTextBaseline, spacing: SbuTheme.space3) {
            label
                .font(SbuTheme.headline)
                .foregroundStyle(SbuTheme.ink)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
            SbuFigure(value: value, unit: unit, fullStop: fullStop, context: nil, accessibilityLabel: nil, scale: .fixed(SbuTheme.figureLive, .mark))
        }
        .padding(SbuTheme.space4)
        .background { SbuPaper(grid: true) }
        .environment(\.sbuAccent, accent)
        .accessibilityElement(children: .combine)
    }
}

#Preview("Light") {
    SbuLiveFigure(value: "12:40", label: Text(verbatim: "Lettura"), accent: .habits)
}

#Preview("Dark") {
    SbuLiveFigure(value: "0:00", label: Text(verbatim: "Lettura"), fullStop: .set, accent: .habits)
        .preferredColorScheme(.dark)
}
