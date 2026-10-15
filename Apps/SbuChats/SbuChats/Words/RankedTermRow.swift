import SbuKit
import SwiftUI

/// A place in the ranking: position, word or emoji, times used.
///
/// At the accessibility sizes the word gets the whole width, with position and count under it:
/// beside them it broke mid-word.
struct RankedTermRow: View {
    let rank: Int
    let term: RankedTerm

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .body) private var rankWidth: CGFloat = 32

    var body: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: SbuTheme.space1) {
                    termText
                    HStack(alignment: .firstTextBaseline) {
                        rankText
                        Spacer(minLength: SbuTheme.space2)
                        countText
                    }
                }
            } else {
                HStack(alignment: .firstTextBaseline, spacing: SbuTheme.space3) {
                    rankText
                        .frame(minWidth: rankWidth, alignment: .leading)
                    termText
                    Spacer(minLength: SbuTheme.space2)
                    countText
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: "\(rank.formatted()). \(term.term)"))
        .accessibilityValue(Text("\(term.count) volte"))
    }

    private var rankText: some View {
        Text(rank, format: .number)
            .font(SbuTheme.subheadline)
            .monospacedDigit()
            .foregroundStyle(SbuTheme.inkMuted)
    }

    private var termText: some View {
        Text(verbatim: term.term)
            .font(SbuTheme.body)
            .foregroundStyle(SbuTheme.ink)
    }

    private var countText: some View {
        Text(term.count, format: .number)
            .font(SbuTheme.body)
            .monospacedDigit()
            .foregroundStyle(SbuTheme.inkMuted)
    }
}

#Preview("Light") {
    List { RankedTermRow(rank: 1, term: RankedTerm(term: "pizza", count: 214)) }
}

#Preview("Dark") {
    List { RankedTermRow(rank: 1, term: RankedTerm(term: "pizza", count: 214)) }
        .preferredColorScheme(.dark)
}
