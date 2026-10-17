import SbuKit
import SwiftUI

/// The one figure: how many messages in the period, closed by the full stop, and the dates it spans.
struct ChatFigure: View {
    /// `nil` while the numbers load.
    let total: Int?
    let statistics: ChatStatistics?

    var body: some View {
        SbuFigure(
            value: (total ?? 0).formatted(),
            fullStop: (total ?? 0) > 0 ? .set : .waiting,
            context: context,
            accessibilityLabel: spoken
        )
        .redacted(reason: total == nil ? .placeholder : [])
    }

    /// "messaggi · 3 mar 2024 – 15 ott 2026", or why there is nothing to count.
    private var context: Text? {
        guard let total else { return nil }
        guard let span else { return Text("Nessun messaggio in questo periodo") }
        // Two strings, as Xcode asks for plurals that omit the number.
        let noun = total == 1 ? Text("messaggio") : Text("messaggi")
        return noun + Text(verbatim: " · \(span)")
    }

    /// "Messaggi, 4.218, 3 mar 2024 – 15 ott 2026".
    private var spoken: Text {
        let text = Text("Messaggi") + Text(verbatim: ", \((total ?? 0).formatted())")
        if let span {
            return text + Text(verbatim: ", \(span)")
        }
        if total != nil {
            return text + Text(verbatim: ", ") + Text("Nessun messaggio in questo periodo")
        }
        return text
    }

    private var span: String? {
        guard let first = statistics?.firstMessageAt, let last = statistics?.lastMessageAt else { return nil }
        return ChatDates.span(from: first, to: last)
    }
}

#Preview("Light") {
    ChatFigure(total: 4218, statistics: nil)
        .padding(SbuTheme.space4)
        .frame(maxHeight: .infinity, alignment: .top)
        .sbuPaper(grid: true)
        .environment(\.sbuAccent, .chats)
}

#Preview("Dark") {
    ChatFigure(total: 4218, statistics: nil)
        .padding(SbuTheme.space4)
        .frame(maxHeight: .infinity, alignment: .top)
        .sbuPaper(grid: true)
        .environment(\.sbuAccent, .chats)
        .preferredColorScheme(.dark)
}
