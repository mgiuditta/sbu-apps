import SbuKit
import SwiftUI

/// A person in a group: name, and messages with their share.
struct SenderRow: View {
    let sender: SenderStatistics

    var body: some View {
        LabeledContent {
            Text("\(sender.messages.formatted()) · \(sender.share.formatted(.percent.precision(.fractionLength(0))))")
                .monospacedDigit()
                .foregroundStyle(SbuTheme.inkMuted)
        } label: {
            if sender.isOwner {
                Text("Tu · \(sender.name)")
                    .foregroundStyle(SbuTheme.ink)
            } else {
                Text(verbatim: sender.name)
                    .foregroundStyle(SbuTheme.ink)
            }
        }
        .font(SbuTheme.body)
    }
}

#Preview("Light") {
    List { SenderRow(sender: .preview) }
}

#Preview("Dark") {
    List { SenderRow(sender: .preview) }
        .preferredColorScheme(.dark)
}
