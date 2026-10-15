import SbuKit
import SwiftUI

/// A chat in the list: its name, the span of its messages, and how many there are.
struct ChatRow: View {
    let chat: ChatSummary

    @ScaledMetric(relativeTo: .title2) private var countSize = SbuTheme.statSmallSize
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        let layout = dynamicTypeSize.isAccessibilitySize ? AnyLayout(VStackLayout(alignment: .leading, spacing: SbuTheme.space1))
            : AnyLayout(HStackLayout(alignment: .firstTextBaseline, spacing: SbuTheme.space3))
        layout {
            VStack(alignment: .leading, spacing: 0) {
                Text(verbatim: chat.title)
                    .font(SbuTheme.headline)
                    .foregroundStyle(SbuTheme.ink)
                Text(ChatDates.span(from: chat.firstMessageAt, to: chat.lastMessageAt))
                    .font(SbuTheme.subheadline)
                    .foregroundStyle(SbuTheme.inkMuted)
            }
            if !dynamicTypeSize.isAccessibilitySize { Spacer(minLength: 0) }
            Text(chat.messageCount, format: .number)
                .font(SbuTheme.smallNumberFont(size: countSize))
                .foregroundStyle(SbuTheme.ink)
        }
        .padding(.vertical, SbuTheme.space1)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: "\(chat.title), \(ChatDates.span(from: chat.firstMessageAt, to: chat.lastMessageAt))"))
        .accessibilityValue(Text("\(chat.messageCount) messaggi"))
    }
}

#Preview("Light") {
    List { ChatRow(chat: .preview) }
}

#Preview("Dark") {
    List { ChatRow(chat: .preview) }
        .preferredColorScheme(.dark)
}
