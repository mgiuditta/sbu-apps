import SbuKit
import SwiftUI

/// One place of the tool screen's grid, as Streaks draws it: a ring as large as the place
/// allows, with its caption under it.
///
/// The caption's room is as tall as the tallest caption of its page, so the rings of a page stay
/// the same size whatever their titles, without reserving lines no one on the page needs.
struct RingSlot<Ring: View>: View {
    /// The ring's largest side: `.infinity` on a page, where the place sets it.
    let maxRingSide: CGFloat
    let caption: SlotCaption
    /// The captions of the whole page, this one included; empty in the single column.
    var pageCaptions: [SlotCaption] = []
    @ViewBuilder let ring: Ring

    var body: some View {
        VStack(spacing: SbuTheme.space2) {
            ring
                .aspectRatio(1, contentMode: .fit)
                .anchorPreference(key: RingBoundsKey.self, value: .bounds) { $0 }
                .frame(maxWidth: maxRingSide, maxHeight: maxRingSide)

            ZStack(alignment: .top) {
                // Invisible, they only make the room as tall as the row's tallest caption.
                ForEach(pageCaptions.indices, id: \.self) { index in
                    pageCaptions[index]
                        .hidden()
                }
                caption
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview("Light") {
    RingSlotPreview()
}

#Preview("Dark") {
    RingSlotPreview()
        .preferredColorScheme(.dark)
}

private struct RingSlotPreview: View {
    private let captions = [
        SlotCaption(title: Text(verbatim: "Leggere")),
        SlotCaption(title: Text(verbatim: "Portare a spasso il cane"), detail: Text(verbatim: "10 min")),
    ]

    var body: some View {
        HStack(spacing: SbuTheme.space3) {
            RingSlot(maxRingSide: .infinity, caption: captions[0], pageCaptions: captions) {
                HabitRing(symbol: "book", segments: 1, filled: 1)
            }
            RingSlot(maxRingSide: .infinity, caption: captions[1], pageCaptions: captions) {
                HabitRing(symbol: "dog", segments: 1, filled: 0)
            }
        }
        .frame(height: SbuTheme.space12 * 4)
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentHabits)
    }
}
