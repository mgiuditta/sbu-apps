import SbuKit
import SwiftUI
import WidgetKit

/// The figure closed by the full stop, then the next doses, sized to each family.
struct MedsWidgetView: View {
    let entry: MedsEntry

    @Environment(\.widgetFamily) private var family

    private var content: WidgetContent { entry.content }

    var body: some View {
        layout
            .tint(SbuTheme.accentMeds)
            .containerBackground(for: .widget) {
                if family.isAccessory { Color.clear } else { SbuTheme.surface }
            }
    }

    @ViewBuilder
    private var layout: some View {
        switch family {
        case .accessoryInline:
            Text("Da prendere oggi: \(content.toTakeCount)")
        case .accessoryCircular:
            VStack(spacing: 0) {
                Text(content.toTakeCount, format: .number)
                    .font(SbuTheme.title2)
                    .monospacedDigit()
                    .widgetAccentable()
                Text("dosi")
                    .font(SbuTheme.footnote)
            }
        case .accessoryRectangular:
            VStack(alignment: .leading, spacing: 0) {
                Text("Da prendere oggi: \(content.toTakeCount)")
                    .font(SbuTheme.headline)
                    .widgetAccentable()
                ForEach(content.items.prefix(2), id: \.self) { item in
                    HStack(spacing: SbuTheme.space1) {
                        Text(item.dueDate, format: .dateTime.hour().minute())
                        Text(item.name)
                            .privacySensitive()
                    }
                    .font(SbuTheme.footnote)
                    .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        case .systemSmall:
            VStack(alignment: .leading, spacing: SbuTheme.space2) {
                WidgetFigure(content: content, size: SbuTheme.statSmallSize + SbuTheme.space2)
                Spacer(minLength: 0)
                if let first = content.items.first {
                    WidgetDoseLine(item: first)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        case .systemMedium:
            HStack(alignment: .top, spacing: SbuTheme.space4) {
                WidgetFigure(content: content, size: SbuTheme.statSmallSize + SbuTheme.space2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                WidgetDoseList(content: content, limit: 3)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxHeight: .infinity, alignment: .top)
        default:
            VStack(alignment: .leading, spacing: SbuTheme.space3) {
                WidgetFigure(content: content, size: SbuTheme.statSize)
                Divider()
                WidgetDoseList(content: content, limit: MedsProvider.itemLimit)
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
            Text("Da prendere oggi")
                .font(SbuTheme.caption)
                .textCase(.uppercase)
                .tracking(SbuTheme.captionTracking)
                .foregroundStyle(SbuTheme.inkMuted)
                .lineLimit(1)
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text(content.toTakeCount, format: .number)
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
        if content.isEmpty { return "Aggiungi un farmaco" }
        if content.lateCount > 0 { return "di cui \(content.lateCount) in ritardo" }
        return content.toTakeCount == 0 ? "Tutto preso" : "Niente in ritardo"
    }
}

/// The next doses still to take today.
private struct WidgetDoseList: View {
    let content: WidgetContent
    let limit: Int

    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space2) {
            ForEach(content.items.prefix(limit), id: \.self) { item in
                WidgetDoseLine(item: item)
            }
        }
    }
}

/// A dose: its medicine, then when, how much and for whom.
private struct WidgetDoseLine: View {
    let item: WidgetContent.Item

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(item.name)
                .font(SbuTheme.subheadline)
                .foregroundStyle(SbuTheme.ink)
                .lineLimit(1)
                .privacySensitive()
            HStack(spacing: SbuTheme.space1) {
                Text(item.dueDate, format: .dateTime.hour().minute())
                    .foregroundStyle(item.isLate ? SbuTheme.warning : SbuTheme.inkMuted)
                if item.isLate {
                    Text("in ritardo")
                        .foregroundStyle(SbuTheme.warning)
                }
                if !item.personName.isEmpty {
                    Text(verbatim: "·")
                    Text(item.personName)
                        .privacySensitive()
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
    MedsWidget()
} timeline: {
    MedsEntry.sample()
}

#Preview("Medium", as: .systemMedium) {
    MedsWidget()
} timeline: {
    MedsEntry.sample()
}

#Preview("Large", as: .systemLarge) {
    MedsWidget()
} timeline: {
    MedsEntry.sample()
}

#Preview("Lock Screen", as: .accessoryRectangular) {
    MedsWidget()
} timeline: {
    MedsEntry.sample()
}
