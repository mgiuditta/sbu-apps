import SwiftUI

/// The title of the tool screen: Bricolage ExtraBold 34 at width 87, and under it the cartiglio,
/// one line of IBM Plex Mono 11 in uppercase, `inkMuted`, tracked 0.1 em.
///
/// The cartiglio carries metadata only, such as `SBU · ABITUDINI · SAB 17 OTT`: never a figure.
/// Both lines follow Dynamic Type; the title is a header for VoiceOver.
public struct SbuScreenTitle: View {
    private let title: Text
    private let cartiglio: String

    @ScaledMetric(relativeTo: .largeTitle) private var titleSize = SbuTheme.titleSize
    @ScaledMetric(relativeTo: .caption2) private var cartiglioSize = SbuTheme.cartiglioSize
    @Environment(\.locale) private var locale

    /// Creates the title.
    /// - Parameters:
    ///   - title: The screen title, such as "Abitudini".
    ///   - cartiglio: The metadata line, already localized, such as "Sbu · Abitudini · sab 17 ott".
    ///     It is drawn in uppercase.
    public init(_ title: LocalizedStringKey, cartiglio: String) {
        self.title = Text(title)
        self.cartiglio = cartiglio
    }

    /// Creates the title from text that is already localized.
    public init(verbatim title: String, cartiglio: String) {
        self.title = Text(verbatim: title)
        self.cartiglio = cartiglio
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space1) {
            title
                .font(.sbuFigure(size: titleSize, width: SbuTheme.figureWidthMid))
                .foregroundStyle(SbuTheme.ink)
                .accessibilityAddTraits(.isHeader)
            // Uppercased in the string, not with `.textCase`: the accessibility audit measures the
            // string, and a narrower lowercase measure reported the line as clipped.
            Text(verbatim: cartiglio.uppercased(with: locale))
                .font(.sbuCartiglio)
                .tracking(cartiglioSize * SbuTheme.cartiglioTracking)
                .foregroundStyle(SbuTheme.inkMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview("Light") {
    SbuScreenTitle("Abitudini", cartiglio: "Sbu · Abitudini · sab 17 ott")
        .padding(SbuTheme.space4)
        .frame(maxHeight: .infinity, alignment: .top)
        .sbuPaper()
}

#Preview("Dark") {
    SbuScreenTitle("Abitudini", cartiglio: "Sbu · Abitudini · sab 17 ott")
        .padding(SbuTheme.space4)
        .frame(maxHeight: .infinity, alignment: .top)
        .sbuPaper()
        .preferredColorScheme(.dark)
}

#Preview("AX5") {
    SbuScreenTitle("Abbonamenti", cartiglio: "Sbu · Abbonamenti · ottobre 2026")
        .padding(SbuTheme.space4)
        .frame(maxHeight: .infinity, alignment: .top)
        .sbuPaper()
        .dynamicTypeSize(.accessibility5)
}
