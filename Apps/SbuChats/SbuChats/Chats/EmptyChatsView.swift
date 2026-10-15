import SbuKit
import SwiftUI

/// No chat yet: how to bring one in, a file to pick, and the sample to try.
struct EmptyChatsView: View {
    let pickFile: () -> Void
    let trySample: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space6) {
            VStack(alignment: .leading, spacing: SbuTheme.space2) {
                Text("Nessuna chat")
                    .font(SbuTheme.title2)
                    .foregroundStyle(SbuTheme.ink)
                    .accessibilityAddTraits(.isHeader)
                Text("Nell'app di messaggi apri una chat, scegli Esporta chat e condividila con Sbu Chats. Oppure salvala in File e sceglila da qui.")
                    .font(SbuTheme.body)
                    .foregroundStyle(SbuTheme.inkMuted)
                Text("La chat resta su questo iPhone: Sbu Chats non si collega a internet.")
                    .font(SbuTheme.footnote)
                    .foregroundStyle(SbuTheme.inkMuted)
            }

            VStack(spacing: SbuTheme.space3) {
                SbuButton("Scegli un file", action: pickFile)
                SbuButton("Prova con una chat di esempio", kind: .secondary, action: trySample)
            }

            NavigationLink {
                ExportHelpView()
            } label: {
                Text("Come esportare una chat")
                    .font(SbuTheme.body)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, SbuTheme.space4)
    }
}

#Preview("Light") {
    NavigationStack {
        EmptyChatsView(pickFile: {}, trySample: {})
            .padding(SbuTheme.space4)
    }
}

#Preview("Dark") {
    NavigationStack {
        EmptyChatsView(pickFile: {}, trySample: {})
            .padding(SbuTheme.space4)
    }
    .preferredColorScheme(.dark)
}
