import SbuKit
import SwiftUI

/// What the player shows in a category with nothing in it yet: the empty figure, what to do, and
/// for the mixes the button that makes the first one.
struct EmptyCategoryView: View {
    let category: PlayerCategory
    let createMix: () -> Void

    var body: some View {
        Group {
            if category == .mixes {
                SbuEmpty(sentence: "Metti insieme fino a cinque suoni e scegli dove sentirli.") {
                    Button("Crea un mix", action: createMix)
                }
            } else {
                SbuEmpty(sentence: "Tocca il cuore sotto un suono o un mix per ritrovarlo qui.")
            }
        }
        .padding(.horizontal, SbuTheme.space4)
        .padding(.top, SbuTheme.gridCell)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .sbuPaper(grid: true)
    }
}

#Preview("Light") {
    EmptyCategoryView(category: .favorites) {}
}

#Preview("Dark") {
    EmptyCategoryView(category: .mixes) {}
        .preferredColorScheme(.dark)
}
