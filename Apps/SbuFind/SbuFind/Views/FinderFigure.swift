import SbuKit
import SwiftUI

/// The one figure of the finder: the signal as a percentage, as in Find Air. The full stop waits
/// while you search and is set once the device is in reach of your hand; under the figure the
/// word, or how long the device has been silent.
struct FinderFigure: View {
    let tracked: TrackedDevice?
    /// From the "found it" moment until the device sounds far again.
    let isFound: Bool

    private var percent: Double { tracked?.device.proximity.percent ?? 0 }

    private var value: String {
        percent.formatted(.percent.precision(.fractionLength(0)))
    }

    private var fullStop: SbuFullStop.State {
        guard let tracked, isFound, !tracked.isLost else { return .waiting }
        return .set
    }

    private var contextText: Text {
        guard let tracked else { return Text(Warmth.cold.name) }
        if tracked.silence > TrackedDevice.longAgo {
            return Text("Non nelle vicinanze")
        }
        if tracked.isLost {
            let silence = tracked.silenceDuration.formatted(.units(allowed: [.minutes, .seconds], width: .abbreviated))
            return Text("Non sentito da \(silence)")
        }
        return Text(tracked.warmth.name)
    }

    var body: some View {
        SbuFigure(value: value, fullStop: fullStop, context: contextText, accessibilityLabel: Text("Segnale"))
            .accessibilityValue(Text("\(Text(verbatim: value)), \(contextText)"))
            .accessibilityIdentifier("figure")
    }
}

#Preview("Light") {
    FinderFigure(
        tracked: TrackedDevice(
            device: NearbyDevice(id: UUID(), name: "Buds Pro", kind: .earbuds, signal: -45, lastSeen: .now),
            warmth: .veryClose,
            silence: 0
        ),
        isFound: true
    )
    .padding(SbuTheme.space4)
    .frame(maxHeight: .infinity, alignment: .top)
    .sbuPaper()
    .environment(\.sbuAccent, .find)
}

#Preview("Dark") {
    FinderFigure(
        tracked: TrackedDevice(
            device: NearbyDevice(id: UUID(), name: "Buds Pro", kind: .earbuds, signal: -70, lastSeen: .now),
            warmth: .warm,
            silence: 8
        ),
        isFound: false
    )
    .padding(SbuTheme.space4)
    .frame(maxHeight: .infinity, alignment: .top)
    .sbuPaper()
    .environment(\.sbuAccent, .find)
    .preferredColorScheme(.dark)
}
