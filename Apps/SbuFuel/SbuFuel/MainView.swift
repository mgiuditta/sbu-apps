import SbuKit
import SwiftUI

/// The one screen of the app: its central figure in an `SbuStat`.
struct MainView: View {
    var body: some View {
        VStack(spacing: SbuTheme.space6) {
            SbuStat("Valore", value: 0, format: .number)
            Spacer()
        }
        .padding(SbuTheme.space4)
    }
}

#Preview("Light") {
    MainView()
}

#Preview("Dark") {
    MainView()
        .preferredColorScheme(.dark)
}
