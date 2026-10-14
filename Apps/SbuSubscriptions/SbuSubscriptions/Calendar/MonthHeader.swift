import SbuKit
import SwiftUI

/// The month's name between its arrows, then what it costs and what's left to pay, as secondary text.
struct MonthHeader: View {
    let grid: MonthGrid
    let month: MonthPayments
    let mainCurrency: String
    let totalSize: CGFloat
    let changeMonth: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space2) {
            HStack {
                Button("Mese precedente", systemImage: "chevron.left") { changeMonth(-1) }
                    .labelStyle(.iconOnly)
                    .frame(minWidth: 44, minHeight: 44)
                    .contentShape(.rect)
                Spacer()
                Text(grid.start, format: .dateTime.month(.wide).year())
                    .font(SbuTheme.headline)
                    .foregroundStyle(SbuTheme.ink)
                    .accessibilityAddTraits(.isHeader)
                Spacer()
                Button("Mese successivo", systemImage: "chevron.right") { changeMonth(1) }
                    .labelStyle(.iconOnly)
                    .frame(minWidth: 44, minHeight: 44)
                    .contentShape(.rect)
            }
            .buttonStyle(.borderless)
            .fontWeight(.medium)
            // The chevrons are small; their tap area is the 44 points iOS asks for.
            .frame(minHeight: 44)

            Text("Totale \(month.total.formatted(.currency(code: mainCurrency))) · ancora da pagare \(month.remaining.formatted(.currency(code: mainCurrency)))")
                .font(SbuTheme.smallNumberFont(size: totalSize))
                .foregroundStyle(SbuTheme.inkMuted)
            if month.missingRates > 0 {
                Label("Esclusi \(month.missingRates): manca il tasso", systemImage: "exclamationmark.triangle")
                    .font(SbuTheme.footnote)
                    .foregroundStyle(SbuTheme.warning)
            }
        }
    }
}
