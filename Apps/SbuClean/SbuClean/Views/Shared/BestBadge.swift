import SbuKit
import SwiftUI

/// The word on the suggested photo of a group.
struct BestBadge: View {
    var body: some View {
        Text("Migliore")
            .font(SbuTheme.caption)
            .foregroundStyle(SbuTheme.ink)
            .padding(.horizontal, SbuTheme.space2)
            .padding(.vertical, SbuTheme.space1)
            .background(SbuTheme.surface, in: .rect(cornerRadius: SbuTheme.radiusSm))
            .padding(SbuTheme.space1)
            // A tag on a thumbnail: it stays a tag. The tile's VoiceOver label says it.
            .dynamicTypeSize(...DynamicTypeSize.xxLarge)
            .accessibilityHidden(true)
    }
}

#Preview("Light") {
    BestBadge()
        .padding()
        .background(SbuTheme.surfaceSunken)
}

#Preview("Dark") {
    BestBadge()
        .padding()
        .background(SbuTheme.surfaceSunken)
        .preferredColorScheme(.dark)
}
