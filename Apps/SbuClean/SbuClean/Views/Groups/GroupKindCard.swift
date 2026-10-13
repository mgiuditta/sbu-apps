import SbuKit
import SwiftUI

/// One kind of group on the overview, as in the Originale: the best shot of the first group,
/// and next to it how many photos and how much space, which opens every group.
struct GroupKindCard: View {
    let model: CleanModel
    let kind: GroupKind

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private let heroSide: CGFloat = 140

    private var title: LocalizedStringKey {
        kind == .duplicate ? "Duplicati" : "Simili"
    }

    var body: some View {
        let groups = model.groups(of: kind)
        let selected = model.selectedGroupMembers(of: kind)
        VStack(alignment: .leading, spacing: SbuTheme.space2) {
            Text(title)
                .font(SbuTheme.title2)
                .foregroundStyle(SbuTheme.ink)
                .accessibilityAddTraits(.isHeader)

            if let first = groups.first {
                NavigationLink(value: Route.groups(kind)) {
                    let layout = dynamicTypeSize.isAccessibilitySize
                        ? AnyLayout(VStackLayout(alignment: .leading, spacing: SbuTheme.space3))
                        : AnyLayout(HStackLayout(spacing: SbuTheme.space3))
                    layout {
                        MediaThumbnail(id: first.best, side: heroSide)
                            .frame(width: heroSide, height: heroSide)
                            .overlay(alignment: .bottomLeading) {
                                BestBadge()
                            }
                            .clipShape(.rect(cornerRadius: SbuTheme.radiusMd))

                        VStack(alignment: .leading, spacing: SbuTheme.space1) {
                            Text("\(groups.reduce(0) { $0 + $1.members.count }) foto in \(groups.count) gruppi")
                                .font(SbuTheme.headline)
                                .foregroundStyle(SbuTheme.ink)
                            Text("\(selected.count) selezionate, \(model.bytes(of: selected).sizeText)")
                                .font(SbuTheme.subheadline)
                                .foregroundStyle(SbuTheme.inkMuted)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        Image(systemName: "chevron.forward")
                            .fontWeight(.medium)
                            .foregroundStyle(SbuTheme.inkMuted)
                            .accessibilityHidden(true)
                    }
                    .padding(SbuTheme.space3)
                    .background(SbuTheme.surfaceRaised, in: .rect(cornerRadius: SbuTheme.radiusLg))
                    .contentShape(.rect)
                }
                .buttonStyle(.plain)
                .accessibilityElement(children: .combine)
                .accessibilityIdentifier("card.\(kind.rawValue)")
            } else {
                Text(model.scan == .finished ? "Nessun gruppo trovato." : "Ancora nessun gruppo: l'analisi li trova man mano.")
                    .font(SbuTheme.subheadline)
                    .foregroundStyle(SbuTheme.inkMuted)
            }
        }
    }
}

#Preview("Light") {
    NavigationStack {
        GroupKindCard(model: .preview, kind: .duplicate)
            .padding()
    }
}

#Preview("Dark") {
    NavigationStack {
        GroupKindCard(model: .preview, kind: .similar)
            .padding()
    }
    .preferredColorScheme(.dark)
}
