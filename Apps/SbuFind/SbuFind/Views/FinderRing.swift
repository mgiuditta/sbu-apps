import SbuKit
import SwiftUI

/// The finder's large ring around the device's symbol. Its fill eases to each reading, it dims
/// when the device falls silent, and it pops once at the "found it" moment, not with Reduce Motion.
struct FinderRing: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let tracked: TrackedDevice?
    let foundMoments: Int

    @State private var isPopping = false

    private var isLost: Bool { tracked?.isLost ?? true }

    var body: some View {
        SignalRing(
            proximity: tracked?.device.proximity ?? Proximity(rssi: Proximity.farthestRSSI),
            systemImage: tracked?.device.kind.systemImage ?? DeviceKind.other.systemImage,
            lineWidth: SbuTheme.space3,
            symbolScale: 0.42
        )
        .opacity(isLost ? 0.4 : 1)
        .scaleEffect(isPopping ? 1.08 : 1)
        .animation(.easeInOut(duration: 0.4), value: isLost)
        .onChange(of: foundMoments, pop)
    }

    private func pop() {
        guard !reduceMotion else { return }
        withAnimation(.spring(response: 0.25, dampingFraction: 0.5)) {
            isPopping = true
        } completion: {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                isPopping = false
            }
        }
    }
}

#Preview("Light") {
    FinderRing(
        tracked: TrackedDevice(
            device: NearbyDevice(id: UUID(), name: "Buds Pro", kind: .earbuds, signal: -55, lastSeen: .now),
            warmth: .hot,
            silence: 0
        ),
        foundMoments: 0
    )
    .frame(width: 260)
    .tint(SbuTheme.accentFind)
}

#Preview("Dark") {
    FinderRing(tracked: nil, foundMoments: 0)
        .frame(width: 260)
        .tint(SbuTheme.accentFind)
        .preferredColorScheme(.dark)
}
