import SbuKit
import SwiftUI

/// Modalità post: lift the Shield for 10 minutes to publish from the native app, or bring it back early.
struct PostModeRow: View {
    let shield: ShieldModel

    var body: some View {
        if let end = shield.postModeEnd {
            VStack(alignment: .leading, spacing: SbuTheme.space2) {
                Text("Modalità post fino alle \(end, format: .dateTime.hour().minute())")
                Button("Riattiva lo Schermo", action: shield.endPostMode)
            }
        } else {
            VStack(alignment: .leading, spacing: SbuTheme.space2) {
                Button("Modalità post") { shield.startPostMode() }
                    .disabled(!shield.isOn)
                Text("Sblocca le app per 10 minuti, per pubblicare.")
                    .font(SbuTheme.footnote)
                    .foregroundStyle(SbuTheme.inkMuted)
            }
        }
    }
}

#Preview("Light") {
    PostModeRow(shield: ShieldModel(defaults: UserDefaults(suiteName: "preview")!))
        .padding()
}

#Preview("Dark") {
    PostModeRow(shield: ShieldModel(defaults: UserDefaults(suiteName: "preview")!))
        .padding()
        .preferredColorScheme(.dark)
}
