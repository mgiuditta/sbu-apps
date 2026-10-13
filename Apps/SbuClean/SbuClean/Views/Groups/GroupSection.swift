import SbuKit
import SwiftUI

/// One group: its size, a button for all the copies, and the photos in a row, best first.
struct GroupSection: View {
    let model: CleanModel
    let group: PhotoGroup

    @ScaledMetric(relativeTo: .body) private var tileSide: CGFloat = 120

    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space2) {
            HStack(alignment: .firstTextBaseline) {
                Text("\(group.members.count) foto · \(model.bytes(of: group.members).formatted(.byteCount(style: .file)))")
                    .font(SbuTheme.subheadline)
                    .foregroundStyle(SbuTheme.inkMuted)
                Spacer(minLength: SbuTheme.space2)
                Button(model.groupSelection.areAllCopiesSelected(in: group) ? "Tieni tutte" : "Tieni solo la migliore", action: toggleAll)
                    .font(SbuTheme.subheadline)
                    .frame(minHeight: 44)
                    .contentShape(.rect)
            }

            ScrollView(.horizontal) {
                HStack(spacing: SbuTheme.space2) {
                    ForEach(Array(group.members.enumerated()), id: \.element) { index, id in
                        GroupTile(
                            id: id,
                            position: index + 1,
                            count: group.members.count,
                            isBest: id == group.best,
                            isSelected: model.groupSelection.isSelected(id, in: group)
                        ) {
                            model.groupSelection.toggle(id, in: group)
                        }
                        .frame(width: tileSide, height: tileSide)
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
    }

    private func toggleAll() {
        model.groupSelection.toggleAllCopies(in: group)
    }
}

#Preview("Light") {
    GroupSection(model: .preview, group: PhotoGroup(kind: .duplicate, members: ["duplicate-b0", "duplicate-b1", "duplicate-b2"]))
        .padding()
        .tint(SbuTheme.accentClean)
}

#Preview("Dark") {
    GroupSection(model: .preview, group: PhotoGroup(kind: .similar, members: ["burst-0", "burst-1"]))
        .padding()
        .tint(SbuTheme.accentClean)
        .preferredColorScheme(.dark)
}
