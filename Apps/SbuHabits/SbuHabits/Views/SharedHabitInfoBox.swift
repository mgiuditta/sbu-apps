import SbuKit
import SwiftUI

/// On the screen of an Abitudine condivisa received: whose it is and what can be done with it.
struct SharedHabitInfoBox: View {
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: SbuTheme.space3) {
            Image(systemName: OwnerEmoji.personSymbol)
                .fontWeight(.medium)
                .imageScale(.medium)
                .foregroundStyle(SbuTheme.inkMuted)
                .accessibilityHidden(true)
            Text("Chi la condivide la segna. Tu vedi i progressi e le statistiche.")
                .foregroundStyle(SbuTheme.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .font(SbuTheme.subheadline)
        .padding(SbuTheme.space4)
        .background(SbuTheme.surfaceRaised, in: .rect(cornerRadius: SbuTheme.radiusLg))
    }
}

#Preview("Light") {
    SharedHabitInfoBox()
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
}

#Preview("Dark") {
    SharedHabitInfoBox()
        .padding(SbuTheme.space4)
        .background(SbuTheme.surface)
        .preferredColorScheme(.dark)
}
