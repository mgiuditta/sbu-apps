import SbuKit
import SwiftUI

/// A place in the ranking: position, word or emoji, times used.
struct RankedTermRow: View {
    let rank: Int
    let term: RankedTerm

    @ScaledMetric(relativeTo: .body) private var rankWidth: CGFloat = 32

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: SbuTheme.space3) {
            Text(rank, format: .number)
                .font(SbuTheme.subheadline)
                .monospacedDigit()
                .foregroundStyle(SbuTheme.inkMuted)
                .frame(minWidth: rankWidth, alignment: .leading)
            Text(verbatim: term.term)
                .font(SbuTheme.body)
                .foregroundStyle(SbuTheme.ink)
            Spacer(minLength: SbuTheme.space2)
            Text(term.count, format: .number)
                .font(SbuTheme.body)
                .monospacedDigit()
                .foregroundStyle(SbuTheme.inkMuted)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: "\(rank.formatted()). \(term.term)"))
        .accessibilityValue(Text("\(term.count) volte"))
    }
}

#Preview("Light") {
    List { RankedTermRow(rank: 1, term: RankedTerm(term: "pizza", count: 214)) }
}

#Preview("Dark") {
    List { RankedTermRow(rank: 1, term: RankedTerm(term: "pizza", count: 214)) }
        .preferredColorScheme(.dark)
}
