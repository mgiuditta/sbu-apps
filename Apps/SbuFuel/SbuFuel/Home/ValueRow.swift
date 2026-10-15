import SbuKit
import SwiftUI

/// A secondary figure: its name in ink, the value in inkMuted with steady digits.
struct ValueRow: View {
    let title: LocalizedStringKey
    let value: String

    var body: some View {
        LabeledContent {
            Text(value)
                .monospacedDigit()
                .foregroundStyle(SbuTheme.inkMuted)
        } label: {
            Text(title)
                .foregroundStyle(SbuTheme.ink)
        }
        .listRowBackground(SbuTheme.surfaceRaised)
    }
}

#Preview("Light") {
    List {
        ValueRow(title: "Ultimo pieno", value: "6,2 L/100 km")
    }
}

#Preview("Dark") {
    List {
        ValueRow(title: "Ultimo pieno", value: "6,2 L/100 km")
    }
    .preferredColorScheme(.dark)
}
