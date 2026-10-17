import SbuKit
import SwiftUI

/// A grid of the category symbols to pick one from, each named after the built-in category it stands for.
struct SymbolPicker: View {
    @Binding var symbol: String

    @ScaledMetric(relativeTo: .body) private var side: CGFloat = 44

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: side), spacing: SbuTheme.space2)], spacing: SbuTheme.space2) {
            ForEach(BuiltInCategory.allCases, id: \.self) { category in
                Button {
                    symbol = category.symbol
                } label: {
                    Image(systemName: category.symbol)
                        .fontWeight(.medium)
                        .imageScale(.medium)
                        .frame(width: side, height: side)
                        .foregroundStyle(symbol == category.symbol ? SbuTheme.paper : SbuTheme.ink)
                        .background(symbol == category.symbol ? SbuTheme.ink : SbuTheme.surfaceSunken, in: .rect(cornerRadius: SbuTheme.radiusCard))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(category.name)
                .accessibilityAddTraits(symbol == category.symbol ? .isSelected : [])
            }
        }
        .padding(.vertical, SbuTheme.space2)
    }
}
