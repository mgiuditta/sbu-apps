import SbuKit
import SwiftUI

/// The corner mark of a tile, drawn over the photo like `SbuCheckboxStyle`'s box: a square filled
/// with `ink` and a `paper` check when the item is chosen, an empty `paper` square with an `ink`
/// border when not. The fill and the check, not a color, tell the two apart.
struct SelectionMark: View {
    let isSelected: Bool

    @ScaledMetric(relativeTo: .title2) private var side = SbuTheme.checkbox

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: SbuTheme.radiusCheckbox)
        // Opaque either way, so the mark reads on any photo.
        shape
            .fill(isSelected ? SbuTheme.ink : SbuTheme.paper)
            .overlay {
                shape.strokeBorder(SbuTheme.ink, lineWidth: SbuTheme.checkboxStroke)
            }
            .overlay {
                if isSelected {
                    Image(systemName: "checkmark")
                        .resizable()
                        .scaledToFit()
                        .fontWeight(.bold)
                        .foregroundStyle(SbuTheme.paper)
                        .padding(SbuTheme.space1 + SbuTheme.hairline)
                }
            }
            .frame(width: side, height: side)
            .padding(SbuTheme.space2)
            .accessibilityHidden(true)
    }
}

#Preview("Light") {
    SelectionMarkPreview()
}

#Preview("Dark") {
    SelectionMarkPreview()
        .preferredColorScheme(.dark)
}

private struct SelectionMarkPreview: View {
    var body: some View {
        HStack {
            SelectionMark(isSelected: true)
            SelectionMark(isSelected: false)
        }
        .padding()
        .background(SbuTheme.surfaceSunken)
    }
}
