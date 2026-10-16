import SbuKit
import SwiftUI

/// How much the average moves: up in `success`, down in `danger`, always with its arrow and sign.
struct ChangeLabel: View {
    let change: Double

    var body: some View {
        HStack(spacing: SbuTheme.space1) {
            Image(systemName: symbol)
                .fontWeight(.medium)
                .imageScale(.medium)
            Text(change, format: LibrettoFormat.change)
                .monospacedDigit()
        }
        .font(SbuTheme.subheadline)
        .foregroundStyle(color)
    }

    /// Below a hundredth it shows as 0,00: no direction to tell.
    private var isFlat: Bool {
        abs(change) < 0.005
    }

    private var symbol: String {
        isFlat ? "equal" : change > 0 ? "arrow.up" : "arrow.down"
    }

    private var color: Color {
        isFlat ? SbuTheme.inkMuted : change > 0 ? SbuTheme.success : SbuTheme.danger
    }
}

#Preview("Light") {
    VStack {
        ChangeLabel(change: 0.2)
        ChangeLabel(change: -0.13)
        ChangeLabel(change: 0.001)
    }
}

#Preview("Dark") {
    ChangeLabel(change: -1.5)
        .preferredColorScheme(.dark)
}
