import SbuKit
import SwiftUI

/// One nearby device, as in Find Air: its symbol inside a ring filled to the signal, its name,
/// and the signal as a percentage under it. VoiceOver also hears the kind and the word.
struct DeviceRow: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let device: NearbyDevice
    /// Your name for it, when it is one of your devices.
    var savedName: String?

    @ScaledMetric(relativeTo: .headline) private var ringSide = SbuTheme.controlRound

    var body: some View {
        HStack(spacing: SbuTheme.space4) {
            // At the accessibility sizes the name gets the whole width.
            if !dynamicTypeSize.isAccessibilitySize {
                SignalRing(proximity: device.proximity, systemImage: device.kind.systemImage)
                    .frame(width: ringSide, height: ringSide)
            }

            VStack(alignment: .leading, spacing: SbuTheme.space1) {
                DeviceName(name: savedName ?? device.name)
                    .font(SbuTheme.headline)
                    .foregroundStyle(SbuTheme.ink)

                Text(device.proximity.percent, format: .percent.precision(.fractionLength(0)))
                    .font(SbuTheme.subheadline.monospacedDigit())
                    .foregroundStyle(SbuTheme.inkMuted)
                    .contentTransition(.numericText())
            }
            .alignmentGuide(.listRowSeparatorLeading) { $0[.leading] }

            Spacer(minLength: 0)
        }
        .padding(.vertical, SbuTheme.space1)
        .accessibilityElement(children: .combine)
        .accessibilityValue(Text("\(Text(device.kind.name)), \(Text(device.warmth.name))"))
        .accessibilityIdentifier("device")
    }
}

#Preview("Light") {
    DeviceRowPreview()
}

#Preview("Dark") {
    DeviceRowPreview()
        .preferredColorScheme(.dark)
}

private struct DeviceRowPreview: View {
    var body: some View {
        List {
            DeviceRow(device: NearbyDevice(id: UUID(), name: "Buds Pro", kind: .earbuds, signal: -48, lastSeen: .now))
            DeviceRow(device: NearbyDevice(id: UUID(), name: "WH-1000XM5", kind: .headphones, signal: -62, lastSeen: .now))
            DeviceRow(device: NearbyDevice(id: UUID(), name: nil, kind: .other, signal: -90, lastSeen: .now))
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentFind)
    }
}
