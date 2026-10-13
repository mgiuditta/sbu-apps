import SbuKit
import SwiftUI

/// The corner mark of a tile: a filled bin in the accent when the item goes to the bin, an
/// empty ring when not. The shape, not the color alone, tells the two apart. Both sit on a disk
/// of paper drawn with the same symbol, so the disk never shows past the mark's edge.
struct SelectionMark: View {
    let isSelected: Bool

    var body: some View {
        ZStack {
            Image(systemName: "circle.fill")
                .foregroundStyle(SbuTheme.surface)
            if isSelected {
                Image(systemName: "trash.circle.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(SbuTheme.onAccent, .tint)
            } else {
                Image(systemName: "circle")
                    .foregroundStyle(SbuTheme.ink)
            }
        }
        .font(.title2)
        .fontWeight(.medium)
        .padding(SbuTheme.space1)
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
        .tint(SbuTheme.accentClean)
    }
}
