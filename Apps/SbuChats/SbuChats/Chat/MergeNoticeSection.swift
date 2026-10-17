import SbuKit
import SwiftUI

/// After a re-import: how many messages the newer export added, marked like a done row.
struct MergeNoticeSection: View {
    let added: Int

    var body: some View {
        Section {
            HStack(spacing: SbuTheme.space3) {
                SbuRowMark(filled: true)
                Group {
                    if added == 0 {
                        Text("Nessun messaggio nuovo: la chat era già aggiornata")
                    } else {
                        Text("Aggiunti \(added) messaggi nuovi")
                    }
                }
                .font(SbuTheme.body)
                .foregroundStyle(SbuTheme.ink)
            }
        }
        .listRowBackground(SbuTheme.surfaceRaised)
    }
}

#Preview("Light") {
    List { MergeNoticeSection(added: 312) }
}

#Preview("Dark") {
    List { MergeNoticeSection(added: 0) }
        .preferredColorScheme(.dark)
}
