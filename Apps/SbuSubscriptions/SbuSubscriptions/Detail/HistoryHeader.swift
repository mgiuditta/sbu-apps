import SbuKit
import SwiftUI

/// A detail history section's title with the pencil that edits it.
struct HistoryHeader: View {
    let title: LocalizedStringKey
    let editLabel: LocalizedStringKey
    let edit: () -> Void

    var body: some View {
        HStack {
            Text(title)
                .accessibilityAddTraits(.isHeader)
            Spacer()
            Button(editLabel, systemImage: "pencil", action: edit)
                .labelStyle(.iconOnly)
                .fontWeight(.medium)
                .imageScale(.medium)
                .frame(minWidth: 44, minHeight: 44)
                .contentShape(.rect)
        }
        .textCase(nil)
    }
}

#Preview("Light") {
    List {
        Section {
            Text(verbatim: "16 ott 2026")
        } header: {
            HistoryHeader(title: "Storico dei pagamenti", editLabel: "Modifica lo storico dei pagamenti") {}
        }
    }
}

#Preview("Dark") {
    List {
        Section {
            Text(verbatim: "16 ott 2026")
        } header: {
            HistoryHeader(title: "Storico dei pagamenti", editLabel: "Modifica lo storico dei pagamenti") {}
        }
    }
    .preferredColorScheme(.dark)
}
