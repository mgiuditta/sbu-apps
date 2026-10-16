import SbuKit
import SwiftUI
import WidgetKit

/// The average closed by the full stop, then the next sitting, sized to each family.
struct LibrettoWidgetView: View {
    let entry: LibrettoWidgetEntry

    @Environment(\.widgetFamily) private var family

    var body: some View {
        content
            .tint(SbuTheme.accentLibretto)
            .containerBackground(for: .widget) {
                if family == .accessoryRectangular || family == .accessoryInline { Color.clear } else { SbuTheme.surface }
            }
    }

    @ViewBuilder
    private var content: some View {
        switch family {
        case .accessoryInline:
            InlineContent(entry: entry)
        case .accessoryRectangular:
            RectangularContent(entry: entry)
        case .systemMedium:
            HStack(alignment: .top, spacing: SbuTheme.space4) {
                AverageBlock(snapshot: entry.snapshot, size: SbuTheme.statSize)
                    .frame(maxWidth: .infinity, alignment: .leading)
                NextExamBlock(entry: entry)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxHeight: .infinity, alignment: .top)
        default:
            VStack(alignment: .leading, spacing: SbuTheme.space2) {
                AverageBlock(snapshot: entry.snapshot, size: SbuTheme.statSmallSize + 8)
                Spacer(minLength: 0)
                NextExamBlock(entry: entry)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }
}

#Preview("Small", as: .systemSmall) {
    LibrettoWidget()
} timeline: {
    LibrettoWidgetEntry(date: .now, snapshot: .sample(now: .now))
    LibrettoWidgetEntry(date: .now, snapshot: nil)
}

#Preview("Medium", as: .systemMedium) {
    LibrettoWidget()
} timeline: {
    LibrettoWidgetEntry(date: .now, snapshot: .sample(now: .now))
}

#Preview("Lock Screen", as: .accessoryRectangular) {
    LibrettoWidget()
} timeline: {
    LibrettoWidgetEntry(date: .now, snapshot: .sample(now: .now))
}

#Preview("Inline", as: .accessoryInline) {
    LibrettoWidget()
} timeline: {
    LibrettoWidgetEntry(date: .now, snapshot: .sample(now: .now))
}
