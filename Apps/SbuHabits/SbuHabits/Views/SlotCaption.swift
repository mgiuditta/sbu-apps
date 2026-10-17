import SbuKit
import SwiftUI

/// The words under a ring of the grid: the title in uppercase, after a symbol for its kind and
/// one for today's note when there are, then an optional muted line such as an Abitudine a
/// tempo's length.
struct SlotCaption: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let title: Text
    /// A heart when Salute marks the habit, ⊘ for an Abitudine da evitare.
    var kindSymbol: String?
    /// Today has a Nota del giorno: a small note symbol, muted.
    var hasNote = false
    var detail: Text?
    /// Lines the title may take; `nil` for two, or four at accessibility sizes. A widget keeps one.
    var maxLines: Int?
    /// The text style: smaller in the widget's grid, where four rings share a row.
    var font = SbuTheme.footnote

    var body: some View {
        VStack(spacing: SbuTheme.space1) {
            HStack(alignment: .firstTextBaseline, spacing: SbuTheme.space1) {
                if let kindSymbol {
                    Image(systemName: kindSymbol)
                }
                if hasNote {
                    Image(systemName: "note.text")
                        .foregroundStyle(SbuTheme.inkMuted)
                }
                title
                    .textCase(.uppercase)
                    .multilineTextAlignment(.center)
                    .lineLimit(maxLines ?? (dynamicTypeSize.isAccessibilitySize ? 4 : 2))
            }
            .font(font)
            .fontWeight(.semibold)
            .imageScale(.medium)
            .foregroundStyle(SbuTheme.ink)

            if let detail {
                detail
                    .font(font)
                    .monospacedDigit()
                    .foregroundStyle(SbuTheme.inkMuted)
            }
        }
    }
}

#Preview("Light") {
    SlotCaption(title: Text(verbatim: "Lavarsi i denti"), kindSymbol: "heart.fill", hasNote: true, detail: Text(verbatim: "3 min"))
        .padding(SbuTheme.space4)
        .background(SbuTheme.paper)
}

#Preview("Dark") {
    SlotCaption(title: Text(verbatim: "Lavarsi i denti"), kindSymbol: "heart.fill", hasNote: true, detail: Text(verbatim: "3 min"))
        .padding(SbuTheme.space4)
        .background(SbuTheme.paper)
        .preferredColorScheme(.dark)
}
