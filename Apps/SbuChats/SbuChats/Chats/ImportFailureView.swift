import SbuKit
import SwiftUI

/// Why the file didn't become a chat, the line that was found, and how to export again.
struct ImportFailureView: View {
    let failure: ImportFailure

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: SbuTheme.space2) {
                    Label {
                        Text(failure.title)
                            .font(SbuTheme.headline)
                            .foregroundStyle(SbuTheme.ink)
                    } icon: {
                        Image(systemName: "exclamationmark.triangle")
                            .fontWeight(.medium)
                            .foregroundStyle(SbuTheme.danger)
                    }
                    Text(failure.explanation)
                        .font(SbuTheme.body)
                        .foregroundStyle(SbuTheme.inkMuted)
                }
                .accessibilityElement(children: .combine)
            }

            if let line = failure.sampleLine {
                Section("Riga trovata") {
                    Text(verbatim: line)
                        .font(SbuTheme.footnote.monospaced())
                        .foregroundStyle(SbuTheme.ink)
                        .textSelection(.enabled)
                }
            }

            Section {
                NavigationLink("Come esportare una chat") {
                    ExportHelpView()
                }
            } footer: {
                Text("Nulla è stato importato. Il file resta dov'era.")
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .navigationTitle(Text("Importazione"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Chiudi") { dismiss() }
            }
        }
    }
}

#Preview("Light") {
    NavigationStack { ImportFailureView(failure: .unrecognizedFormat(firstLine: "Lista della spesa")) }
}

#Preview("Dark") {
    NavigationStack { ImportFailureView(failure: .unrecognizedFormat(firstLine: "Lista della spesa")) }
        .preferredColorScheme(.dark)
}
