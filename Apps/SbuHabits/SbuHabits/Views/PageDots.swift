import SbuKit
import SwiftUI

/// The dots under the grid, one per page, the current one in `ink`. Hidden with one page.
///
/// VoiceOver reaches every habit by swiping, the grid scrolls to its page; the dots are one
/// adjustable element as well, "Pagina, 2 di 3", that turns the page with a swipe up or down,
/// for VoiceOver and Switch Control.
struct PageDots: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let count: Int
    @Binding var page: Int?

    private var current: Int {
        min(max(page ?? 0, 0), max(count - 1, 0))
    }

    var body: some View {
        HStack(spacing: SbuTheme.space2) {
            ForEach(0..<count, id: \.self) { index in
                Circle()
                    .fill(index == current ? SbuTheme.ink : SbuTheme.line)
                    .frame(width: SbuTheme.space2, height: SbuTheme.space2)
            }
        }
        .opacity(count > 1 ? 1 : 0)
        // A target as large as a button's, for Switch Control and Voice Control.
        .frame(minWidth: SbuTheme.controlRoundSm, minHeight: SbuTheme.controlRoundSm)
        .contentShape(.rect)
        .accessibilityElement()
        .accessibilityLabel(Text("Pagina"))
        .accessibilityValue(Text("\(current + 1) di \(count)"))
        .accessibilityAdjustableAction(turn)
        .accessibilityHidden(count < 2)
    }

    private func turn(_ direction: AccessibilityAdjustmentDirection) {
        let next = switch direction {
        case .increment: current + 1
        case .decrement: current - 1
        @unknown default: current
        }
        guard (0..<count).contains(next), next != current else { return }
        withAnimation(reduceMotion ? nil : .snappy) {
            page = next
        }
    }
}

#Preview("Light") {
    PageDots(count: 3, page: .constant(1))
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
}

#Preview("Dark") {
    PageDots(count: 3, page: .constant(1))
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
        .preferredColorScheme(.dark)
}
