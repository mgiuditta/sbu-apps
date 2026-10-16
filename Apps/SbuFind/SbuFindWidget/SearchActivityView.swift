import SbuKit
import SwiftUI
import WidgetKit

/// The search on the Lock Screen and in the expanded Dynamic Island: the ring with the device's
/// symbol, its name, the percentage and the word. Stale, it asks to open Sbu Find; found, it
/// says so.
struct SearchActivityView: View {
    let attributes: SearchActivityAttributes
    let state: SearchActivityAttributes.ContentState
    let isStale: Bool

    private var status: LocalizedStringResource {
        if state.isFound {
            "Trovato"
        } else if isStale {
            "Apri Sbu Find per continuare la ricerca"
        } else if state.isLost {
            "Non si sente più"
        } else {
            state.warmth.name
        }
    }

    var body: some View {
        HStack(spacing: SbuTheme.space4) {
            SignalRing(proximity: state.proximity, systemImage: attributes.systemImage, lineWidth: SbuTheme.space1)
                .frame(width: SbuTheme.controlRound, height: SbuTheme.controlRound)
                .opacity(isStale || state.isLost ? 0.4 : 1)

            VStack(alignment: .leading, spacing: SbuTheme.space1) {
                Text(verbatim: attributes.deviceName)
                    .font(SbuTheme.headline)
                    .foregroundStyle(SbuTheme.ink)
                    .lineLimit(1)

                Text(status)
                    .font(SbuTheme.subheadline)
                    .foregroundStyle(SbuTheme.inkMuted)
                    .lineLimit(2)
            }

            Spacer(minLength: 0)

            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text(Double(state.percent) / 100, format: .percent.precision(.fractionLength(0)))
                    .font(SbuTheme.numberFont(size: SbuTheme.statSize))
                    .foregroundStyle(SbuTheme.ink)
                    .contentTransition(.numericText(value: Double(state.percent)))
                SbuFullStop(fontSize: SbuTheme.statSize)
            }
            .opacity(isStale ? 0.4 : 1)
        }
        .accessibilityElement(children: .combine)
    }
}
