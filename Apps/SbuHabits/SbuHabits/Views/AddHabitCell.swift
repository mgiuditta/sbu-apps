import SbuKit
import SwiftUI

/// Aggiungi as the grid's last place, as Streaks has it: an empty ring with a plus, the word
/// under it. It opens Aggiungi abitudine.
struct AddHabitCell: View {
    /// The ring's largest side: `.infinity` on a page of the grid, where the place sets it.
    var maxRingSide = CGFloat.infinity
    /// The captions of the cell's page in the grid, so the rings of a page stay even.
    var pageCaptions: [SlotCaption] = []
    let add: () -> Void

    static let caption = SlotCaption(title: Text("Aggiungi"))

    var body: some View {
        Button(action: add) {
            RingSlot(maxRingSide: maxRingSide, caption: Self.caption, pageCaptions: pageCaptions) {
                ZStack {
                    Circle()
                        .stroke(SbuTheme.line, lineWidth: SbuTheme.space2)
                    Image(systemName: "plus")
                        .font(SbuTheme.title2)
                        .fontWeight(.medium)
                        .imageScale(.medium)
                        .foregroundStyle(SbuTheme.ink)
                }
                // As HabitRing: the stroke stays inside the place.
                .padding(SbuTheme.space1)
            }
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        // The word as written, not in the uppercase it shows.
        .accessibilityLabel(Text("Aggiungi"))
    }
}

#Preview("Light") {
    AddHabitCell {}
        .frame(height: SbuTheme.space12 * 4)
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentHabits)
}

#Preview("Dark") {
    AddHabitCell {}
        .frame(height: SbuTheme.space12 * 4)
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentHabits)
        .preferredColorScheme(.dark)
}
