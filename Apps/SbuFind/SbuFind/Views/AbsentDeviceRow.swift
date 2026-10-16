import SbuKit
import SwiftUI

/// One of your devices that is not heard now: its symbol dimmed, your name for it, and
/// "Non nelle vicinanze".
struct AbsentDeviceRow: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let saved: SavedDevice

    @ScaledMetric(relativeTo: .headline) private var ringSide = SbuTheme.controlRound

    var body: some View {
        HStack(spacing: SbuTheme.space4) {
            if !dynamicTypeSize.isAccessibilitySize {
                SignalRing(proximity: Proximity(value: 0), systemImage: saved.kind.systemImage)
                    .frame(width: ringSide, height: ringSide)
                    .opacity(0.4)
            }

            VStack(alignment: .leading, spacing: SbuTheme.space1) {
                Text(verbatim: saved.name)
                    .font(SbuTheme.headline)
                    .foregroundStyle(SbuTheme.ink)

                Text("Non nelle vicinanze")
                    .font(SbuTheme.subheadline)
                    .foregroundStyle(SbuTheme.inkMuted)
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, SbuTheme.space1)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("device")
    }
}

#Preview("Light") {
    List {
        AbsentDeviceRow(saved: SavedDevice(name: "Le mie cuffie", device: NearbyDevice(id: UUID(), name: "WH-1000XM5", kind: .headphones, signal: -60, lastSeen: .now)))
    }
}

#Preview("Dark") {
    List {
        AbsentDeviceRow(saved: SavedDevice(name: "Le mie cuffie", device: NearbyDevice(id: UUID(), name: "WH-1000XM5", kind: .headphones, signal: -60, lastSeen: .now)))
    }
    .preferredColorScheme(.dark)
}
