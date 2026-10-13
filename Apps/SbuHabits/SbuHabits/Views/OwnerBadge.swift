import SbuKit
import SwiftUI

/// The round badge of an Abitudine condivisa received: the emoji picked for its owner, or the
/// person symbol. A picture: the habit's own VoiceOver text says it is shared.
struct OwnerBadge: View {
    let emoji: String?
    var side = SbuTheme.controlRoundSm

    /// The small badge of a small ring takes a smaller text style.
    private var font: Font {
        side < SbuTheme.controlRoundSm ? SbuTheme.footnote : SbuTheme.body
    }

    var body: some View {
        Group {
            if let emoji {
                Text(verbatim: emoji)
                    .font(font)
            } else {
                Image(systemName: OwnerEmoji.personSymbol)
                    .font(font)
                    .fontWeight(.medium)
                    .imageScale(.medium)
                    .foregroundStyle(SbuTheme.inkMuted)
            }
        }
        // A picture in a circle of fixed side, hidden from VoiceOver: it keeps the default
        // size, or at larger text the emoji would touch the circle's edge.
        .dynamicTypeSize(.large)
        .frame(width: side, height: side)
        .background(SbuTheme.surfaceRaised, in: .circle)
        .accessibilityHidden(true)
    }
}

#Preview("Light") {
    HStack(spacing: SbuTheme.space3) {
        OwnerBadge(emoji: nil)
        OwnerBadge(emoji: "😎")
        OwnerBadge(emoji: "😎", side: SbuTheme.space8)
    }
    .padding(SbuTheme.space4)
    .background(SbuTheme.surface)
}

#Preview("Dark") {
    HStack(spacing: SbuTheme.space3) {
        OwnerBadge(emoji: nil)
        OwnerBadge(emoji: "😎")
    }
    .padding(SbuTheme.space4)
    .background(SbuTheme.surface)
    .preferredColorScheme(.dark)
}
