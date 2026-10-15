import SbuKit
import SwiftUI

/// A number in a list: what it counts on the left, its value on the right.
struct StatRow: View {
    let title: LocalizedStringKey
    let value: Text

    var body: some View {
        LabeledContent {
            value
                .monospacedDigit()
                .foregroundStyle(SbuTheme.inkMuted)
        } label: {
            Text(title)
                .foregroundStyle(SbuTheme.ink)
        }
        .font(SbuTheme.body)
    }
}

#Preview("Light") {
    List { StatRow(title: "Parole", value: Text(12_345, format: .number)) }
}

#Preview("Dark") {
    List { StatRow(title: "Parole", value: Text(12_345, format: .number)) }
        .preferredColorScheme(.dark)
}
