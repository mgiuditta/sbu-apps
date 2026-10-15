import SbuKit
import SwiftUI

/// After a re-import: how many messages the newer export added.
struct MergeNoticeSection: View {
    let added: Int

    var body: some View {
        Section {
            Label {
                Group {
                    if added == 0 {
                        Text("Nessun messaggio nuovo: la chat era già aggiornata")
                    } else {
                        Text("Aggiunti \(added) messaggi nuovi")
                    }
                }
                .font(SbuTheme.body)
                .foregroundStyle(SbuTheme.ink)
            } icon: {
                Image(systemName: "checkmark.circle")
                    .fontWeight(.medium)
                    .foregroundStyle(SbuTheme.success)
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
