import SbuKit
import SwiftUI

/// The Record at the top left of the screen, after a crown.
struct RecordBadge: View {
    let record: Int

    var body: some View {
        Label {
            Text(record, format: .number)
                .monospacedDigit()
        } icon: {
            Image(systemName: "crown.fill")
                .fontWeight(.medium)
        }
        .font(SbuTheme.headline)
        .foregroundStyle(SbuTheme.inkMuted)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Record \(record)")
    }
}

#Preview("Light") {
    RecordBadge(record: 12_480).padding(SbuTheme.space4).sbuPaper()
}

#Preview("Dark") {
    RecordBadge(record: 12_480).padding(SbuTheme.space4).sbuPaper().preferredColorScheme(.dark)
}
