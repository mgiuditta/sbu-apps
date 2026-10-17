import SbuKit
import SwiftUI

/// Settings → what the app is not: it reminds you of what you wrote, it never advises on doses,
/// and the data stays on this iPhone.
struct CareNoteSection: View {
    var body: some View {
        Section {
            Label {
                Text("Sbu Meds ti ricorda quello che hai scritto tu. Non dà consigli su farmaci, dosi o interazioni: per quelli chiedi al medico o al farmacista.")
                    .font(SbuTheme.subheadline)
                    .foregroundStyle(SbuTheme.ink)
            } icon: {
                Image(systemName: "stethoscope")
                    .fontWeight(.medium)
                    .imageScale(.medium)
                    .foregroundStyle(SbuTheme.inkMuted)
            }
            .accessibilityIdentifier("careNote")
            Label {
                Text("Farmaci, persone e storico restano su questo iPhone: nessun server, nessun account. Se elimini l'app, li elimini con lei.")
                    .font(SbuTheme.subheadline)
                    .foregroundStyle(SbuTheme.ink)
            } icon: {
                Image(systemName: "lock")
                    .fontWeight(.medium)
                    .imageScale(.medium)
                    .foregroundStyle(SbuTheme.inkMuted)
            }
        } header: {
            Text("Da sapere")
        }
        .listRowBackground(SbuTheme.surfaceRaised)
    }
}

#Preview("Light") {
    Form {
        CareNoteSection()
    }
    .scrollContentBackground(.hidden)
    .background(SbuTheme.paper)
}

#Preview("Dark") {
    Form {
        CareNoteSection()
    }
    .scrollContentBackground(.hidden)
    .background(SbuTheme.paper)
    .preferredColorScheme(.dark)
}
