import SbuKit
import SwiftUI
import WidgetKit

/// The figure closed by the full stop, then the most urgent chores, sized to each family.
struct TidyWidgetView: View {
    let entry: TidyEntry

    @Environment(\.widgetFamily) private var family

    private var content: WidgetContent { entry.content }

    var body: some View {
        layout
            .tint(SbuTheme.accentTidy)
            .containerBackground(for: .widget) {
                if family.isAccessory { Color.clear } else { SbuTheme.surface }
            }
    }

    @ViewBuilder
    private var layout: some View {
        switch family {
        case .accessoryInline:
            Text("Da fare oggi: \(content.toDoCount)")
        case .accessoryCircular:
            VStack(spacing: 0) {
                Text(content.toDoCount, format: .number)
                    .font(SbuTheme.title2)
                    .monospacedDigit()
                    .widgetAccentable()
                Text("da fare")
                    .font(SbuTheme.footnote)
            }
        case .accessoryRectangular:
            VStack(alignment: .leading, spacing: 0) {
                Text("Da fare oggi: \(content.toDoCount)")
                    .font(SbuTheme.headline)
                    .widgetAccentable()
                ForEach(content.items.prefix(2), id: \.self) { item in
                    Text(item.name)
                        .font(SbuTheme.footnote)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        case .systemSmall:
            VStack(alignment: .leading, spacing: SbuTheme.space2) {
                WidgetFigure(content: content, size: SbuTheme.statSmallSize + 8)
                Spacer(minLength: 0)
                if let first = content.items.first {
                    WidgetChoreLine(item: first, showsRoom: false)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        case .systemMedium:
            HStack(alignment: .top, spacing: SbuTheme.space4) {
                WidgetFigure(content: content, size: SbuTheme.statSmallSize + 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                WidgetChoreList(content: content, limit: 3)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxHeight: .infinity, alignment: .top)
        default:
            VStack(alignment: .leading, spacing: SbuTheme.space3) {
                WidgetFigure(content: content, size: SbuTheme.statSize)
                Divider()
                WidgetChoreList(content: content, limit: TidyProvider.itemLimit)
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }
}

/// The caption, the count and its full stop: the one figure of the widget.
private struct WidgetFigure: View {
    let content: WidgetContent
    let size: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space1) {
            Text("Da fare oggi")
                .font(SbuTheme.caption)
                .textCase(.uppercase)
                .tracking(SbuTheme.captionTracking)
                .foregroundStyle(SbuTheme.inkMuted)
                .lineLimit(1)
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text(content.toDoCount, format: .number)
                    .font(SbuTheme.numberFont(size: size))
                    .foregroundStyle(SbuTheme.ink)
                    .lineLimit(1)
                    .widgetAccentable()
                SbuFullStop(fontSize: size)
            }
            Text(context)
                .font(SbuTheme.footnote)
                .foregroundStyle(SbuTheme.inkMuted)
                .lineLimit(1)
        }
    }

    private var context: LocalizedStringKey {
        if content.isEmpty { return "Aggiungi le stanze" }
        if content.overdueCount > 0 { return "di cui \(content.overdueCount) in ritardo" }
        return content.toDoCount == 0 ? "Casa in ordine" : "Niente in ritardo"
    }
}

/// The chores to do, or the next ones when nothing is.
private struct WidgetChoreList: View {
    let content: WidgetContent
    let limit: Int

    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space2) {
            ForEach(content.items.prefix(limit), id: \.self) { item in
                WidgetChoreLine(item: item, showsRoom: true)
            }
        }
    }
}

/// A chore: its name, then when and where.
private struct WidgetChoreLine: View {
    let item: WidgetContent.Item
    let showsRoom: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(item.name)
                .font(SbuTheme.subheadline)
                .foregroundStyle(SbuTheme.ink)
                .lineLimit(1)
            HStack(spacing: SbuTheme.space1) {
                Text(item.label.text)
                if showsRoom {
                    Text(verbatim: "·")
                    Text(item.roomName)
                }
            }
            .font(SbuTheme.footnote)
            .foregroundStyle(SbuTheme.inkMuted)
            .lineLimit(1)
        }
    }
}

private extension WidgetFamily {
    var isAccessory: Bool {
        self == .accessoryInline || self == .accessoryRectangular || self == .accessoryCircular
    }
}

#Preview("Small", as: .systemSmall) {
    TidyWidget()
} timeline: {
    TidyEntry.sample()
}

#Preview("Medium", as: .systemMedium) {
    TidyWidget()
} timeline: {
    TidyEntry.sample()
}

#Preview("Large", as: .systemLarge) {
    TidyWidget()
} timeline: {
    TidyEntry.sample()
}

#Preview("Lock Screen", as: .accessoryRectangular) {
    TidyWidget()
} timeline: {
    TidyEntry.sample()
}
