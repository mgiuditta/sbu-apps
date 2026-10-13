import SbuKit
import SwiftUI

/// The hairline between two home rows, starting under the row's title as in an iOS list.
struct HomeRowDivider: View {
    /// The row's icon tile and the gap after it, as `SbuListRow` draws them.
    @ScaledMetric(relativeTo: .headline) private var iconSide: CGFloat = 40

    var body: some View {
        Rectangle()
            .fill(SbuTheme.line)
            .frame(height: SbuTheme.hairline)
            .padding(.leading, SbuTheme.space4 + iconSide + SbuTheme.space3)
            .accessibilityHidden(true)
    }
}

#Preview("Light") {
    HomeRowDivider()
        .padding()
}

#Preview("Dark") {
    HomeRowDivider()
        .padding()
        .preferredColorScheme(.dark)
}
