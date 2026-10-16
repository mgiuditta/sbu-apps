import SbuKit
import SwiftUI

/// The finder's tool field for a tracked device: the proximity closed by the full stop, the word
/// or how long it has been silent, the bar, and the hint.
struct FinderContent<Pills: View>: View {
    let tracked: TrackedDevice?
    @ViewBuilder let pills: Pills

    private var value: Int { tracked?.device.proximity.value ?? 0 }

    private var context: LocalizedStringKey {
        guard let tracked else { return "Freddo" }
        if tracked.isLost {
            return "Non sentito da \(tracked.silenceDuration.formatted(.units(allowed: [.minutes, .seconds], width: .abbreviated)))"
        }
        return tracked.warmth.key
    }

    private var contextSystemImage: String {
        guard let tracked else { return Warmth.cold.systemImage }
        return tracked.isLost ? "antenna.radiowaves.left.and.right.slash" : tracked.warmth.systemImage
    }

    var body: some View {
        SbuToolField(
            "Vicinanza",
            value: value,
            format: .number,
            spokenValue: Text("\(value) su 100"),
            context: context,
            contextSystemImage: contextSystemImage
        ) {
            VStack(spacing: SbuTheme.space4) {
                ProximityBar(value: value)

                Text("Muoviti piano e gira su te stesso: il numero sale quando ti avvicini. Non è una distanza.")
                    .font(SbuTheme.footnote)
                    .foregroundStyle(SbuTheme.inkMuted)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        } pills: {
            pills
        }
    }
}

#Preview("Light") {
    FinderContent(tracked: TrackedDevice(
        device: NearbyDevice(id: UUID(), name: "Buds Pro", kind: .earbuds, signal: -55, lastSeen: .now),
        warmth: .hot,
        silence: 0
    )) {
        EmptyView()
    }
    .background(SbuTheme.surface)
}

#Preview("Dark") {
    FinderContent(tracked: TrackedDevice(
        device: NearbyDevice(id: UUID(), name: "Buds Pro", kind: .earbuds, signal: -70, lastSeen: .now),
        warmth: .warm,
        silence: 8
    )) {
        EmptyView()
    }
    .background(SbuTheme.surface)
    .preferredColorScheme(.dark)
}
