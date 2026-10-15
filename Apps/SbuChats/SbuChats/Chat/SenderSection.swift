import SbuKit
import SwiftUI

/// One person's numbers: messages, words, media, conversations, reply times, streak.
struct SenderSection: View {
    let sender: SenderStatistics

    var body: some View {
        Section {
            StatRow(title: "Messaggi", value: Text("\(sender.messages.formatted()) · \(sender.share.formatted(.percent.precision(.fractionLength(0))))"))
            StatRow(title: "Parole", value: Text(sender.words, format: .number))
            StatRow(title: "Foto, video e altri file", value: Text(sender.media, format: .number))
            StatRow(title: "Conversazioni iniziate", value: Text(sender.conversationsStarted, format: .number))
            StatRow(title: "Conversazioni chiuse", value: Text(sender.conversationsEnded, format: .number))
            StatRow(title: "Risposta tipica", value: replyText(sender.medianReply))
            StatRow(title: "Risposta media", value: replyText(sender.averageReply))
            StatRow(title: "Giorni di fila, record", value: Text("\(sender.longestStreak) giorni"))
        } header: {
            if sender.isOwner {
                Text("Tu · \(sender.name)")
            } else {
                Text(verbatim: sender.name)
            }
        }
        .listRowBackground(SbuTheme.surfaceRaised)
    }

    private func replyText(_ interval: TimeInterval?) -> Text {
        interval.map { Text(verbatim: ReplyTime.text($0)) } ?? Text("Nessuna risposta")
    }
}

#Preview("Light") {
    List { SenderSection(sender: .preview) }
}

#Preview("Dark") {
    List { SenderSection(sender: .preview) }
        .preferredColorScheme(.dark)
}
