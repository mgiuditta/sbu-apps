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
            Text("Scegli un'icona per chi la condivide")
                .font(SbuTheme.subheadline)
                .foregroundStyle(SbuTheme.inkMuted)
                .padding(.horizontal, SbuTheme.space4)

            ScrollView(.horizontal) {
                HStack(spacing: SbuTheme.space3) {
                    ForEach(options, id: \.self) { option in
                        Button {
                            select(option)
                        } label: {
                            OwnerBadge(emoji: option, side: SbuTheme.controlRound)
                                .overlay {
                                    if option == selection {
                                        Circle()
                                            .strokeBorder(.tint, lineWidth: SbuTheme.space1)
                                    }
                                }
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(label(of: option))
                        .accessibilityAddTraits(option == selection ? .isSelected : [])
                    }
                }
                .padding(.horizontal, SbuTheme.space4)
            }
            .scrollIndicators(.hidden)
        }
        .padding(.vertical, SbuTheme.space4)
        .background(SbuTheme.surfaceRaised, in: .rect(cornerRadius: SbuTheme.radiusLg))
    }

    private func label(of option: String?) -> Text {
        option.map { Text(verbatim: $0) } ?? Text("Persona")
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
