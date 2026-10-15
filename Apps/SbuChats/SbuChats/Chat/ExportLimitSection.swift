import SbuKit
import SwiftUI

/// The honest note under the numbers: an export holds only the most recent messages.
struct ExportLimitSection: View {
    let chat: ChatSummary

    var body: some View {
        Section {
        } footer: {
            Text("Un export contiene al massimo circa 40.000 messaggi senza media o 10.000 con i media, i più recenti: questa chat parte dal \(ChatDates.day(chat.firstMessageAt)). Esportala di nuovo più avanti e Sbu Chats aggiunge i messaggi nuovi a questi.")
        }
    }
}
