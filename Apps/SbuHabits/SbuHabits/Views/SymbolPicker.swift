import SbuKit
import SwiftUI

/// A grid of the curated habit symbols; the chosen one sits on the accent.
struct SymbolPicker: View {
    @Binding var selection: String

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: SbuTheme.space12), spacing: SbuTheme.space2)], spacing: SbuTheme.space2) {
            ForEach(HabitSymbol.all) { symbol in
                SymbolButton(symbol: symbol, isSelected: symbol.id == selection) {
                    selection = symbol.id
                }
            }
        }
        .padding(.vertical, SbuTheme.space2)
    }
}

private struct SymbolButton: View {
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
    SymbolPickerPreview()
}

#Preview("Dark") {
    SymbolPickerPreview()
        .preferredColorScheme(.dark)
}

private struct SymbolPickerPreview: View {
    @State private var selection = "book"

    var body: some View {
        Form {
            SymbolPicker(selection: $selection)
        }
        .tint(SbuTheme.accentHabits)
    }
}
