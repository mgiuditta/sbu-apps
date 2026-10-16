import SbuKit
import SwiftUI

/// The proximity as a bar in the accent: the system linear gauge, hidden from VoiceOver because
/// the figure above says the same.
struct ProximityBar: View {
    let value: Int

    var body: some View {
        Gauge(value: Double(value), in: 0...100) {
            EmptyView()
        }
        .gaugeStyle(.linearCapacity)
        .animation(.default, value: value)
        .accessibilityHidden(true)
    }
}

#Preview("Light") {
    ProximityBar(value: 64)
        .padding(SbuTheme.space4)
        .tint(SbuTheme.accentFind)
}

#Preview("Dark") {
    ProximityBar(value: 20)
        .padding(SbuTheme.space4)
        .tint(SbuTheme.accentFind)
        .preferredColorScheme(.dark)
}
