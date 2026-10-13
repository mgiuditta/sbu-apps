import SbuKit
import SwiftUI

/// The top of the habit form and of its Notifiche screen: the habit's ring as the grid will draw
/// it, and its title in capitals after the heart (Salute) or the ⊘ (Da evitare). The accessory
/// sits on the ring's bottom right: the form puts the symbol button there.
struct HabitPreview<Accessory: View>: View {
    let draft: HabitDraft
    let ringSize: CGFloat
    let symbolFont: Font
    let accessory: Accessory

    init(draft: HabitDraft, ringSize: CGFloat, symbolFont: Font, @ViewBuilder accessory: () -> Accessory) {
        self.draft = draft
        self.ringSize = ringSize
        self.symbolFont = symbolFont
        self.accessory = accessory()
    }

    var body: some View {
        VStack(spacing: SbuTheme.space3) {
            // A picture of the ring: the title says what it shows.
            ZStack(alignment: .bottomTrailing) {
                HabitRing(symbol: draft.symbol, segments: draft.ringSegments, filled: draft.ringFilled, symbolFont: symbolFont)
                    .frame(width: ringSize, height: ringSize)
                    .accessibilityHidden(true)
                accessory
            }

            HabitPreviewTitle(title: draft.resolvedTitle(), mark: draft.titleMark)
        }
        .frame(maxWidth: .infinity)
    }
}

extension HabitPreview where Accessory == EmptyView {
    init(draft: HabitDraft, ringSize: CGFloat, symbolFont: Font) {
        self.init(draft: draft, ringSize: ringSize, symbolFont: symbolFont) {
            EmptyView()
        }
    }
}

#Preview("Light") {
    HabitPreviewPreview()
}

#Preview("Dark") {
    HabitPreviewPreview()
        .preferredColorScheme(.dark)
}

private struct HabitPreviewPreview: View {
    var body: some View {
        var linked = HabitDraft(habit: nil, today: LogicalDay(.now))
        linked.linksHealth = true
        linked.symbol = "figure.walk"
        var avoided = HabitDraft(habit: nil, today: LogicalDay(.now))
        avoided.kind = .toAvoid
        avoided.title = "Caffè"
        avoided.limit = 2
        return VStack(spacing: SbuTheme.space8) {
            HabitPreview(draft: linked, ringSize: SbuTheme.space12 * 3, symbolFont: SbuTheme.largeTitle)
            HabitPreview(draft: avoided, ringSize: SbuTheme.space12 * 2, symbolFont: SbuTheme.title2)
        }
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentHabits)
    }
}
