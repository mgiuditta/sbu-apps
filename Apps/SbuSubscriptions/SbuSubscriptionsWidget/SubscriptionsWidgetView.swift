import SbuKit
import SwiftUI
import WidgetKit

/// The figure closed by the full stop, then the payments coming, sized to each family.
struct SubscriptionsWidgetView: View {
    let entry: SubscriptionsWidgetEntry

    @Environment(\.widgetFamily) private var family

    var body: some View {
        content
            .tint(SbuTheme.accentSubscriptions)
            .containerBackground(for: .widget) {
                if family.isAccessory { Color.clear } else { SbuTheme.surface }
            }
    }

    @ViewBuilder
    private var content: some View {
        if entry.isEmpty {
            Text("Nessun abbonamento")
                .font(SbuTheme.footnote)
                .foregroundStyle(SbuTheme.inkMuted)
        } else {
            switch family {
            case .accessoryInline: inline
            case .accessoryRectangular: rectangular
            case .systemSmall:
                VStack(alignment: .leading, spacing: SbuTheme.space2) {
                    WidgetFigure(entry: entry, size: SbuTheme.statSmallSize + 8, isCompact: true)
                    Spacer(minLength: 0)
                    if let next = entry.upcoming.first {
                        PaymentLine(payment: next, today: entry.date, showsPrice: false)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            case .systemMedium:
                HStack(alignment: .top, spacing: SbuTheme.space4) {
                    WidgetFigure(entry: entry, size: SbuTheme.statSmallSize + 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    PaymentList(payments: Array(entry.upcoming.prefix(3)), today: entry.date)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxHeight: .infinity, alignment: .top)
            default:
                VStack(alignment: .leading, spacing: SbuTheme.space3) {
                    WidgetFigure(entry: entry, size: SbuTheme.statSize)
                    Text("Ancora da pagare questo mese: \(entry.monthRemaining.formatted(.currency(code: entry.currencyCode)))")
                        .font(SbuTheme.footnote)
                        .foregroundStyle(SbuTheme.inkMuted)
                    Divider()
                    PaymentList(payments: entry.upcoming, today: entry.date)
                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
        }
    }

    private var rectangular: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Prossimo rinnovo")
                .font(.caption)
            if let next = entry.upcoming.first {
                Text(next.name)
                    .font(.headline)
                    .widgetAccentable()
                    .lineLimit(1)
                HStack(spacing: SbuTheme.space1) {
                    PaymentDayText(day: next.day, today: entry.date)
                    Text("·")
                    Text(next.price, format: .currency(code: next.currencyCode))
                }
                .font(.caption)
                .lineLimit(1)
            } else {
                Text("Nessun pagamento in arrivo").font(.caption)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var inline: some View {
        Group {
            if let next = entry.upcoming.first {
                Text("\(next.name) \(Text(next.price, format: .currency(code: next.currencyCode)))")
            } else {
                Text("Nessun pagamento in arrivo")
            }
        }
    }
}

/// The caption, the total and its full stop: the one figure of the widget.
private struct WidgetFigure: View {
    let entry: SubscriptionsWidgetEntry
    let size: CGFloat
    /// The small widget has room for "All'anno", not "Spendi all'anno · Famiglia".
    var isCompact = false

    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space1) {
            Text(isCompact ? compactCaption : caption)
                .font(SbuTheme.caption)
                .textCase(.uppercase)
                .tracking(SbuTheme.captionTracking)
                .foregroundStyle(SbuTheme.inkMuted)
                .lineLimit(1)
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text(entry.total, format: .currency(code: entry.currencyCode))
                    .font(SbuTheme.numberFont(size: size))
                    .foregroundStyle(SbuTheme.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .widgetAccentable()
                SbuFullStop(fontSize: size)
            }
        }
    }

    private var compactCaption: LocalizedStringKey {
        entry.period == .year ? "All'anno" : "Al mese"
    }

    private var caption: LocalizedStringKey {
        switch (entry.period, entry.listName) {
        case (.year, nil): "Spendi all'anno"
        case (.month, nil): "Spendi al mese"
        case let (.year, name?): "Spendi all'anno · \(name)"
        case let (.month, name?): "Spendi al mese · \(name)"
        }
    }
}

/// The next payments, one line each.
private struct PaymentList: View {
    let payments: [UpcomingPayment]
    let today: Date

    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space2) {
            if payments.isEmpty {
                Text("Nessun pagamento in arrivo")
                    .font(SbuTheme.footnote)
                    .foregroundStyle(SbuTheme.inkMuted)
            }
            ForEach(payments, id: \.self) { payment in
                PaymentLine(payment: payment, today: today, showsPrice: true)
            }
        }
    }
}

/// A payment coming: its name, then when, and how much where there's room.
private struct PaymentLine: View {
    let payment: UpcomingPayment
    let today: Date
    let showsPrice: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(payment.name)
                .font(SbuTheme.subheadline)
                .foregroundStyle(SbuTheme.ink)
                .lineLimit(1)
            HStack(spacing: SbuTheme.space1) {
                PaymentDayText(day: payment.day, today: today)
                if showsPrice {
                    Text("·")
                    Text(payment.price, format: .currency(code: payment.currencyCode))
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
    SubscriptionsWidget()
} timeline: {
    SubscriptionsWidgetEntry.sample()
}

#Preview("Medium", as: .systemMedium) {
    SubscriptionsWidget()
} timeline: {
    SubscriptionsWidgetEntry.sample()
}

#Preview("Large", as: .systemLarge) {
    SubscriptionsWidget()
} timeline: {
    SubscriptionsWidgetEntry.sample()
}

#Preview("Lock Screen", as: .accessoryRectangular) {
    SubscriptionsWidget()
} timeline: {
    SubscriptionsWidgetEntry.sample()
}
