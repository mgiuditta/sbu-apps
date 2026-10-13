import SbuKit
import SwiftUI

/// One city in the place sheet, with a checkmark when it is the place chosen.
struct CityRow: View {
    let city: City
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: SbuTheme.space2) {
                Text(verbatim: city.name())
                    .frame(maxWidth: .infinity, alignment: .leading)

                if isSelected {
                    Image(systemName: "checkmark")
                        .fontWeight(.medium)
                        .imageScale(.medium)
                        .foregroundStyle(.tint)
                        .accessibilityHidden(true)
                }
            }
        }
        .tint(SbuTheme.ink)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview("Light") {
    CityRowPreview()
}

#Preview("Dark") {
    CityRowPreview()
        .preferredColorScheme(.dark)
}

private struct CityRowPreview: View {
    var body: some View {
        List {
            ForEach(CityCatalog.all.prefix(3)) { city in
                CityRow(city: city, isSelected: city.id == "rome") {}
            }
        }
        .tint(SbuTheme.accentMoon)
    }
}
