import SbuKit
import SwiftUI

/// No chat yet: the waiting zero, how to bring one in, a file to pick, and the sample to try.
struct EmptyChatsView: View {
    let pickFile: () -> Void
    let trySample: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space6) {
            SbuEmpty(sentence: "Nell'app di messaggi apri una chat, scegli Esporta chat e condividila con Sbu Chats. Oppure salvala in File e sceglila da qui.") {
                VStack(spacing: SbuTheme.space3) {
                    SbuButton("Scegli un file", action: pickFile)
                    SbuButton("Prova con una chat di esempio", kind: .secondary, action: trySample)
                }
            }

            NavigationLink {
                ExportHelpView()
            } label: {
                Text("Come esportare una chat")
                    .font(SbuTheme.body)
            }
            .frame(maxWidth: .infinity)

            Text("La chat resta su questo iPhone: Sbu Chats non si collega a internet.")
                .font(SbuTheme.footnote)
                .foregroundStyle(SbuTheme.inkMuted)
        }
    }
}

#Preview("Light") {
    NavigationStack {
        EmptyChatsView(pickFile: {}, trySample: {})
            .padding(SbuTheme.space4)
            .frame(maxHeight: .infinity, alignment: .top)
            .sbuPaper(grid: true)
    }
}

#Preview("Dark") {
    NavigationStack {
        EmptyChatsView(pickFile: {}, trySample: {})
            .padding(SbuTheme.space4)
            .frame(maxHeight: .infinity, alignment: .top)
            .sbuPaper(grid: true)
    }
    .preferredColorScheme(.dark)
}
