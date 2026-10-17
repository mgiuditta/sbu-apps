import SbuKit
import SwiftUI

/// One symbol of the picker, on the accent when it is the chosen one.
struct SymbolButton: View {
    let symbol: HabitSymbol
    let isSelected: Bool
    let select: () -> Void

    var body: some View {
        Button(action: select) {
            Label {
                Text(symbol.name)
            } icon: {
                Image(systemName: symbol.id)
                    .fontWeight(.medium)
                    .imageScale(.medium)
            }
            .labelStyle(.iconOnly)
            .font(SbuTheme.title2)
            .frame(maxWidth: .infinity, minHeight: SbuTheme.space12) // at least the 44pt tap target
            .foregroundStyle(isSelected ? SbuTheme.onAccent : SbuTheme.ink)
            .background(isSelected ? AnyShapeStyle(.tint) : AnyShapeStyle(.clear), in: .rect(cornerRadius: SbuTheme.radiusMd))
            .contentShape(.rect(cornerRadius: SbuTheme.radiusMd))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview("Light") {
    SymbolButtonPreview()
}

#Preview("Dark") {
    SymbolButtonPreview()
        .preferredColorScheme(.dark)
}

private struct SymbolButtonPreview: View {
    var body: some View {
        HStack {
            SymbolButton(symbol: HabitSymbol.all[0], isSelected: true) {}
            SymbolButton(symbol: HabitSymbol.all[1], isSelected: false) {}
        }
        .padding()
        .background(SbuTheme.paper)
        .tint(SbuTheme.ink)
    }
}
