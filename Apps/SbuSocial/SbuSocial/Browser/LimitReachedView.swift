import SbuKit
import SwiftUI

/// In place of the page once the Limite di tempo is reached: the social stays closed until tomorrow.
struct LimitReachedView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space4) {
            Text("Basta per oggi.")
                .font(SbuTheme.title2)
                .foregroundStyle(SbuTheme.ink)
            Text("Hai raggiunto il tuo limite di tempo. I social si riaprono domani.")
                .font(SbuTheme.body)
                .foregroundStyle(SbuTheme.inkMuted)
        }
        .padding(SbuTheme.space4)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .sbuPaper(grid: true)
    }
}

#Preview("Light") {
    LimitReachedView()
}

#Preview("Dark") {
    LimitReachedView()
        .preferredColorScheme(.dark)
}
