#if DEBUG
import SbuKit
import SwiftUI

/// One device on the Taratura screen: name, raw and smoothed reading, percentage and band.
struct TuningReadingRow: View {
    let device: NearbyDevice

    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space1) {
            Text(verbatim: device.name ?? "—")
                .font(SbuTheme.headline)
            Text(verbatim: summary)
                .font(SbuTheme.footnote.monospacedDigit())
                .foregroundStyle(SbuTheme.inkMuted)
        }
    }

    private var summary: String {
        let raw = device.rawRSSI.map { $0.formatted() } ?? "—"
        let smoothed = device.signal.formatted(.number.precision(.fractionLength(1)))
        let percent = device.proximity.percent.formatted(.percent.precision(.fractionLength(0)))
        return "grezzo \(raw) · filtrato \(smoothed) dBm · \(percent) · \(String(localized: device.warmth.name))"
    }
}

#Preview("Light") {
    Form {
        TuningReadingRow(device: NearbyDevice(id: UUID(), name: "Buds Pro", kind: .earbuds, signal: -58.4, rawRSSI: -61, lastSeen: .now))
    }
}

#Preview("Dark") {
    Form {
        TuningReadingRow(device: NearbyDevice(id: UUID(), name: "Buds Pro", kind: .earbuds, signal: -58.4, rawRSSI: -61, lastSeen: .now))
    }
    .preferredColorScheme(.dark)
}
#endif
