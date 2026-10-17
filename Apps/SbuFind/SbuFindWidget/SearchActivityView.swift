import SbuKit
import SwiftUI
import WidgetKit

/// The search on the Lock Screen and in the expanded Dynamic Island: the device's name and the
/// signal as the figure. The full stop waits while you search and is set at the "found it"
/// moment, just before the activity goes. Silent, it says so; stale, it asks to open Sbu Find.
struct SearchActivityView: View {
    let attributes: SearchActivityAttributes
    let state: SearchActivityAttributes.ContentState
    let isStale: Bool

    private var label: Text {
        if state.isFound {
            Text(verbatim: attributes.deviceName)
        } else if isStale {
            Text("Apri Sbu Find")
        } else if state.isLost {
            Text("\(attributes.deviceName) non si sente più")
        } else {
            Text(verbatim: attributes.deviceName)
        }
    }

    var body: some View {
        SbuLiveFigure(
            value: (Double(state.percent) / 100).formatted(.percent.precision(.fractionLength(0))),
            label: label,
            fullStop: state.isFound ? .set : .waiting,
            accent: .find
        )
    }
}
