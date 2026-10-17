import SbuKit
import SwiftUI

/// A group of the tool screen on paper: its name in inkMuted, then its card.
struct CardSection<Content: View>: View {
    let title: LocalizedStringKey
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space2) {
            Text(title)
                .font(SbuTheme.footnote)
                .foregroundStyle(SbuTheme.inkMuted)
                .padding(.horizontal, SbuTheme.space4)
                .accessibilityAddTraits(.isHeader)
            content
        }
    }
}

#Preview("Light") {
    CardSection(title: "Spese") {
        SbuListCard([OverviewValue(id: "month", title: "Questo mese", value: "64,53 €")]) { value in
            ValueRow(value)
        }
    }
    .padding(SbuTheme.space4)
    .frame(maxHeight: .infinity, alignment: .top)
    .sbuPaper(grid: false)
}

#Preview("Dark") {
    CardSection(title: "Spese") {
        SbuListCard([OverviewValue(id: "month", title: "Questo mese", value: "64,53 €")]) { value in
            ValueRow(value)
        }
    }
    .padding(SbuTheme.space4)
    .frame(maxHeight: .infinity, alignment: .top)
    .sbuPaper(grid: false)
    .preferredColorScheme(.dark)
}
