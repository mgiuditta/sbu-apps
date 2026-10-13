import SwiftUI

/// The layout of the tool screen: caption, the figure in `statHero` closed by `SbuFullStop`,
/// a context line, the indicator, and a row of pills at the bottom.
///
/// It sits on `surface`, like every screen: the figure in `ink`, captions in `inkMuted`, the
/// indicator in the accent. The figure is optional, because not every app has one. Use one per app.
public struct SbuToolField<Indicator: View, Pills: View>: View {
    private let caption: LocalizedStringKey
    /// The figure already formatted for the current locale, or `nil` when the app has none.
    let formattedValue: String?
    private let unit: String?
    private let context: LocalizedStringKey?
    private let contextSystemImage: String?
    private let contextTone: SbuStatusTone
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
    ///   - contextSystemImage: SF Symbol before the context line, required with a status tone.
    ///   - contextTone: Color of the context line; a status color always comes with its word and symbol.
    ///   - indicator: The drawing of the one thing, under the figure, in the accent.
    ///   - pills: The controls at the bottom of the screen.
    public init<Format: FormatStyle>(
        _ caption: LocalizedStringKey,
        value: Format.FormatInput,
        format: Format,
        unit: String? = nil,
        context: LocalizedStringKey? = nil,
        contextSystemImage: String? = nil,
        contextTone: SbuStatusTone = .neutral,
        @ViewBuilder indicator: () -> Indicator,
        @ViewBuilder pills: () -> Pills
    ) where Format.FormatOutput == String {
        self.caption = caption
        self.formattedValue = format.format(value)
        self.unit = unit
        self.context = context
        self.contextSystemImage = contextSystemImage
        self.contextTone = contextTone
        self.indicator = indicator()
        self.pills = pills()
    }

    /// Creates a tool screen without a figure.
    /// - Parameters:
    ///   - caption: Uppercase label above the indicator.
    ///   - context: One line under the caption.
    ///   - indicator: The drawing of the one thing, in the accent.
    ///   - pills: The controls at the bottom of the screen.
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
        self.contextSystemImage = nil
        self.contextTone = .neutral
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
                    .foregroundStyle(SbuTheme.inkMuted)

                if let formattedValue {
                    HStack(alignment: .firstTextBaseline, spacing: 0) {
                        Text(formattedValue)
                            .font(SbuTheme.numberFont(size: valueSize))
                            .tracking(SbuTheme.statHeroTracking)
                            // Tracking also follows the last glyph: give it back, or it eats the full stop's gap.
                            .padding(.trailing, -SbuTheme.statHeroTracking)
                            .foregroundStyle(SbuTheme.ink)
                            .contentTransition(.numericText())

                        if let unit {
                            Text(unit)
                                .font(SbuTheme.smallNumberFont(size: unitSize))
                                .foregroundStyle(SbuTheme.inkMuted)
                        }

                        SbuFullStop(fontSize: valueSize)
                    }
                }

                if let context {
                    HStack(alignment: .firstTextBaseline, spacing: SbuTheme.space1) {
                        if let contextSystemImage {
                            Image(systemName: contextSystemImage)
                                .fontWeight(.medium)
                                .imageScale(.medium)
                                .accessibilityHidden(true)
                        }

                        Text(context)
                    }
                    .font(SbuTheme.footnote)
                    .foregroundStyle(contextTone.color)
                }
            }
            .multilineTextAlignment(.center)
            // Never squeezed by an indicator that takes all the height, such as a grid or a
            // scroll view: the context line keeps all its lines.
            .fixedSize(horizontal: false, vertical: true)
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

#Preview("Contesto in danger") {
    SbuAppShell("Sbu Speed", slug: "speed", accent: SbuTheme.accentSpeed, appIcon: Image(decorative: "sbu-mark", bundle: SbuTheme.bundle)) {
        SbuToolField(
            "Velocità",
            value: 58,
            format: .number,
            unit: "km/h",
            context: "Oltre il limite di 50 km/h",
            contextSystemImage: "exclamationmark.triangle",
            contextTone: .danger
        ) {
            EmptyView()
        } pills: {
            SbuButton("Azzera viaggio", kind: .destructive) {}
        }
    } settings: {
        EmptyView()
    }
}

#Preview("Senza cifra") {
    SbuAppShell("Sbu Noise", slug: "noise", accent: SbuTheme.accentNoise, appIcon: Image(decorative: "sbu-mark", bundle: SbuTheme.bundle)) {
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
        SbuAppShell("Sbu Level", slug: "level", accent: SbuTheme.accentLevel, appIcon: Image(decorative: "sbu-mark", bundle: SbuTheme.bundle)) {
            SbuToolField("Inclinazione", value: 2.4, format: .number.precision(.fractionLength(1)), unit: "°", context: "In piano") {
                Circle()
                    .stroke(SbuTheme.line, lineWidth: SbuTheme.hairline)
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
