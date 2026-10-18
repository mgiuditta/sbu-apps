import SbuKit
import SwiftUI

/// One side of `ModeSwitch`: ink filled when chosen, ink text on paper when not.
struct ModeSwitchSegment: View {
    let title: LocalizedStringKey
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(SbuTheme.subheadline.weight(.semibold))
                .foregroundStyle(isSelected ? SbuTheme.paper : SbuTheme.ink)
                .padding(.horizontal, SbuTheme.space3)
                .frame(minHeight: SbuTheme.gridCell * 1.5)
                .background(isSelected ? SbuTheme.ink : .clear, in: .rect(cornerRadius: SbuTheme.radiusControl))
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview("Light") {
    HStack { ModeSwitchSegment(title: "Del giorno", isSelected: true) {}; ModeSwitchSegment(title: "Libera", isSelected: false) {} }
        .padding(SbuTheme.space4)
}

#Preview("Dark") {
    HStack { ModeSwitchSegment(title: "Del giorno", isSelected: false) {}; ModeSwitchSegment(title: "Libera", isSelected: true) {} }
        .padding(SbuTheme.space4)
        .preferredColorScheme(.dark)
}
