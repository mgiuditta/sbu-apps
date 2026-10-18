import SbuKit
import SwiftUI

/// Del giorno or Libera: the two games, side by side with the title.
struct ModePicker: View {
    @Binding var mode: GameMode

    var body: some View {
        Picker("Partita", selection: $mode) {
            Text("Del giorno").tag(GameMode.daily)
            Text("Libera").tag(GameMode.free)
        }
        .pickerStyle(.segmented)
        .fixedSize()
    }
}

#Preview("Light") {
    @Previewable @State var mode = GameMode.daily
    ModePicker(mode: $mode).padding(SbuTheme.space4)
}

#Preview("Dark") {
    @Previewable @State var mode = GameMode.free
    ModePicker(mode: $mode).padding(SbuTheme.space4).preferredColorScheme(.dark)
}
