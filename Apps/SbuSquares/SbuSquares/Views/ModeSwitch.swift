import SbuKit
import SwiftUI

/// Del giorno or Libera, drawn in ink on the paper beside the title: the chosen one filled,
/// as the square controls of the Quaderno, not a glass control on the glass bar.
struct ModeSwitch: View {
    @Binding var mode: GameMode

    var body: some View {
        HStack(spacing: 0) {
            ModeSwitchSegment(title: "Del giorno", isSelected: mode == .daily) { mode = .daily }
            ModeSwitchSegment(title: "Libera", isSelected: mode == .free) { mode = .free }
        }
        .padding(SbuTheme.space1 / 2)
        .overlay {
            RoundedRectangle(cornerRadius: SbuTheme.radiusCard)
                .strokeBorder(SbuTheme.ink, lineWidth: SbuTheme.hairline)
        }
        .fixedSize()
        .sbuAffectsFigure(mode)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Partita")
    }
}

#Preview("Light") {
    @Previewable @State var mode = GameMode.daily
    ModeSwitch(mode: $mode).padding(SbuTheme.space4).sbuPaper()
}

#Preview("Dark") {
    @Previewable @State var mode = GameMode.free
    ModeSwitch(mode: $mode).padding(SbuTheme.space4).sbuPaper().preferredColorScheme(.dark)
}
