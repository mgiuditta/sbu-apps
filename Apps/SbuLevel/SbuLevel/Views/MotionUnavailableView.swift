import SbuKit
import SwiftUI

/// The tool screen without a motion sensor: the title, and one sentence on paper closed by a
/// waiting full stop. No figure and no Calibra, which would promise a reading there isn't.
struct MotionUnavailableView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space8) {
            SbuScreenTitle("Livella", cartiglio: ["Sbu", String(localized: "Livella")].joined(separator: " · "))

            HStack(alignment: .lastTextBaseline, spacing: 0) {
                Text("Sensore di movimento non disponibile")
                    .font(SbuTheme.title2)
                    .foregroundStyle(SbuTheme.ink)
                    .fixedSize(horizontal: false, vertical: true)
                SbuFullStop(.waiting, size: .inline)
            }
        }
        .padding(SbuTheme.space4)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .sbuPaper(grid: true)
    }
}

#Preview("Light") {
    MotionUnavailableView()
}

#Preview("Dark") {
    MotionUnavailableView()
        .preferredColorScheme(.dark)
}
