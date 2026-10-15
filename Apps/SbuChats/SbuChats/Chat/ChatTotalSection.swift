import SbuKit
import SwiftUI

/// The one figure: how many messages in the period, closed by the full stop, and the dates it spans.
struct ChatTotalSection: View {
    /// `nil` while the numbers load.
    let total: Int?
    let statistics: ChatStatistics?

    var body: some View {
        Section {
            SbuStat("Messaggi", value: total ?? 0, format: .number, context: context)
                .redacted(reason: total == nil ? .placeholder : [])
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
        }
    }

    private var context: LocalizedStringKey? {
        guard let first = statistics?.firstMessageAt, let last = statistics?.lastMessageAt else {
            return total == nil ? nil : "Nessun messaggio in questo periodo"
        }
        return "\(ChatDates.span(from: first, to: last))"
    }
}

#Preview("Light") {
    List { ChatTotalSection(total: 4218, statistics: nil) }
}

#Preview("Dark") {
    List { ChatTotalSection(total: 4218, statistics: nil) }
        .preferredColorScheme(.dark)
}
