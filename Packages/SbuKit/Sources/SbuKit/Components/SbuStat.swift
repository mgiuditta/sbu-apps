import SwiftUI

/// The central figure of an app: an uppercase caption, the number in `stat`, a context line.
///
/// Use one per management screen, near the top, never on the tool screen: there the figure
/// goes in `SbuToolField`. Do not color the number: put any state in `context` as a word.
public struct SbuStat: View {
    private let label: LocalizedStringKey
    /// The value already formatted for the current locale.
    let formattedValue: String
    private let unit: String?
    private let context: LocalizedStringKey?

    @ScaledMetric(relativeTo: .largeTitle) private var valueSize = SbuTheme.statSize
    @ScaledMetric(relativeTo: .title2) private var unitSize = SbuTheme.statSmallSize

    /// Creates a stat that formats its value with a `FormatStyle`.
    /// - Parameters:
    ///   - label: Uppercase caption above the figure, such as "Inclinazione".
    ///   - value: The number to show.
    ///   - format: How to format `value`; it follows the current locale unless it sets its own.
    ///   - unit: Short unit attached to the number, such as "°" or "gg".
    ///   - context: One line under the number, such as "calibrata".
    public init<Format: FormatStyle>(
        _ label: LocalizedStringKey,
        value: Format.FormatInput,
        format: Format,
        unit: String? = nil,
        context: LocalizedStringKey? = nil
    ) where Format.FormatOutput == String {
        self.label = label
        self.formattedValue = format.format(value)
        self.unit = unit
        self.context = context
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space1) {
            Text(label)
                .font(SbuTheme.caption)
                .textCase(.uppercase)
                .tracking(SbuTheme.captionTracking)
                .foregroundStyle(SbuTheme.inkMuted)

            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text(formattedValue)
                    .font(SbuTheme.numberFont(size: valueSize))
                    .tracking(SbuTheme.statTracking)
                    .foregroundStyle(SbuTheme.ink)
                    .contentTransition(.numericText())

                if let unit {
                    Text(unit)
                        .font(SbuTheme.smallNumberFont(size: unitSize))
                        .foregroundStyle(SbuTheme.inkMuted)
                }
            }

            if let context {
                Text(context)
                    .font(SbuTheme.footnote)
                    .foregroundStyle(SbuTheme.inkMuted)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(SbuTheme.space4)
        .background(SbuTheme.surfaceRaised, in: .rect(cornerRadius: SbuTheme.radiusLg))
        .accessibilityElement(children: .combine)
    }
}

#Preview("Light") {
    SbuStatPreview()
}

#Preview("Dark") {
    SbuStatPreview()
        .preferredColorScheme(.dark)
}

private struct SbuStatPreview: View {
    var body: some View {
        VStack(spacing: SbuTheme.space5) {
            SbuStat("Spesa mensile", value: Decimal(string: "128.90") ?? 0, format: .currency(code: "EUR"), context: "€ 1.546,80 all'anno")
            SbuStat("Streak", value: 14, format: .number, unit: "gg", context: "record 31")
            SbuStat("Inclinazione", value: 2.4, format: .number.precision(.fractionLength(1)), unit: "°", context: "calibrata")
        }
        .padding(SbuTheme.space4)
        .frame(maxHeight: .infinity)
        .background(SbuTheme.surface)
    }
}
