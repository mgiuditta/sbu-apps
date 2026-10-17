import SbuKit
import SwiftUI

/// A row you pick, one among several: the row marker fills when picked.
struct ChoiceRow: View {
    let title: Text
    let isSelected: Bool
    let select: () -> Void

    var body: some View {
        Button(action: select) {
            HStack(spacing: SbuTheme.space3) {
                SbuRowMark(filled: isSelected)
                title
                    .font(SbuTheme.body)
                    .foregroundStyle(SbuTheme.ink)
                Spacer(minLength: SbuTheme.space2)
            }
            .contentShape(.rect)
        }
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview("Light") {
    List {
        ChoiceRow(title: Text(verbatim: "Giulia"), isSelected: true) {}
        ChoiceRow(title: Text(verbatim: "Marco"), isSelected: false) {}
    }
}

#Preview("Dark") {
    List {
        ChoiceRow(title: Text(verbatim: "Giulia"), isSelected: true) {}
        ChoiceRow(title: Text(verbatim: "Marco"), isSelected: false) {}
    }
    .preferredColorScheme(.dark)
}
