import SbuKit
import SwiftData
import SwiftUI

/// Settings → shown only when some of the 1.0's subscriptions couldn't be brought over, with a retry.
struct LegacyImportSection: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage(LegacyMigration.Key.skipped, store: .appGroup) private var skipped = 0
    @AppStorage(LegacyMigration.Key.unreadable, store: .appGroup) private var unreadable = false

    var body: some View {
        if skipped > 0 || unreadable {
            Section {
                Label(message, systemImage: "exclamationmark.triangle")
                    .foregroundStyle(SbuTheme.warning)
                Button("Riprova a importare", action: retry)
            } header: {
                Text("Versione precedente")
            } footer: {
                Text("I dati della versione precedente restano su questo iPhone, intatti.")
            }
        }
    }

    private var message: LocalizedStringKey {
        unreadable ? "Non riesco a leggere gli abbonamenti della versione precedente." : "Non importati dalla versione precedente: ^[\(skipped) abbonamento](inflect: true)."
    }

    private func retry() {
        LegacyMigration.run(modelContext)
    }
}
