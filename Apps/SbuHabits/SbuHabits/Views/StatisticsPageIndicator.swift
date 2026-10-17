import SbuKit
import SwiftUI

/// The pages of the Statistiche at the bottom, a grid for all the habits, then each
/// habit's symbol, the page on show in `ink`. With too many habits to fit, "2 di 25".
///
/// For VoiceOver and Switch Control it is one adjustable element, "Pagina, 2 di 25", that turns
/// the page with a swipe up or down: the pages are reached without the horizontal swipe.
struct StatisticsPageIndicator: View {
    let symbols: [String]
    let page: Int
    let turn: (Int) -> Void

    private var count: Int { symbols.count + 1 }

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: SbuTheme.space1) {
                ForEach(0..<count, id: \.self) { index in
                    Image(systemName: index == 0 ? "square.grid.2x2" : symbols[index - 1])
                        .foregroundStyle(index == page ? SbuTheme.ink : SbuTheme.inkMuted)
                }
            }
            .font(SbuTheme.caption)
            .imageScale(.medium)

            Text("\(page + 1) di \(count)")
                .font(SbuTheme.caption)
                .monospacedDigit()
                .foregroundStyle(SbuTheme.inkMuted)
        }
        // The symbols are a picture of the pages: past the largest text sizes they would not fit.
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
        .frame(minWidth: SbuTheme.controlRoundSm, minHeight: SbuTheme.controlRoundSm)
        .contentShape(.rect)
        .accessibilityElement()
        .accessibilityLabel(Text("Pagina"))
        .accessibilityValue(Text("\(page + 1) di \(count)"))
        .accessibilityAdjustableAction(adjust)
        // The tool screen under the sheet has its own Pagina.
        .accessibilityIdentifier("statistics-pages")
    }

    private func adjust(_ direction: AccessibilityAdjustmentDirection) {
        let next = switch direction {
        case .increment: page + 1
        case .decrement: page - 1
        @unknown default: page
        }
        if (0..<count).contains(next) {
            turn(next)
        }
    }
}

#Preview("Light") {
    StatisticsPageIndicator(symbols: ["drop", "book", "figure.walk", "cup.and.saucer"], page: 2) { _ in }
        .padding(SbuTheme.space4)
        .background(SbuTheme.paper)
}

#Preview("Dark") {
    StatisticsPageIndicator(symbols: ["drop", "book", "figure.walk", "cup.and.saucer"], page: 0) { _ in }
        .padding(SbuTheme.space4)
        .background(SbuTheme.paper)
        .preferredColorScheme(.dark)
}
