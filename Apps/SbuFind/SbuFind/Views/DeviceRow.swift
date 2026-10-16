import SbuKit
import SwiftUI

/// One nearby device: its kind's symbol, its name and kind, and how near it sounds in a word.
///
/// No figure and no colored ring: the one figure of the app is on the finder.
struct DeviceRow: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let device: NearbyDevice

    @ScaledMetric(relativeTo: .headline) private var symbolWidth: CGFloat = 32

    var body: some View {
        // The word goes under the name at the accessibility sizes, where the name needs the width.
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: SbuTheme.space1))
            : AnyLayout(HStackLayout(spacing: SbuTheme.space3))

        layout {
            HStack(spacing: SbuTheme.space3) {
                if !dynamicTypeSize.isAccessibilitySize {
                    Image(systemName: device.kind.systemImage)
                        .font(SbuTheme.headline)
                        .fontWeight(.medium)
                        .imageScale(.medium)
                        .foregroundStyle(SbuTheme.ink)
                        .frame(width: symbolWidth)
                        .accessibilityHidden(true)
                }

                VStack(alignment: .leading, spacing: 0) {
                    DeviceName(name: device.name)
                        .font(SbuTheme.headline)
                        .foregroundStyle(SbuTheme.ink)

                    Text(device.kind.name)
                        .font(SbuTheme.subheadline)
                        .foregroundStyle(SbuTheme.inkMuted)
                }
                .alignmentGuide(.listRowSeparatorLeading) { $0[.leading] }
            }

            if !dynamicTypeSize.isAccessibilitySize {
                Spacer(minLength: SbuTheme.space2)
            }

            HStack(spacing: SbuTheme.space1) {
                Image(systemName: device.warmth.systemImage)
                    .fontWeight(.medium)
                    .imageScale(.medium)
                    .accessibilityHidden(true)
                Text(device.warmth.name)
            }
            .font(SbuTheme.footnote)
            .foregroundStyle(SbuTheme.inkMuted)
        }
        .accessibilityElement(children: .combine)
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
            DeviceRow(device: NearbyDevice(id: UUID(), name: "Buds Pro", kind: .earbuds, rssi: -48, lastSeen: .now))
            DeviceRow(device: NearbyDevice(id: UUID(), name: "WH-1000XM5", kind: .headphones, rssi: -62, lastSeen: .now))
            DeviceRow(device: NearbyDevice(id: UUID(), name: nil, kind: .other, rssi: -90, lastSeen: .now))
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(SbuTheme.surface)
    }
}
