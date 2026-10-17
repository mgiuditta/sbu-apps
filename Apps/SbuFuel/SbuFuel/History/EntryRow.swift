import SbuKit
import SwiftUI

/// A row of the log: symbol tile, title and subtitle, then the amount and a status word, with its
/// row mark when the status is one to act on.
///
/// Like `SbuListRow`, but when the words don't fit on one line beside the amount, the amount and
/// status go under the title, on its leading edge, instead of under the symbol.
struct EntryRow: View {
    let title: Text
    var subtitle: Text?
    let systemImage: String
    var amount: String?
    var status: Text?
    /// The row mark beside the status: filled when it is due now or soon, empty when later, none when `nil`.
    var statusMark: Bool?

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .headline) private var iconSide: CGFloat = 40
    @ScaledMetric(relativeTo: .title2) private var amountSize = SbuTheme.statSmallSize

    var body: some View {
        HStack(spacing: SbuTheme.space3) {
            // At the accessibility sizes the words get the whole width.
            if !dynamicTypeSize.isAccessibilitySize {
                Image(systemName: systemImage)
                    .fontWeight(.medium)
                    .imageScale(.medium)
                    .foregroundStyle(SbuTheme.ink)
                    .frame(width: iconSide, height: iconSide)
                    .background(SbuTheme.surfaceSunken, in: .rect(cornerRadius: SbuTheme.radiusCard))
                    .accessibilityHidden(true)
            }
            ViewThatFits(in: .horizontal) {
                HStack(spacing: SbuTheme.space2) {
                    words
                    Spacer(minLength: 0)
                    figures(alignment: .trailing)
                }
                VStack(alignment: .leading, spacing: SbuTheme.space1) {
                    words
                    figures(alignment: .leading)
                }
            }
            .alignmentGuide(.listRowSeparatorLeading) { $0[.leading] }
        }
        .listRowInsets(EdgeInsets(top: SbuTheme.space3, leading: SbuTheme.space4, bottom: SbuTheme.space3, trailing: SbuTheme.space4))
        .listRowBackground(SbuTheme.surfaceRaised)
        .listRowSeparatorTint(SbuTheme.line)
        .contentShape(.rect)
        .accessibilityElement(children: .combine)
    }

    private var words: some View {
        VStack(alignment: .leading, spacing: 0) {
            title
                .font(SbuTheme.headline)
                .foregroundStyle(SbuTheme.ink)
            if let subtitle {
                subtitle
                    .font(SbuTheme.subheadline)
                    .foregroundStyle(SbuTheme.inkMuted)
            }
        }
        // Full height for every line: inside ViewThatFits the subtitle was offered a few points less.
        .fixedSize(horizontal: false, vertical: true)
    }

    private func figures(alignment: HorizontalAlignment) -> some View {
        VStack(alignment: alignment, spacing: 0) {
            if let amount {
                Text(amount)
                    .font(SbuTheme.smallNumberFont(size: amountSize))
                    .foregroundStyle(SbuTheme.ink)
            }
            if let status {
                // Ink, not a status color: the mark and the word say how close it is.
                HStack(spacing: SbuTheme.space2) {
                    if let statusMark {
                        SbuRowMark(filled: statusMark)
                    }
                    status
                        .font(SbuTheme.footnote)
                        .foregroundStyle(statusMark == true ? SbuTheme.ink : SbuTheme.inkMuted)
                }
            }
        }
    }
}

#Preview("Light") {
    List {
        EntryRow(title: Text(verbatim: "13 ottobre 2026"), subtitle: Text(verbatim: "47.845 km · 35,69 L"), systemImage: "fuelpump",
                 amount: "64,53 €", status: Text(verbatim: "6,1 L/100 km"))
        EntryRow(title: Text(verbatim: "Revisione"), subtitle: Text(verbatim: "Ogni 24 mesi"), systemImage: "checkmark.seal",
                 status: Text(verbatim: "Tra 20 giorni"), statusMark: true)
    }
}

#Preview("Dark") {
    List {
        EntryRow(title: Text(verbatim: "Cambio olio"), subtitle: Text(verbatim: "Ogni 15.000 km o 12 mesi"), systemImage: "drop",
                 status: Text(verbatim: "Scaduto"), statusMark: true)
    }
    .preferredColorScheme(.dark)
}
