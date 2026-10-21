import SwiftUI
import WidgetKit

/// The Live Activity layout: a label and the figure (40) with its `mark` full stop, on paper.
///
/// The full stop waits while the process runs and is `.set` at the end: the app then ends the
/// activity after `liveEndDelay` (4 s). The full stop is `.widgetAccentable()` on the Lock Screen.
public struct SbuLiveFigure: View {
    private let value: String
    private let countdown: ClosedRange<Date>?
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
        countdown = nil
        self.unit = unit
        self.label = label
        self.fullStop = fullStop
        self.accent = accent
    }

    /// Creates a Live Activity figure that counts down by itself to the end of `countdown`, so it
    /// keeps time on the Lock Screen while the app is asleep.
    /// - Parameters:
    ///   - countdown: From now to the moment the countdown reaches zero.
    ///   - label: What is running, such as "Modalità post".
    ///   - fullStop: `.waiting` while running, `.set` at the end.
    ///   - accent: The app's accent, for the `.set` full stop.
    public init(countdown: ClosedRange<Date>, label: Text, fullStop: SbuFullStop.State = .waiting, accent: SbuAccent) {
        value = ""
        self.countdown = countdown
        unit = nil
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
            if let countdown {
                HStack(alignment: .lastTextBaseline, spacing: 0) {
                    Text(timerInterval: countdown, countsDown: true)
                        .font(.sbuFigure(size: SbuTheme.figureLive))
                        .monospacedDigit()
                        .foregroundStyle(SbuTheme.ink)
                        .multilineTextAlignment(.trailing)
                        .lineLimit(1)
                    SbuFullStop(fullStop, size: .mark)
                }
                .fixedSize()
            } else {
                SbuFigure(value: value, unit: unit, fullStop: fullStop, context: nil, accessibilityLabel: nil, scale: .fixed(SbuTheme.figureLive, .mark))
            }
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

#Preview("Countdown") {
    SbuLiveFigure(countdown: Date.now...Date.now.addingTimeInterval(600), label: Text(verbatim: "Modalità post"), accent: .social)
}

#Preview("Dark") {
    SbuLiveFigure(value: "0:00", label: Text(verbatim: "Lettura"), fullStop: .set, accent: .habits)
        .preferredColorScheme(.dark)
}
