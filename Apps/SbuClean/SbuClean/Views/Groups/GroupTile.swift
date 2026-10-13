import SbuKit
import SwiftUI

/// A photo in a group: the best one carries "Migliore", a selected one the bin mark.
struct GroupTile: View {
    let id: String
    let position: Int
    let count: Int
    let isBest: Bool
    let isSelected: Bool
    let toggle: () -> Void

    var body: some View {
        Button(action: toggle) {
            MediaThumbnail(id: id)
                .overlay(alignment: .topTrailing) {
                    SelectionMark(isSelected: isSelected)
                }
                .overlay(alignment: .bottomLeading) {
                    if isBest {
                        BestBadge()
                    }
                }
                .clipShape(.rect(cornerRadius: SbuTheme.radiusMd))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isBest ? Text("Foto \(position) di \(count), la migliore") : Text("Foto \(position) di \(count)"))
        .accessibilityValue(isSelected ? Text("Da eliminare") : Text("Da tenere"))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview("Light") {
    GroupTile(id: "burst-0", position: 1, count: 3, isBest: true, isSelected: false) {}
        .frame(width: 120, height: 120)
        .tint(SbuTheme.accentClean)
}

#Preview("Dark") {
    GroupTile(id: "burst-1", position: 2, count: 3, isBest: false, isSelected: true) {}
        .frame(width: 120, height: 120)
        .tint(SbuTheme.accentClean)
        .preferredColorScheme(.dark)
}
