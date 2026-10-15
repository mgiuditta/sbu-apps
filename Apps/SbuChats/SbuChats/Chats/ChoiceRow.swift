import SbuKit
import SwiftUI

/// A row you pick, with a check mark when picked.
struct ChoiceRow: View {
    let title: Text
    let isSelected: Bool
    let select: () -> Void

    var body: some View {
        Button(action: select) {
            HStack {
                title
                    .font(SbuTheme.body)
                    .foregroundStyle(SbuTheme.ink)
                Spacer(minLength: SbuTheme.space2)
                if isSelected {
                    Image(systemName: "checkmark")
                        .fontWeight(.medium)
                        .foregroundStyle(.tint)
                        .accessibilityHidden(true)
                }
            }
            .contentShape(.rect)
        }
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview("Light") {
    List { ChoiceRow(title: Text(verbatim: "Giulia"), isSelected: true) {} }
}

#Preview("Dark") {
    List { ChoiceRow(title: Text(verbatim: "Giulia"), isSelected: true) {} }
        .preferredColorScheme(.dark)
}
