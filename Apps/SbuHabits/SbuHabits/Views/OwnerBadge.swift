import SbuKit
import SwiftUI

/// The round badge of an Abitudine condivisa received: the emoji picked for its owner, or the
/// person symbol. A picture: the habit's own VoiceOver text says it is shared.
struct OwnerBadge: View {
    let emoji: String?
    var side = SbuTheme.controlRoundSm

    var body: some View {
        Group {
            if let emoji {
                Text(verbatim: emoji)
                    .font(SbuTheme.body)
            } else {
                Image(systemName: OwnerEmoji.personSymbol)
                    .font(SbuTheme.body)
                    .fontWeight(.medium)
                    .imageScale(.medium)
                    .foregroundStyle(SbuTheme.inkMuted)
            }
        }
        // The side is fixed: past the largest text sizes the symbol would spill out.
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
        .frame(width: side, height: side)
        .background(SbuTheme.surfaceRaised, in: .circle)
        .accessibilityHidden(true)
    }
}

#Preview("Light") {
    HStack(spacing: SbuTheme.space3) {
        OwnerBadge(emoji: nil)
        OwnerBadge(emoji: "😎")
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
