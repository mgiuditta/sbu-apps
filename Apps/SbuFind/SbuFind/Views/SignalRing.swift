import SbuKit
import SwiftUI

/// A ring filled to the proximity in the accent, around the device's symbol, as in Find Air's
/// rows and finder. The fill eases to each new reading. Hidden from VoiceOver: the percentage
/// beside it says the same.
struct SignalRing: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let proximity: Proximity
    let systemImage: String
    /// Ring thickness: thin in a row, thick on the finder.
    var lineWidth: CGFloat = SbuTheme.space1
    /// Symbol size as a fraction of the ring's side.
    var symbolScale: CGFloat = 0.42

    var body: some View {
        GeometryReader { proxy in
            let side = min(proxy.size.width, proxy.size.height)
            ZStack {
                Circle()
                    .stroke(SbuTheme.line, lineWidth: lineWidth)

                Circle()
                    .trim(from: 0, to: RingFill.fraction(for: proximity))
                    .stroke(.tint, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .rotationEffect(.degrees(-90))

                Image(systemName: systemImage)
                    .resizable()
                    .scaledToFit()
                    .fontWeight(.medium)
                    .foregroundStyle(SbuTheme.ink)
                    .frame(width: side * symbolScale, height: side * symbolScale)
            }
            .padding(lineWidth / 2)
            .frame(width: side, height: side)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .aspectRatio(1, contentMode: .fit)
        .animation(reduceMotion ? nil : .smooth(duration: 0.6), value: proximity)
        .accessibilityHidden(true)
    }
}

#Preview("Light") {
    HStack(spacing: SbuTheme.space4) {
        SignalRing(proximity: Proximity(rssi: -52), systemImage: "airpods")
            .frame(width: 56)
        SignalRing(proximity: Proximity(rssi: -85), systemImage: "applewatch")
            .frame(width: 56)
        SignalRing(proximity: Proximity(rssi: -61), systemImage: "laptopcomputer", lineWidth: SbuTheme.space3, symbolScale: 0.45)
            .frame(width: 240)
    }
    .tint(SbuTheme.accentFind)
    .padding(SbuTheme.space4)
    .background(SbuTheme.surface)
}

#Preview("Dark") {
    SignalRing(proximity: Proximity(rssi: -61), systemImage: "headphones", lineWidth: SbuTheme.space3, symbolScale: 0.45)
        .frame(width: 240)
        .tint(SbuTheme.accentFind)
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
        .preferredColorScheme(.dark)
}
