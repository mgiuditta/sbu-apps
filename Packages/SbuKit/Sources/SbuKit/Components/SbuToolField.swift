import SwiftUI

/// The layout of the tool screen: caption, the figure in `statHero`, a context line, the
/// indicator, and a row of pills at the bottom.
///
/// `SbuAppShell` paints the field and sets the dark color scheme; this view only places the
/// content on it. The figure is optional, because not every app has one. Use one per app.
public struct SbuToolField<Indicator: View, Pills: View>: View {
    private let caption: LocalizedStringKey
    /// The figure already formatted for the current locale, or `nil` when the app has none.
    let formattedValue: String?
    private let unit: String?
    private let context: LocalizedStringKey?
    private let indicator: Indicator
    private let pills: Pills

    @ScaledMetric(relativeTo: .largeTitle) private var valueSize = SbuTheme.statHeroSize
    @ScaledMetric(relativeTo: .title2) private var unitSize = SbuTheme.statSmallSize

    /// Creates a tool screen with a figure formatted by a `FormatStyle`.
    /// - Parameters:
    ///   - caption: Uppercase label above the figure, such as "Inclinazione".
    ///   - value: The figure to show.
    ///   - format: How to format `value`; it follows the current locale unless it sets its own.
    ///   - unit: Short unit attached to the figure, such as "°" or "dB".
    ///   - context: One line under the figure, such as "In bolla".
    ///   - indicator: The drawing of the one thing, under the figure, in the accent.
    ///   - pills: The controls at the bottom of the field.
    public init<Format: FormatStyle>(
        _ caption: LocalizedStringKey,
        value: Format.FormatInput,
        format: Format,
        unit: String? = nil,
        context: LocalizedStringKey? = nil,
        @ViewBuilder indicator: () -> Indicator,
        @ViewBuilder pills: () -> Pills
    ) where Format.FormatOutput == String {
        self.caption = caption
        self.formattedValue = format.format(value)
        self.unit = unit
        self.context = context
        self.indicator = indicator()
        self.pills = pills()
    }

    /// Creates a tool screen without a figure.
    /// - Parameters:
    ///   - caption: Uppercase label above the indicator.
    ///   - context: One line under the caption.
    ///   - indicator: The drawing of the one thing, in the accent.
    ///   - pills: The controls at the bottom of the field.
    public init(
        _ caption: LocalizedStringKey,
        context: LocalizedStringKey? = nil,
        @ViewBuilder indicator: () -> Indicator,
        @ViewBuilder pills: () -> Pills
    ) {
        self.caption = caption
        self.formattedValue = nil
        self.unit = nil
        self.context = context
        self.indicator = indicator()
        self.pills = pills()
    }

    public var body: some View {
        VStack(spacing: SbuTheme.space8) {
            VStack(spacing: SbuTheme.space1) {
                Text(caption)
                    .font(SbuTheme.caption)
                    .textCase(.uppercase)
                    .tracking(SbuTheme.captionTracking)
                    .foregroundStyle(SbuTheme.onFieldMuted)

                if let formattedValue {
                    HStack(alignment: .firstTextBaseline, spacing: 0) {
                        Text(formattedValue)
                            .font(SbuTheme.numberFont(size: valueSize))
                            .tracking(SbuTheme.statHeroTracking)
                            .foregroundStyle(SbuTheme.onField)
                            .contentTransition(.numericText())

                        if let unit {
                            Text(unit)
                                .font(SbuTheme.numberFont(size: unitSize))
                                .foregroundStyle(SbuTheme.onFieldMuted)
                        }
                    }
                }

                if let context {
                    Text(context)
                        .font(SbuTheme.footnote)
                        .foregroundStyle(SbuTheme.onFieldMuted)
                }
            }
            .multilineTextAlignment(.center)
            .accessibilityElement(children: .combine)

            indicator

            Spacer(minLength: 0)

            HStack(spacing: SbuTheme.space2) {
                pills
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, SbuTheme.space4)
        .padding(.top, SbuTheme.space4)
        .padding(.bottom, SbuTheme.space8)
    }
}

#Preview("Light") {
    SbuToolFieldPreview()
}

#Preview("Dark") {
    SbuToolFieldPreview()
        .preferredColorScheme(.dark)
}

#Preview("Senza cifra") {
    SbuAppShell("Sbu Noise", accent: SbuTheme.accentNoise, field: SbuTheme.fieldNoise, appIcon: Image(decorative: "sbu-mark", bundle: SbuTheme.bundle)) {
        SbuToolField("Rumore rosa", context: "In riproduzione") {
            Image(systemName: "waveform")
                .font(.largeTitle)
                .foregroundStyle(.tint)
                .accessibilityHidden(true)
        } pills: {
            SbuButton("Ferma") {}
        }
    } settings: {
        EmptyView()
    }
}

private struct SbuToolFieldPreview: View {
    var body: some View {
        SbuAppShell("Sbu Level", accent: SbuTheme.accentLevel, onAccent: SbuTheme.onAccentLevel, field: SbuTheme.fieldLevel, appIcon: Image(decorative: "sbu-mark", bundle: SbuTheme.bundle)) {
            SbuToolField("Inclinazione", value: 2.4, format: .number.precision(.fractionLength(1)), unit: "°", context: "In piano") {
                Circle()
                    .stroke(SbuTheme.onFieldMuted, lineWidth: SbuTheme.hairline)
                    .frame(maxWidth: 240)
                    .accessibilityHidden(true)
            } pills: {
                SbuButton("Calibra") {}
            }
        } settings: {
            EmptyView()
        }
    }
}
