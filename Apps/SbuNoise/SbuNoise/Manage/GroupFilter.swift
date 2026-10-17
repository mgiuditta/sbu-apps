import SbuKit
import SwiftUI

/// The filter of Gestisci: all the groups, or one.
struct GroupFilter: View {
    @Binding var selection: SoundCategory?

    var body: some View {
        Menu {
            Picker("Gruppo", selection: $selection) {
                Text("Tutti i gruppi").tag(SoundCategory?.none)
                ForEach(SoundCategory.allCases) { group in
                    Label { Text(group.title) } icon: { Image(systemName: group.systemImage) }
                        .tag(SoundCategory?.some(group))
                }
            }
        } label: {
            Label("Filtra", systemImage: selection == nil ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill")
        }
        .accessibilityValue(selection.map { Text($0.title) } ?? Text("Tutti i gruppi"))
    }
}

#Preview("Light") {
    GroupFilter(selection: .constant(nil))
}

#Preview("Dark") {
    GroupFilter(selection: .constant(.rain))
        .preferredColorScheme(.dark)
}
