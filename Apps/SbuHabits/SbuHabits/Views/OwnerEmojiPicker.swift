import SbuKit
import SwiftUI

/// The row of icons for the owner of an Abitudine condivisa, as Streaks offers it: the person
/// symbol, then system emoji, in a row that scrolls sideways. The one picked has a ring in the
/// accent and reads as selected.
struct OwnerEmojiPicker: View {
    /// The emoji picked, `nil` for the person symbol.
    let selection: String?
    let select: (String?) -> Void

    private var options: [String?] {
        [nil] + OwnerEmoji.choices.map(Optional.some)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space3) {
            Text("Scegli un'emoji per chi la condivide")
                .font(SbuTheme.subheadline)
                .foregroundStyle(SbuTheme.inkMuted)

            ScrollView(.horizontal) {
                HStack(spacing: SbuTheme.space3) {
                    ForEach(options, id: \.self) { option in
                        OptionButton(option: option, isSelected: option == selection) {
                            select(option)
                        }
                    }
                }
                .padding(.horizontal, SbuTheme.space4)
                // Room for the ring of the one picked.
                .padding(.vertical, SbuTheme.space1)
            }
            .scrollIndicators(.hidden)
            // Edge to edge under the finger; the first icon lines up with the screen's margin.
            .padding(.horizontal, -SbuTheme.space4)
        }
    }
}

/// One icon of the row: the emoji, or the person symbol, on raised paper.
private struct OptionButton: View {
    let option: String?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label {
                if let option {
                    Text(verbatim: option)
                } else {
                    Text("Persona")
                }
            } icon: {
                if let option {
                    Text(verbatim: option)
                } else {
                    Image(systemName: OwnerEmoji.personSymbol)
                        .foregroundStyle(SbuTheme.inkMuted)
                }
            }
        }
        .labelStyle(.iconOnly)
        .buttonStyle(RoundButtonStyle(side: SbuTheme.controlRound))
        .overlay {
            if isSelected {
                Circle()
                    .strokeBorder(.tint, lineWidth: SbuTheme.space1)
                    .accessibilityHidden(true)
            }
        }
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview("Light") {
    OwnerEmojiPicker(selection: "😎") { _ in }
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentHabits)
}

#Preview("Dark") {
    OwnerEmojiPicker(selection: nil) { _ in }
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentHabits)
        .preferredColorScheme(.dark)
}
