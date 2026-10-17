import SbuKit
import SwiftUI

/// How to export a chat from WhatsApp on iPhone and Android, what an export holds, and the trademark note.
struct ExportHelpView: View {
    var body: some View {
        List {
            Section {
                HelpStep(number: 1, text: "Apri la chat in WhatsApp e tocca il suo nome in alto.")
                HelpStep(number: 2, text: "Scorri in fondo e tocca Esporta chat.")
                HelpStep(number: 3, text: "Scegli Senza media: è più veloce e i numeri sono gli stessi.")
                HelpStep(number: 4, text: "Nel foglio di condivisione tocca Sbu Chats. Se non c'è, tocca Salva su File e poi, in Sbu Chats, Importa una chat.")
            } header: {
                Text("Da iPhone")
            }

            Section {
                HelpStep(number: 1, text: "Apri la chat in WhatsApp, tocca ⋮, poi Altro e infine Esporta chat.")
                HelpStep(number: 2, text: "Scegli Senza media.")
                HelpStep(number: 3, text: "Manda il file all'iPhone, per esempio per email o con un servizio cloud, e aprilo con Sbu Chats.")
            } header: {
                Text("Da Android")
            }

            Section {
                Text("Un export contiene al massimo circa 40.000 messaggi senza media o 10.000 con i media: i più recenti. Per tenere la storia, esporta di nuovo la stessa chat più avanti: Sbu Chats la riconosce e aggiunge solo i messaggi nuovi.")
                    .font(SbuTheme.body)
                    .foregroundStyle(SbuTheme.ink)
                    .listRowBackground(SbuTheme.surfaceRaised)
            } header: {
                Text("Quanti messaggi")
            }

            Section {
                Text("La chat resta su questo iPhone. Sbu Chats non si collega a internet, non usa iCloud e non legge altro che i file che gli dai. Puoi eliminare una chat in ogni momento.")
                    .font(SbuTheme.body)
                    .foregroundStyle(SbuTheme.ink)
                    .listRowBackground(SbuTheme.surfaceRaised)
            } header: {
                Text("Privacy")
            } footer: {
                Text("WhatsApp è un marchio di Meta Platforms, Inc. Sbu Chats non è affiliata a Meta.")
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(SbuTheme.paper)
        .navigationTitle(Text("Come esportare una chat"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Light") {
    NavigationStack { ExportHelpView() }
}

#Preview("Dark") {
    NavigationStack { ExportHelpView() }
        .preferredColorScheme(.dark)
}
