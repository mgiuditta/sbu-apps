// iOS only: the shell, the settings and list rows have no place on Apple Watch.
#if os(iOS)

import SwiftUI

/// A row of an `.insetGrouped` list: icon, title and subtitle on the left, figure and status on the right.
///
/// The icon tile is centred on the title and subtitle; the separator starts under the title, as on iOS.
public struct SbuListRow: View {
    private let title: LocalizedStringKey
    private let subtitle: LocalizedStringKey?
    private let systemImage: String
    private let iconBackground: Color
    private let iconForeground: Color
    private let amount: String?
    private let status: LocalizedStringKey?
    private let statusTone: SbuStatusTone

    @ScaledMetric(relativeTo: .headline) private var iconSide: CGFloat = 40
    @ScaledMetric(relativeTo: .title2) private var amountSize = SbuTheme.statSmallSize

    /// Creates a list row.
    /// - Parameters:
    ///   - title: Row title in `headline`.
    ///   - subtitle: Second line in `subheadline`, `inkMuted`.
    ///   - systemImage: SF Symbol drawn in the 40pt icon tile.
    ///   - iconBackground: Fill of the icon tile, usually an `accent*` token.
    ///   - iconForeground: Glyph color, usually `onAccent`.
    ///   - amount: Figure already formatted for the locale, shown in `statSmall`.
    ///   - status: One word under the figure, such as "tra 2 giorni".
    ///   - statusTone: Color of the status word.
    public init(
        _ title: LocalizedStringKey,
        subtitle: LocalizedStringKey? = nil,
        systemImage: String,
        iconBackground: Color,
        iconForeground: Color = SbuTheme.onAccent,
        amount: String? = nil,
        status: LocalizedStringKey? = nil,
        statusTone: SbuStatusTone = .neutral
    ) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.iconBackground = iconBackground
        self.iconForeground = iconForeground
        self.amount = amount
        self.status = status
        self.statusTone = statusTone
    }

    public var body: some View {
        LabeledContent {
            VStack(alignment: .trailing, spacing: 0) {
                if let amount {
                    Text(amount)
                        .font(SbuTheme.smallNumberFont(size: amountSize))
                        .foregroundStyle(SbuTheme.ink)
                }

                if let status {
                    Text(status)
                        .font(SbuTheme.footnote)
                        .foregroundStyle(statusTone.color)
                }
            }
        } label: {
            // Not a `Label`: outside a `List` it aligns the icon to the title's first line, so the
            // tile sat high next to a two-line title and subtitle. Centred here in and out of lists.
            HStack(spacing: SbuTheme.space3) {
                Image(systemName: systemImage)
                    .fontWeight(.medium)
                    .imageScale(.medium)
                    .foregroundStyle(iconForeground)
                    .frame(width: iconSide, height: iconSide)
                    .background(iconBackground, in: .rect(cornerRadius: SbuTheme.radiusMd))

                VStack(alignment: .leading, spacing: 0) {
                    Text(title)
                        .font(SbuTheme.headline)
                        .foregroundStyle(SbuTheme.ink)

                    if let subtitle {
                        Text(subtitle)
                            .font(SbuTheme.subheadline)
                            .foregroundStyle(SbuTheme.inkMuted)
                    }
                }
                .alignmentGuide(.listRowSeparatorLeading) { $0[.leading] }
            }
        }
        .listRowInsets(EdgeInsets(top: SbuTheme.space3, leading: SbuTheme.space4, bottom: SbuTheme.space3, trailing: SbuTheme.space4))
        .listRowBackground(SbuTheme.surfaceRaised)
        .listRowSeparatorTint(SbuTheme.line)
        .accessibilityElement(children: .combine)
    }
}

#Preview("Light") {
    SbuListRowPreview()
}

#Preview("Dark") {
    SbuListRowPreview()
        .preferredColorScheme(.dark)
}

private struct SbuListRowPreview: View {
    var body: some View {
        List {
            Section("Prossimi rinnovi") {
                SbuListRow("Netflix Premium", subtitle: "Intrattenimento · mensile", systemImage: "play.rectangle", iconBackground: SbuTheme.accentCards, amount: "17,99", status: "tra 2 giorni", statusTone: .warning)
                SbuListRow("iCloud+ 200 GB", subtitle: "Cloud · mensile", systemImage: "icloud", iconBackground: SbuTheme.accentDocs, amount: "2,99", status: "14 nov")
                SbuListRow("Spotify", subtitle: "Musica · annuale", systemImage: "music.note", iconBackground: SbuTheme.accentHabits, amount: "119,88", status: "pagato", statusTone: .success)
                SbuListRow("Livella", subtitle: "Accento ocra", systemImage: "level", iconBackground: SbuTheme.accentLevel)
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(SbuTheme.surface)
    }
}

#endif
