import SbuKit
import SwiftUI

/// The home's two pills: the swipe timeline and the bin. Side by side, or one above the other
/// when the text is too large for one line.
struct HomePills: View {
    let binCount: Int

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: SbuTheme.space2) {
                pills
            }
            VStack(spacing: SbuTheme.space2) {
                pills
            }
        }
    }

    @ViewBuilder private var pills: some View {
        NavigationLink(value: Route.months) {
            Text("Scorri le foto")
                .fixedSize(horizontal: false, vertical: true)
        }
        .buttonStyle(SbuFieldPillStyle())
        .accessibilityIdentifier("pill.months")
        NavigationLink(value: Route.bin) {
            Text("Cestino: \(binCount)")
                .fixedSize(horizontal: false, vertical: true)
        }
        .buttonStyle(SbuFieldPillStyle())
        .accessibilityIdentifier("pill.bin")
    }
}

#Preview("Light") {
    NavigationStack {
        HomePills(binCount: 4)
    }
    .environment(\.sbuAccent, .clean)
}

#Preview("Dark") {
    NavigationStack {
        HomePills(binCount: 0)
    }
    .environment(\.sbuAccent, .clean)
    .preferredColorScheme(.dark)
}
