import SbuKit
import SwiftUI

/// A message that matches: who wrote it, when, and the words around the match.
struct SearchHitRow: View {
    let hit: SearchHit
    let owner: String?

    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space1) {
            HStack(alignment: .firstTextBaseline) {
                Group {
                    if hit.sender == owner {
                        Text("Tu")
                    } else {
                        Text(verbatim: hit.sender)
                    }
                }
                .font(SbuTheme.subheadline.weight(.semibold))
                .foregroundStyle(SbuTheme.ink)
                Spacer(minLength: SbuTheme.space2)
                Text(hit.sentAt, format: .dateTime.day().month(.abbreviated).year().hour().minute())
                    .font(SbuTheme.footnote)
                    .foregroundStyle(SbuTheme.inkMuted)
            }
            Text(SearchSnippet.attributed(hit.snippet))
                .font(SbuTheme.body)
                .foregroundStyle(SbuTheme.ink)
        }
        .padding(.vertical, SbuTheme.space1)
        .accessibilityElement(children: .combine)
    }
}

#Preview("Light") {
    List { SearchHitRow(hit: SearchHit(id: 1, sentAt: .now, sender: "Marco", snippet: "Porto io il \u{1}vino\u{2} stasera"), owner: "Giulia") }
}

#Preview("Dark") {
    List { SearchHitRow(hit: SearchHit(id: 1, sentAt: .now, sender: "Marco", snippet: "Porto io il \u{1}vino\u{2} stasera"), owner: "Giulia") }
        .preferredColorScheme(.dark)
}
