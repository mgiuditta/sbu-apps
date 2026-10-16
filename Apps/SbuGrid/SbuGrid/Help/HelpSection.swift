import SbuKit
import SwiftUI

/// Settings section on how to draw with the grid, step by step, and what Sbu Grid does not do.
struct HelpSection: View {
    var body: some View {
        Section {
            ForEach(HelpStep.all) { step in
                Label {
                    Text(step.text)
                        .font(SbuTheme.body)
                        .foregroundStyle(SbuTheme.ink)
                } icon: {
                    Image(systemName: step.systemImage)
                        .fontWeight(.medium)
                        .imageScale(.medium)
                        .foregroundStyle(SbuTheme.inkMuted)
                }
            }
        } header: {
            Text("Come si usa")
        } footer: {
            Text("Sbu Grid non disegna al posto tuo: ti aiuta a disegnare sulla carta. Per questo non ha pennelli né disegno sullo schermo.")
        }
    }
}

#Preview("Light") {
    List {
        HelpSection()
    }
}

#Preview("Dark") {
    List {
        HelpSection()
    }
    .preferredColorScheme(.dark)
}
